const adminAuthService = require('../services/adminAuth.service');

async function login(req, res, next) {
  try {
    const result = await adminAuthService.login(req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function refresh(req, res, next) {
  try {
    const result = await adminAuthService.refresh(req.body.refreshToken);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function logout(req, res, next) {
  try {
    await adminAuthService.logout(req.admin.id, req.body.refreshToken);
    res.json({ success: true, data: { message: 'Logged out' } });
  } catch (err) {
    next(err);
  }
}

module.exports = { login, refresh, logout };
