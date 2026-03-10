const { Router } = require('express');
const userController = require('../controllers/user.controller');
const { authGuard } = require('../middleware/auth');

const router = Router();

router.get('/', authGuard, userController.getNotifications);
router.put('/read-all', authGuard, userController.markAllNotificationsRead);

module.exports = router;
