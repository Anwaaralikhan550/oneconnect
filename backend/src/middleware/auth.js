const jwt = require('jsonwebtoken');
const { env } = require('../config/env');
const { prisma } = require('../config/database');

/**
 * User JWT authentication guard.
 * Extracts Bearer token, verifies it, attaches req.user = { id, email }.
 */
async function authGuard(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Access token required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    if (decoded.role !== 'user') {
      return res.status(403).json({ success: false, error: 'User access required' });
    }
    const user = await prisma.user.findUnique({
      where: { id: decoded.sub },
      select: { isBanned: true },
    });
    if (!user) {
      return res.status(401).json({ success: false, error: 'Invalid token' });
    }
    if (user.isBanned) {
      return res.status(403).json({ success: false, error: 'Account is banned' });
    }
    req.user = { id: decoded.sub, email: decoded.email };
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, error: 'Token expired' });
    }
    return res.status(401).json({ success: false, error: 'Invalid token' });
  }
}

/**
 * Optional auth — same as authGuard but does not reject unauthenticated requests.
 * If a valid token is present, sets req.user; otherwise continues without it.
 */
async function optionalAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next();
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    if (decoded.role === 'user') {
      const user = await prisma.user.findUnique({
        where: { id: decoded.sub },
        select: { isBanned: true },
      });
      if (user && !user.isBanned) {
        req.user = { id: decoded.sub, email: decoded.email };
      }
    }
  } catch (_) {
    // Token invalid or expired — continue without user
  }
  next();
}

module.exports = { authGuard, optionalAuth };
