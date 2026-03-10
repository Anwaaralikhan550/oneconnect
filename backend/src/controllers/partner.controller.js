const partnerService = require('../services/partner.service');

async function register(req, res, next) {
  try {
    const result = await partnerService.register(req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function login(req, res, next) {
  try {
    const result = await partnerService.login(req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function refresh(req, res, next) {
  try {
    const result = await partnerService.refresh(req.body.refreshToken);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function forgotPassword(req, res, next) {
  try {
    const result = await partnerService.forgotPassword(
      req.body.businessId,
      req.body.redirectUrl
    );
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function resetPassword(req, res, next) {
  try {
    const result = await partnerService.resetPassword(
      req.body.token,
      req.body.newPassword
    );
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function logout(req, res, next) {
  try {
    await partnerService.logout(req.partner?.id, req.body.refreshToken);
    res.json({ success: true, data: { message: 'Logged out' } });
  } catch (err) {
    next(err);
  }
}

async function getProfile(req, res, next) {
  try {
    const result = await partnerService.getProfile(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateProfile(req, res, next) {
  try {
    const result = await partnerService.updateProfile(req.partner.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updatePhones(req, res, next) {
  try {
    const result = await partnerService.updatePhones(req.partner.id, req.body.phones);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function getPromotions(req, res, next) {
  try {
    const result = await partnerService.getPromotions(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function createPromotion(req, res, next) {
  try {
    const result = await partnerService.createPromotion(req.partner.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updatePromotion(req, res, next) {
  try {
    const result = await partnerService.updatePromotion(req.partner.id, req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deletePromotion(req, res, next) {
  try {
    await partnerService.deletePromotion(req.partner.id, req.params.id);
    res.json({ success: true, data: { message: 'Promotion deleted' } });
  } catch (err) {
    next(err);
  }
}

// Service Providers
async function getServiceProviders(req, res, next) {
  try {
    const result = await partnerService.getServiceProviders(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function createServiceProvider(req, res, next) {
  try {
    const result = await partnerService.createServiceProvider(req.partner.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateServiceProvider(req, res, next) {
  try {
    const result = await partnerService.updateServiceProvider(req.partner.id, req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteServiceProvider(req, res, next) {
  try {
    await partnerService.deleteServiceProvider(req.partner.id, req.params.id);
    res.json({ success: true, data: { message: 'Service provider deleted' } });
  } catch (err) {
    next(err);
  }
}

// Businesses
async function getBusinesses(req, res, next) {
  try {
    const result = await partnerService.getBusinesses(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function createBusiness(req, res, next) {
  try {
    const result = await partnerService.createBusiness(req.partner.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateBusiness(req, res, next) {
  try {
    const result = await partnerService.updateBusiness(req.partner.id, req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteBusiness(req, res, next) {
  try {
    await partnerService.deleteBusiness(req.partner.id, req.params.id);
    res.json({ success: true, data: { message: 'Business deleted' } });
  } catch (err) {
    next(err);
  }
}

async function getServiceProviderMedia(req, res, next) {
  try {
    const result = await partnerService.getServiceProviderMedia(req.partner.id, req.params.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteServiceProviderMedia(req, res, next) {
  try {
    await partnerService.deleteServiceProviderMedia(req.partner.id, req.params.mediaId);
    res.json({ success: true, data: { message: 'Media deleted' } });
  } catch (err) {
    next(err);
  }
}

async function deleteBusinessMedia(req, res, next) {
  try {
    await partnerService.deleteBusinessMedia(req.partner.id, req.params.mediaId);
    res.json({ success: true, data: { message: 'Media deleted' } });
  } catch (err) {
    next(err);
  }
}

async function deleteAmenityMedia(req, res, next) {
  try {
    await partnerService.deleteAmenityMedia(req.partner.id, req.params.mediaId);
    res.json({ success: true, data: { message: 'Media deleted' } });
  } catch (err) {
    next(err);
  }
}

// Properties
async function getProperties(req, res, next) {
  try {
    const result = await partnerService.getProperties(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function createProperty(req, res, next) {
  try {
    const result = await partnerService.createProperty(req.partner.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateProperty(req, res, next) {
  try {
    const result = await partnerService.updateProperty(req.partner.id, req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteProperty(req, res, next) {
  try {
    await partnerService.deleteProperty(req.partner.id, req.params.id);
    res.json({ success: true, data: { message: 'Property deleted' } });
  } catch (err) {
    next(err);
  }
}

// Amenities
async function getAmenities(req, res, next) {
  try {
    const result = await partnerService.getAmenities(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function createAmenity(req, res, next) {
  try {
    const result = await partnerService.createAmenity(req.partner.id, req.body);
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function updateAmenity(req, res, next) {
  try {
    const result = await partnerService.updateAmenity(req.partner.id, req.params.id, req.body);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteAmenity(req, res, next) {
  try {
    await partnerService.deleteAmenity(req.partner.id, req.params.id);
    res.json({ success: true, data: { message: 'Amenity deleted' } });
  } catch (err) {
    next(err);
  }
}

async function getMedia(req, res, next) {
  try {
    const result = await partnerService.getMedia(req.partner.id);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function deleteMedia(req, res, next) {
  try {
    await partnerService.deleteMedia(req.partner.id, req.params.id);
    res.json({ success: true, data: { message: 'Media deleted' } });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  register,
  login,
  refresh,
  forgotPassword,
  resetPassword,
  logout,
  getProfile,
  updateProfile,
  updatePhones,
  getPromotions,
  createPromotion,
  updatePromotion,
  deletePromotion,
  getServiceProviders,
  createServiceProvider,
  updateServiceProvider,
  deleteServiceProvider,
  getServiceProviderMedia,
  deleteServiceProviderMedia,
  deleteBusinessMedia,
  deleteAmenityMedia,
  getBusinesses,
  createBusiness,
  updateBusiness,
  deleteBusiness,
  getProperties,
  createProperty,
  updateProperty,
  deleteProperty,
  getAmenities,
  createAmenity,
  updateAmenity,
  deleteAmenity,
  getMedia,
  deleteMedia,
};
