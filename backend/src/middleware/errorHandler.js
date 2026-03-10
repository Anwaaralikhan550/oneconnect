/**
 * Global error handler middleware.
 * Ensures consistent { success, error } response shape.
 */
function errorHandler(err, req, res, _next) {
  console.error(`[Error] ${err.message}`, err.stack);

  // Joi validation error
  if (err.isJoi) {
    return res.status(400).json({
      success: false,
      error: err.details.map(d => d.message).join(', '),
    });
  }

  // Prisma known request error
  if (err.code === 'P2002') {
    const field = err.meta?.target?.join(', ') || 'field';
    return res.status(409).json({
      success: false,
      error: `Duplicate value for ${field}`,
    });
  }

  if (err.code === 'P2025') {
    return res.status(404).json({
      success: false,
      error: 'Record not found',
    });
  }

  // Custom AppError
  if (err.statusCode) {
    return res.status(err.statusCode).json({
      success: false,
      error: err.message,
    });
  }

  // Default server error
  res.status(500).json({
    success: false,
    error: process.env.NODE_ENV === 'production'
      ? 'Internal server error'
      : err.message,
  });
}

/**
 * Custom error class with HTTP status code.
 */
class AppError extends Error {
  constructor(message, statusCode = 400) {
    super(message);
    this.statusCode = statusCode;
    this.name = 'AppError';
  }
}

module.exports = { errorHandler, AppError };
