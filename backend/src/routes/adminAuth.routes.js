const { Router } = require('express');
const adminAuthController = require('../controllers/adminAuth.controller');
const { adminAuthGuard } = require('../middleware/adminAuth');
const { validate } = require('../middleware/validate');
const {
  adminLoginSchema,
  adminRefreshSchema,
  adminLogoutSchema,
} = require('../schemas/adminAuth.schema');

const router = Router();

router.post('/login', validate(adminLoginSchema), adminAuthController.login);
router.post('/refresh', validate(adminRefreshSchema), adminAuthController.refresh);
router.post('/logout', adminAuthGuard, validate(adminLogoutSchema), adminAuthController.logout);

module.exports = router;
