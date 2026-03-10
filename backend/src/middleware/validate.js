/**
 * Joi validation middleware factory.
 * @param {import('joi').ObjectSchema} schema - Joi schema to validate against
 * @param {'body'|'query'|'params'} source - Request property to validate
 */
function validate(schema, source = 'body') {
  return (req, res, next) => {
    const { error, value } = schema.validate(req[source], {
      abortEarly: false,
      stripUnknown: true,
    });

    if (error) {
      return res.status(400).json({
        success: false,
        error: error.details.map(d => d.message).join(', '),
      });
    }

    // Replace with validated & stripped value
    req[source] = value;
    next();
  };
}

module.exports = { validate };
