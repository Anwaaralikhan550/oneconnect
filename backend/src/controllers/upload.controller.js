const uploadService = require('../services/upload.service');

async function uploadPartnerMedia(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadPartnerMedia(
      req.partner.id,
      req.file,
      req.body.mediaType || 'PHOTO'
    );
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadPartnerProfile(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadPartnerProfile(req.partner.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadPromotionImage(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadPromotionImage(req.partner.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadUserProfile(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadUserProfile(req.user.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadReviewMedia(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadReviewMedia(req.user.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadBusinessImage(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadBusinessImage(req.partner.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadAmenityImage(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadAmenityImage(req.partner.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadServiceProviderImage(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const result = await uploadService.uploadServiceProviderImage(req.partner.id, req.file);
    res.json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadProviderMedia(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const serviceProviderId = req.body.serviceProviderId;
    if (!serviceProviderId) {
      return res.status(400).json({ success: false, error: 'serviceProviderId is required' });
    }
    const result = await uploadService.uploadProviderMedia(
      req.partner.id,
      serviceProviderId,
      req.file,
      req.body.mediaType || 'PHOTO'
    );
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadBusinessMedia(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const businessId = req.body.businessId;
    if (!businessId) {
      return res.status(400).json({ success: false, error: 'businessId is required' });
    }
    const result = await uploadService.uploadBusinessMedia(
      req.partner.id,
      businessId,
      req.file,
      req.body.mediaType || 'PHOTO'
    );
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

async function uploadAmenityMedia(req, res, next) {
  try {
    if (!req.file) {
      return res.status(400).json({ success: false, error: 'No file provided' });
    }
    const amenityId = req.body.amenityId;
    if (!amenityId) {
      return res.status(400).json({ success: false, error: 'amenityId is required' });
    }
    const result = await uploadService.uploadAmenityMedia(
      req.partner.id,
      amenityId,
      req.file,
      req.body.mediaType || 'PHOTO'
    );
    res.status(201).json({ success: true, data: result });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  uploadPartnerMedia,
  uploadPartnerProfile,
  uploadPromotionImage,
  uploadUserProfile,
  uploadReviewMedia,
  uploadBusinessImage,
  uploadAmenityImage,
  uploadServiceProviderImage,
  uploadProviderMedia,
  uploadBusinessMedia,
  uploadAmenityMedia,
};
