const jwt = require('jsonwebtoken');
const { env } = require('../config/env');
const { prisma } = require('../config/database');

/**
 * Accepts either user or partner access token.
 * Sets req.actor = { role: 'user'|'partner', id: string, businessId?: string }.
 */
async function anyAuthGuard(req, res, next) {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ success: false, error: 'Access token required' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, env.JWT_SECRET);
    if (decoded.role === 'user') {
      const user = await prisma.user.findUnique({
        where: { id: decoded.sub },
        select: { isBanned: true },
      });
      if (!user) return res.status(401).json({ success: false, error: 'Invalid token' });
      if (user.isBanned) {
        return res.status(403).json({ success: false, error: 'Account is banned' });
      }
      req.actor = { role: 'user', id: decoded.sub };
      return next();
    }

    if (decoded.role === 'partner') {
      const partner = await prisma.partner.findUnique({
        where: { id: decoded.sub },
        select: { status: true },
      });
      if (!partner) return res.status(401).json({ success: false, error: 'Invalid token' });
      if (partner.status === 'SUSPENDED') {
        return res.status(403).json({ success: false, error: 'Account suspended. Contact support.' });
      }
      req.actor = { role: 'partner', id: decoded.sub, businessId: decoded.businessId };
      return next();
    }

    return res.status(403).json({ success: false, error: 'Unsupported role' });
  } catch (err) {
    if (err.name === 'TokenExpiredError') {
      return res.status(401).json({ success: false, error: 'Token expired' });
    }
    return res.status(401).json({ success: false, error: 'Invalid token' });
  }
}

module.exports = { anyAuthGuard };
