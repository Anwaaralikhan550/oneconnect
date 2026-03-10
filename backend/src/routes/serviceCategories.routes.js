const { Router } = require('express');
const serviceCategoryController = require('../controllers/serviceCategory.controller');

const router = Router();

router.get('/', serviceCategoryController.list);

module.exports = router;
