const { Router } = require('express');
const adminController = require('../controllers/admin.controller');

const router = Router();

router.get('/', adminController.listOffices);
router.get('/:id', adminController.getOfficeById);

module.exports = router;
