const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');
const { prisma } = require('../config/database');
const { env } = require('../config/env');
const { AppError } = require('../middleware/errorHandler');

const SALT_ROUNDS = 12;

function hashToken(token) {
  return crypto.createHash('sha256').update(String(token)).digest('hex');
}

function generateTokens(payload) {
  const accessToken = jwt.sign(payload, env.JWT_SECRET, {
    expiresIn: env.JWT_EXPIRES_IN,
  });
  const refreshToken = jwt.sign(
    { ...payload, jti: uuidv4() },
    env.JWT_REFRESH_SECRET,
    { expiresIn: env.JWT_REFRESH_EXPIRES_IN }
  );
  return { accessToken, refreshToken };
}

function parseExpiry(expiresIn) {
  const match = expiresIn.match(/^(\d+)([smhd])$/);
  if (!match) return 7 * 24 * 60 * 60 * 1000; // default 7 days
  const num = parseInt(match[1], 10);
  const unit = match[2];
  const multipliers = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
  return num * (multipliers[unit] || 86400000);
}

function normalizeUrlPrefix(value) {
  const raw = String(value || '').trim();
  if (!raw) return '';
  return raw.endsWith('/') ? raw.slice(0, -1) : raw;
}

function isAllowedRedirectUrl(redirectUrl) {
  const candidate = normalizeUrlPrefix(redirectUrl);
  if (!candidate) return false;

  const allowList = String(env.PASSWORD_RESET_ALLOWED_REDIRECTS || '')
    .split(',')
    .map((s) => normalizeUrlPrefix(s))
    .filter(Boolean);

  if (allowList.length === 0) return false;
  return allowList.some((allowed) => candidate.startsWith(allowed));
}

function buildResetLink(token, redirectUrl) {
  const fallbackBase = env.PASSWORD_RESET_URL || 'oneconnect://reset-password';
  const baseUrl = isAllowedRedirectUrl(redirectUrl) ? redirectUrl : fallbackBase;
  const separator = baseUrl.includes('?') ? '&' : '?';
  return `${baseUrl}${separator}token=${encodeURIComponent(token)}`;
}

async function register({ name, email, password, phone }) {
  const normalizedEmail = String(email || '').trim().toLowerCase();
  const existing = await prisma.user.findUnique({ where: { email: normalizedEmail } });
  if (existing) {
    throw new AppError('Email already registered', 409);
  }

  const passwordHash = await bcrypt.hash(password, SALT_ROUNDS);
  const user = await prisma.user.create({
    data: { name, email: normalizedEmail, passwordHash, phone },
    select: { id: true, name: true, email: true, phone: true, createdAt: true },
  });

  const tokens = generateTokens({ sub: user.id, email: user.email, role: 'user' });

  // Store refresh token
  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      token: hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN)),
    },
  });

  return { user, ...tokens };
}

async function login({ email, password }) {
  const normalizedEmail = String(email || '').trim().toLowerCase();
  const user = await prisma.user.findUnique({ where: { email: normalizedEmail } });
  if (!user) {
    throw new AppError('Invalid email or password', 401);
  }
  if (user.isBanned) {
    throw new AppError('Account is banned', 403);
  }

  const valid = await bcrypt.compare(password, user.passwordHash);
  if (!valid) {
    throw new AppError('Invalid email or password', 401);
  }

  const tokens = generateTokens({ sub: user.id, email: user.email, role: 'user' });

  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      token: hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN)),
    },
  });

  return {
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      phone: user.phone,
      profilePhotoUrl: user.profilePhotoUrl,
    },
    ...tokens,
  };
}

async function refresh(refreshToken) {
  const incomingToken = String(refreshToken || '');
  if (!incomingToken) throw new AppError('Refresh token required', 400);

  let decoded;
  try {
    decoded = jwt.verify(incomingToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }
  if (decoded.role !== 'user') {
    throw new AppError('Invalid refresh token', 401);
  }

  const tokenHash = hashToken(incomingToken);
  const stored = await prisma.refreshToken.findFirst({
    where: { OR: [{ token: tokenHash }, { token: incomingToken }] },
  });

  if (!stored || stored.expiresAt < new Date()) {
    if (stored) await prisma.refreshToken.delete({ where: { id: stored.id } });
    throw new AppError('Refresh token expired or revoked', 401);
  }

  const user = await prisma.user.findUnique({
    where: { id: decoded.sub },
    select: { id: true, email: true, isBanned: true },
  });
  if (!user) {
    await prisma.refreshToken.delete({ where: { id: stored.id } });
    throw new AppError('Invalid refresh token', 401);
  }
  if (user.isBanned) {
    await prisma.refreshToken.deleteMany({ where: { userId: user.id } });
    throw new AppError('Account is banned', 403);
  }

  // Rotate: delete old, create new
  await prisma.refreshToken.delete({ where: { id: stored.id } });

  const tokens = generateTokens({ sub: user.id, email: user.email, role: 'user' });

  await prisma.refreshToken.create({
    data: {
      userId: user.id,
      token: hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN)),
    },
  });

  return tokens;
}

async function logout(userId, refreshToken) {
  const incomingToken = String(refreshToken || '');
  if (!incomingToken) {
    throw new AppError('refreshToken is required', 400);
  }

  let decoded;
  try {
    decoded = jwt.verify(incomingToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }
  if (decoded.role !== 'user') {
    throw new AppError('Invalid refresh token', 401);
  }

  const ownerId = userId || decoded.sub;
  if (decoded.sub !== ownerId) {
    throw new AppError('Invalid refresh token', 401);
  }

  const tokenHash = hashToken(incomingToken);
  await prisma.refreshToken.deleteMany({
    where: { userId: ownerId, OR: [{ token: tokenHash }, { token: incomingToken }] },
  });
}

async function forgotPassword(email, redirectUrl) {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    // Don't reveal whether email exists
    return { message: 'If the email exists, a reset link has been sent' };
  }

  const token = crypto.randomBytes(32).toString('hex');
  const tokenHash = hashToken(token);
  const expiresAt = new Date(Date.now() + 15 * 60 * 1000); // 15 min
  await prisma.passwordResetToken.deleteMany({ where: { userId: user.id } });
  await prisma.passwordResetToken.create({
    data: { userId: user.id, tokenHash, expiresAt },
  });

  const resetLink = buildResetLink(token, redirectUrl);

  // In production, send resetLink via email.
  if (env.ALLOW_PLAINTEXT_RESET_LOGS && env.NODE_ENV !== 'production') {
    console.log(`[PASSWORD_RESET_LINK] ${email}: ${resetLink}`);
  } else {
    console.log(`[PASSWORD_RESET_REQUESTED] ${email}`);
  }

  return { message: 'If the email exists, a reset link has been sent' };
}

async function resetPassword(token, newPassword) {
  const tokenHash = hashToken(token);
  const stored = await prisma.passwordResetToken.findUnique({
    where: { tokenHash },
  });
  if (!stored || stored.expiresAt < new Date()) {
    throw new AppError('Invalid or expired reset token', 400);
  }

  const user = await prisma.user.findUnique({ where: { id: stored.userId } });
  if (!user) {
    await prisma.passwordResetToken.deleteMany({ where: { tokenHash } });
    throw new AppError('Invalid or expired reset token', 400);
  }

  const passwordHash = await bcrypt.hash(newPassword, SALT_ROUNDS);
  await prisma.user.update({
    where: { id: user.id },
    data: { passwordHash },
  });

  await prisma.passwordResetToken.deleteMany({ where: { userId: user.id } });

  // Invalidate all refresh tokens
  await prisma.refreshToken.deleteMany({ where: { userId: user.id } });

  return { message: 'Password reset successful' };
}

module.exports = {
  register,
  login,
  refresh,
  logout,
  forgotPassword,
  resetPassword,
};
