const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const { v4: uuidv4 } = require('uuid');
const crypto = require('crypto');
const { prisma } = require('../config/database');
const { env } = require('../config/env');
const { AppError } = require('../middleware/errorHandler');

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
  if (!match) return 7 * 24 * 60 * 60 * 1000;
  const num = parseInt(match[1], 10);
  const unit = match[2];
  const multipliers = { s: 1000, m: 60000, h: 3600000, d: 86400000 };
  return num * (multipliers[unit] || 86400000);
}

async function login({ email, password }) {
  const admin = await prisma.admin.findUnique({ where: { email } });
  if (!admin) {
    throw new AppError('Invalid email or password', 401);
  }

  const valid = await bcrypt.compare(password, admin.passwordHash);
  if (!valid) {
    throw new AppError('Invalid email or password', 401);
  }

  const tokens = generateTokens({ sub: admin.id, email: admin.email, role: 'admin' });

  await prisma.adminRefreshToken.create({
    data: {
      adminId: admin.id,
      token: hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN)),
    },
  });

  return {
    admin: { id: admin.id, name: admin.name, email: admin.email },
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

  if (decoded.role !== 'admin') {
    throw new AppError('Invalid refresh token', 401);
  }

  const tokenHash = hashToken(incomingToken);
  const stored = await prisma.adminRefreshToken.findFirst({
    where: { OR: [{ token: tokenHash }, { token: incomingToken }] },
  });

  if (!stored || stored.expiresAt < new Date()) {
    if (stored) await prisma.adminRefreshToken.delete({ where: { id: stored.id } });
    throw new AppError('Refresh token expired or revoked', 401);
  }

  // Rotate: delete old, create new
  await prisma.adminRefreshToken.delete({ where: { id: stored.id } });

  const tokens = generateTokens({ sub: decoded.sub, email: decoded.email, role: 'admin' });

  await prisma.adminRefreshToken.create({
    data: {
      adminId: decoded.sub,
      token: hashToken(tokens.refreshToken),
      expiresAt: new Date(Date.now() + parseExpiry(env.JWT_REFRESH_EXPIRES_IN)),
    },
  });

  return tokens;
}

async function logout(adminId, refreshToken) {
  const incomingToken = String(refreshToken || '');
  if (!incomingToken) throw new AppError('refreshToken is required', 400);

  let decoded;
  try {
    decoded = jwt.verify(incomingToken, env.JWT_REFRESH_SECRET);
  } catch {
    throw new AppError('Invalid refresh token', 401);
  }
  if (decoded.role !== 'admin' || decoded.sub !== adminId) {
    throw new AppError('Invalid refresh token', 401);
  }

  const tokenHash = hashToken(incomingToken);
  await prisma.adminRefreshToken.deleteMany({
    where: { adminId, OR: [{ token: tokenHash }, { token: incomingToken }] },
  });
}

module.exports = { login, refresh, logout };
