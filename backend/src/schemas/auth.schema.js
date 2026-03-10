const Joi = require('joi');
const strongPasswordPattern =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{10,128}$/;

const registerSchema = Joi.object({
  name: Joi.string().min(2).max(100).required(),
  email: Joi.string().email().required(),
  password: Joi.string().pattern(strongPasswordPattern).required().messages({
    'string.pattern.base':
      'Password must be 10-128 chars and include uppercase, lowercase, number, and special character',
  }),
  phone: Joi.string().pattern(/^\+?[0-9\-\s]{7,15}$/).allow('', null),
});

const loginSchema = Joi.object({
  email: Joi.string().email().required(),
  password: Joi.string().required(),
});

const refreshSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

const logoutSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

const forgotPasswordSchema = Joi.object({
  email: Joi.string().email().required(),
  redirectUrl: Joi.string().uri().allow('', null),
});

const resetPasswordSchema = Joi.object({
  token: Joi.string().min(20).max(512).required(),
  newPassword: Joi.string().pattern(strongPasswordPattern).required().messages({
    'string.pattern.base':
      'Password must be 10-128 chars and include uppercase, lowercase, number, and special character',
  }),
});

module.exports = {
  registerSchema,
  loginSchema,
  refreshSchema,
  logoutSchema,
  forgotPasswordSchema,
  resetPasswordSchema,
};
