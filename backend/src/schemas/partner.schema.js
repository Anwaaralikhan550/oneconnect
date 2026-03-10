const Joi = require('joi');
const strongPasswordPattern =
  /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[^A-Za-z\d]).{10,128}$/;

const partnerRegisterSchema = Joi.object({
  businessName: Joi.string().min(2).max(200).required(),
  ownerFullName: Joi.string().min(2).max(100).required(),
  businessEmail: Joi.string().email().required(),
  password: Joi.string().pattern(strongPasswordPattern).required().messages({
    'string.pattern.base':
      'Password must be 10-128 chars and include uppercase, lowercase, number, and special character',
  }),
  businessType: Joi.string().valid('RESTAURANT', 'RETAIL_STORE', 'SERVICE_PROVIDER', 'ONLINE_BUSINESS', 'OTHER').required(),
  address: Joi.string().max(500).allow('', null),
  area: Joi.string().max(100).allow('', null),
  city: Joi.string().max(100).allow('', null),
  country: Joi.string().max(100).default('Pakistan'),
  openingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  closingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  description: Joi.string().max(2000).allow('', null),
  phones: Joi.array().items(Joi.object({
    phoneNumber: Joi.string().required(),
    countryCode: Joi.string().default('+92'),
    isPrimary: Joi.boolean().default(false),
  })).max(5),
  operatingDays: Joi.array().items(
    Joi.string().valid('Su', 'M', 'T', 'W', 'Th', 'F', 'S')
  ).max(7),
  categoryIds: Joi.array().items(Joi.string().uuid()).max(5),
});

const partnerLoginSchema = Joi.object({
  businessId: Joi.string().required(),
  password: Joi.string().required(),
});

const partnerRefreshSchema = Joi.object({
  refreshToken: Joi.string().required(),
});

const partnerForgotPasswordSchema = Joi.object({
  businessId: Joi.string().required(),
  redirectUrl: Joi.string().uri().allow('', null),
});

const partnerResetPasswordSchema = Joi.object({
  token: Joi.string().min(20).max(2048).required(),
  newPassword: Joi.string().pattern(strongPasswordPattern).required().messages({
    'string.pattern.base':
      'Password must be 10-128 chars and include uppercase, lowercase, number, and special character',
  }),
});

const partnerUpdateSchema = Joi.object({
  businessName: Joi.string().min(2).max(200),
  ownerFullName: Joi.string().min(2).max(100),
  address: Joi.string().max(500).allow('', null),
  area: Joi.string().max(100).allow('', null),
  city: Joi.string().max(100).allow('', null),
  openingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  closingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  isBusinessOpen: Joi.boolean(),
  description: Joi.string().max(2000).allow('', null),
  followUsEnabled: Joi.boolean(),
  isFollowEnabled: Joi.boolean(),
  facebookUrl: Joi.string().uri().max(500).allow('', null),
  instagramUrl: Joi.string().uri().max(500).allow('', null),
  whatsapp: Joi.string().max(50).allow('', null),
  websiteUrl: Joi.string().uri().max(500).allow('', null),
}).min(1);

const partnerPhonesSchema = Joi.object({
  phones: Joi.array().items(Joi.object({
    phoneNumber: Joi.string().required(),
    countryCode: Joi.string().default('+92'),
    isPrimary: Joi.boolean().default(false),
  })).min(1).max(5).required(),
});

module.exports = {
  partnerRegisterSchema,
  partnerLoginSchema,
  partnerRefreshSchema,
  partnerForgotPasswordSchema,
  partnerResetPasswordSchema,
  partnerUpdateSchema,
  partnerPhonesSchema,
};
