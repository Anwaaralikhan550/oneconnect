const Joi = require('joi');

const paginationSchema = Joi.object({
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

const serviceProviderQuerySchema = Joi.object({
  type: Joi.string().valid('LAUNDRY', 'PLUMBER', 'ELECTRICIAN', 'PAINTER', 'CARPENTER', 'BARBER', 'MAID', 'SALON', 'REAL_ESTATE', 'DOCTOR', 'WATER', 'GAS'),
  city: Joi.string().max(100),
  area: Joi.string().max(100).allow('', null),
  minRating: Joi.number().min(0).max(5),
  locationMode: Joi.string().valid('AREA', 'BLOCK', 'DISTANCE').allow('', null),
  priceTier: Joi.string().valid('RS', 'RS_PLUS', 'RS_PLUS_PLUS').allow('', null),
  sortBy: Joi.string().valid('FEATURED', 'NEAR_ME', 'NEWLY_OPENED').allow('', null),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  radiusKm: Joi.number().min(0.1).max(200).default(25),
  isTopRated: Joi.boolean(),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

const serviceSkillSuggestionsQuerySchema = Joi.object({
  type: Joi.string().valid('LAUNDRY', 'PLUMBER', 'ELECTRICIAN', 'PAINTER', 'CARPENTER', 'BARBER', 'MAID', 'SALON', 'REAL_ESTATE', 'DOCTOR', 'WATER', 'GAS').required(),
});

const businessQuerySchema = Joi.object({
  category: Joi.string().valid('STORE', 'SOLAR', 'BANK', 'RESTAURANT', 'REAL_ESTATE', 'HOME_CHEF'),
  minRating: Joi.number().min(0).max(5),
  locationMode: Joi.string().valid('AREA', 'BLOCK', 'DISTANCE').allow('', null),
  priceTier: Joi.string().valid('RS', 'RS_PLUS', 'RS_PLUS_PLUS').allow('', null),
  sortBy: Joi.string().valid('FEATURED', 'NEAR_ME', 'NEWLY_OPENED').allow('', null),
  area: Joi.string().max(100).allow('', null),
  city: Joi.string().max(100).allow('', null),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  radiusKm: Joi.number().min(0.1).max(200).default(25),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

const amenityQuerySchema = Joi.object({
  type: Joi.string().valid('MASJID', 'PARK', 'GYM', 'HEALTHCARE', 'SCHOOL', 'PHARMACY', 'CAFE', 'ADMIN'),
  minRating: Joi.number().min(0).max(5),
  locationMode: Joi.string().valid('AREA', 'BLOCK', 'DISTANCE').allow('', null),
  priceTier: Joi.string().valid('RS', 'RS_PLUS', 'RS_PLUS_PLUS').allow('', null),
  sortBy: Joi.string().valid('FEATURED', 'NEAR_ME', 'NEWLY_OPENED').allow('', null),
  area: Joi.string().max(100).allow('', null),
  city: Joi.string().max(100).allow('', null),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  radiusKm: Joi.number().min(0.1).max(200).default(25),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

const propertyQuerySchema = Joi.object({
  city: Joi.string().max(100),
  minPrice: Joi.number().min(0),
  maxPrice: Joi.number().min(0),
  propertyType: Joi.string().valid('House', 'Apartment', 'Plot', 'RENTAL', 'SALE'),
  partnerId: Joi.string().uuid().allow('', null),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

const partnerPropertyCreateSchema = Joi.object({
  title: Joi.string().min(2).max(200).required(),
  serviceProviderId: Joi.string().uuid().required(),
  location: Joi.string().max(500).allow('', null),
  beds: Joi.number().integer().min(0).allow(null),
  baths: Joi.number().integer().min(0).allow(null),
  kitchen: Joi.number().integer().min(0).allow(null),
  propertyType: Joi.string().valid('House', 'Apartment', 'Plot').allow('', null),
  purpose: Joi.string().valid('RENTAL', 'SALE').allow('', null),
  listingStatus: Joi.string().valid('SUPER_HOT', 'RENTAL', 'FEATURED').allow('', null),
  price: Joi.number().min(0).allow(null),
  mainImageUrl: Joi.string().uri().allow('', null),
  description: Joi.string().max(2000).allow('', null),
  sqft: Joi.number().min(0).allow(null),
  imageUrls: Joi.array().items(Joi.string().uri()).max(20).allow(null),
});

const reviewSchema = Joi.object({
  rating: Joi.number().min(1).max(5).required(),
  ratingText: Joi.string().max(50).allow('', null),
  reviewText: Joi.string().max(2000).allow('', null),
  imageUrl: Joi.string().uri().allow('', null),
  mediaUrl: Joi.string().uri().allow('', null),
});

const searchQuerySchema = Joi.object({
  q: Joi.string().trim().min(1).max(200).required(),
  category: Joi.string().valid('Shop', 'Service').allow('', null),
  minRating: Joi.number().min(0).max(5),
  entityType: Joi.string().valid('SERVICE', 'BUSINESS', 'AMENITY').allow('', null),
  locationMode: Joi.string().valid('AREA', 'BLOCK', 'DISTANCE').allow('', null),
  priceTier: Joi.string().valid('RS', 'RS_PLUS', 'RS_PLUS_PLUS').allow('', null),
  sortBy: Joi.string().valid('FEATURED', 'NEAR_ME', 'NEWLY_OPENED').allow('', null),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  radiusKm: Joi.number().min(0.1).max(200).default(25),
  page: Joi.number().integer().min(1).default(1),
  limit: Joi.number().integer().min(1).max(100).default(20),
});

const searchPopularQuerySchema = Joi.object({
  q: Joi.string().trim().max(200).allow('', null),
  category: Joi.string().valid('Shop', 'Service').allow('', null),
  minRating: Joi.number().min(0).max(5),
  entityType: Joi.string().valid('SERVICE', 'BUSINESS', 'AMENITY').allow('', null),
  serviceType: Joi.string()
    .valid(
      'LAUNDRY',
      'PLUMBER',
      'ELECTRICIAN',
      'PAINTER',
      'CARPENTER',
      'BARBER',
      'MAID',
      'SALON',
      'REAL_ESTATE',
      'DOCTOR',
      'WATER',
      'GAS',
    )
    .allow('', null),
  excludeServiceType: Joi.string()
    .valid(
      'LAUNDRY',
      'PLUMBER',
      'ELECTRICIAN',
      'PAINTER',
      'CARPENTER',
      'BARBER',
      'MAID',
      'SALON',
      'REAL_ESTATE',
      'DOCTOR',
      'WATER',
      'GAS',
    )
    .allow('', null),
  businessCategory: Joi.string()
    .valid('STORE', 'SOLAR', 'BANK', 'RESTAURANT', 'REAL_ESTATE', 'HOME_CHEF')
    .allow('', null),
  locationMode: Joi.string().valid('AREA', 'BLOCK', 'DISTANCE').allow('', null),
  priceTier: Joi.string().valid('RS', 'RS_PLUS', 'RS_PLUS_PLUS').allow('', null),
  sortBy: Joi.string().valid('FEATURED', 'NEAR_ME', 'NEWLY_OPENED').allow('', null),
  latitude: Joi.number().min(-90).max(90),
  longitude: Joi.number().min(-180).max(180),
  radiusKm: Joi.number().min(0.1).max(200).default(25),
});

const searchSuggestionSchema = Joi.object({
  q: Joi.string().trim().min(1).max(200).required(),
});

const searchHistorySaveSchema = Joi.object({
  query: Joi.string().trim().min(1).max(200).required(),
  category: Joi.string().valid('Shop', 'Service').allow('', null),
});

const promotionSchema = Joi.object({
  title: Joi.string().min(2).max(200).required(),
  price: Joi.number().min(0).allow(null),
  discountPct: Joi.number().min(0).max(100).allow(null),
  description: Joi.string().max(2000).allow('', null),
  imageUrl: Joi.string().uri().allow('', null),
  isActive: Joi.boolean().default(true),
  expiresAt: Joi.date().iso().allow(null),
  businessId: Joi.string().uuid().allow(null),
});

const serviceProviderCreateSchema = Joi.object({
  name: Joi.string().min(2).max(200).required(),
  serviceType: Joi.string().valid('LAUNDRY', 'PLUMBER', 'ELECTRICIAN', 'PAINTER', 'CARPENTER', 'BARBER', 'MAID', 'SALON', 'REAL_ESTATE', 'DOCTOR', 'WATER', 'GAS').required(),
  categoryId: Joi.string().uuid().allow(null),
  phone: Joi.string().allow('', null),
  address: Joi.string().max(500).allow('', null),
  city: Joi.string().max(100).default('Lahore'),
  serviceCharge: Joi.number().min(0).allow(null),
  imageUrl: Joi.string().uri().allow('', null),
  skills: Joi.array().items(Joi.string().max(100)).max(20).allow(null),
  jobsCompleted: Joi.number().integer().min(0).allow(null),
  vendorId: Joi.string().max(100).allow('', null),
  responseTime: Joi.string().max(100).allow('', null),
  workingSince: Joi.string().max(10).allow('', null),
  isTopRated: Joi.boolean().allow(null),
  patientsCount: Joi.number().integer().min(0).allow(null),
  doctorId: Joi.string().max(100).allow('', null),
  experienceYears: Joi.number().integer().min(0).allow(null),
  hospitalName: Joi.string().max(200).allow('', null),
  consultationCharge: Joi.number().min(0).allow(null),
  contentStatus: Joi.string().valid('PENDING'),
});

const businessCreateSchema = Joi.object({
  name: Joi.string().min(2).max(200).required(),
  category: Joi.string().valid('STORE', 'SOLAR', 'BANK', 'RESTAURANT', 'REAL_ESTATE', 'HOME_CHEF').required(),
  location: Joi.string().max(500).allow('', null),
  phone: Joi.string().allow('', null),
  description: Joi.string().max(2000).allow('', null),
  imageUrl: Joi.string().uri().allow('', null),
  openingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  closingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  operatingDays: Joi.array().items(
    Joi.string().valid('Su', 'M', 'T', 'W', 'Th', 'F', 'S')
  ).max(7).allow(null),
  servicesOffered: Joi.array().items(Joi.string().max(100)).max(30).allow(null),
  facebookUrl: Joi.string().uri().max(500).allow('', null),
  instagramUrl: Joi.string().uri().max(500).allow('', null),
  whatsapp: Joi.string().max(50).allow('', null),
  websiteUrl: Joi.string().uri().max(500).allow('', null),
  contentStatus: Joi.string().valid('PENDING'),
});

const amenityCreateSchema = Joi.object({
  name: Joi.string().min(2).max(200).required(),
  amenityType: Joi.string().valid('MASJID', 'PARK', 'GYM', 'HEALTHCARE', 'SCHOOL', 'PHARMACY', 'CAFE', 'ADMIN').required(),
  location: Joi.string().max(500).allow('', null),
  phone: Joi.string().allow('', null),
  description: Joi.string().max(2000).allow('', null),
  imageUrl: Joi.string().uri().allow('', null),
  openingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  closingTime: Joi.string().pattern(/^\d{2}:\d{2}$/).allow('', null),
  operatingDays: Joi.array().items(
    Joi.string().valid('Su', 'M', 'T', 'W', 'Th', 'F', 'S')
  ).max(7).allow(null),
  servicesOffered: Joi.array().items(Joi.string().max(100)).max(30).allow(null),
  facebookUrl: Joi.string().uri().max(500).allow('', null),
  instagramUrl: Joi.string().uri().max(500).allow('', null),
  whatsapp: Joi.string().max(50).allow('', null),
  websiteUrl: Joi.string().uri().max(500).allow('', null),
  contentStatus: Joi.string().valid('PENDING'),
});

const bookingCreateSchema = Joi.object({
  providerId: Joi.string().uuid().required(),
  serviceType: Joi.string().valid(
    'LAUNDRY', 'PLUMBER', 'ELECTRICIAN', 'PAINTER', 'CARPENTER',
    'BARBER', 'MAID', 'SALON', 'REAL_ESTATE', 'DOCTOR', 'WATER', 'GAS'
  ).allow(null),
  bookingDate: Joi.date().iso().required(),
  userLatitude: Joi.number().min(-90).max(90).allow(null),
  userLongitude: Joi.number().min(-180).max(180).allow(null),
});

const bookingStatusUpdateSchema = Joi.object({
  status: Joi.string().valid('PENDING', 'ACCEPTED', 'STARTED', 'COMPLETED', 'CANCELLED').required(),
});

const userUpdateSchema = Joi.object({
  name: Joi.string().min(2).max(100),
  email: Joi.string().email().max(200),
  phone: Joi.string().pattern(/^\+?[0-9\-\s]{7,15}$/).allow('', null),
  profilePhotoUrl: Joi.string().uri().max(500).allow('', null),
  bio: Joi.string().max(1000).allow('', null),
  address: Joi.string().max(500).allow('', null),
  country: Joi.string().max(100).allow('', null),
  gender: Joi.string().max(50).allow('', null),
  occupation: Joi.string().max(100).allow('', null),
  dateOfBirth: Joi.date().iso().allow(null),
  locationLat: Joi.number().min(-90).max(90),
  locationLng: Joi.number().min(-180).max(180),
}).min(1);

const notificationPreferencesSchema = Joi.object({
  notifySound: Joi.boolean(),
  notifyVibrate: Joi.boolean(),
  notifyEmailUpdates: Joi.boolean(),
  notifySmsUpdates: Joi.boolean(),
  notifyPushUpdates: Joi.boolean(),
  notifyEmailReminders: Joi.boolean(),
  notifySmsReminders: Joi.boolean(),
  notifyPushReminders: Joi.boolean(),
}).min(1);

const deviceTokenSchema = Joi.object({
  fcmToken: Joi.string().trim().min(10).max(500).required(),
});

const idParamSchema = Joi.object({
  id: Joi.string().uuid().required(),
});

module.exports = {
  paginationSchema,
  serviceProviderQuerySchema,
  serviceSkillSuggestionsQuerySchema,
  businessQuerySchema,
  amenityQuerySchema,
  propertyQuerySchema,
  partnerPropertyCreateSchema,
  reviewSchema,
  searchQuerySchema,
  searchPopularQuerySchema,
  searchSuggestionSchema,
  searchHistorySaveSchema,
  promotionSchema,
  serviceProviderCreateSchema,
  businessCreateSchema,
  amenityCreateSchema,
  bookingCreateSchema,
  bookingStatusUpdateSchema,
  userUpdateSchema,
  notificationPreferencesSchema,
  deviceTokenSchema,
  idParamSchema,
};
