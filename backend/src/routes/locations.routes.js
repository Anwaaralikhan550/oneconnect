const { Router } = require('express');
const locationController = require('../controllers/location.controller');

const router = Router();

router.get('/', locationController.list);

module.exports = router;

