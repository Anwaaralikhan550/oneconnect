const { Router } = require('express');
const propertyController = require('../controllers/property.controller');
const { validate } = require('../middleware/validate');
const { propertyQuerySchema, idParamSchema } = require('../schemas/common.schema');

const router = Router();

router.get('/', validate(propertyQuerySchema, 'query'), propertyController.list);
router.get('/:id', validate(idParamSchema, 'params'), propertyController.getById);

module.exports = router;
