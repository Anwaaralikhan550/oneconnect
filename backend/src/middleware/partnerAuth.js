const jwt = require('jsonwebtoken');
const { env } = require('../config/env');
const { prisma } = require('../config/database');

/**
 * Partner JWT authentication guard.
 * Extracts Bearer token, verifies it, attaches req.partner = { id, businessId }.
 */
async function partnerAuthGuard(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Access token required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    if (decoded.role !== 'partner') {
      return res.status(403).json({ success: false, error: 'Partner access required' });
    }
    const partner = await prisma.partner.findUnique({
      where: { id: decoded.sub },
      select: { status: true },
    });
    if (!partner) {
      return res.status(401).json({ success: false, error: 'Invalid token' });
    }
    if (partner.status === 'SUSPENDED') {
      return res.status(403).json({ success: false, error: 'Account suspended. Contact support.' });
    }
    req.partner = { id: decoded.sub, businessId: decoded.businessId };
    next();
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, error: 'Token expired' });
    }
    return res.status(401).json({ success: false, error: 'Invalid token' });
  }
}

async function optionalPartnerAuth(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return next();
  }

  const token = authHeader.split(' ')[1];
  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    if (decoded.role === 'partner') {
      const partner = await prisma.partner.findUnique({
        where: { id: decoded.sub },
        select: { status: true },
      });
      if (partner && partner.status !== 'SUSPENDED') {
        req.partner = { id: decoded.sub, businessId: decoded.businessId };
      }
    }
  } catch (_) {
    // Invalid/expired token -> continue unauthenticated.
  }
  next();
}

module.exports = { partnerAuthGuard, optionalPartnerAuth };
