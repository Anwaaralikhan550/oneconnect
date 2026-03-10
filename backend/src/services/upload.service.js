const { v4: uuidv4 } = require('uuid');
const path = require('path');
const { PutObjectCommand } = require('@aws-sdk/client-s3');
const { getS3Client, getS3Config, buildPublicFileUrl } = require('../config/s3');
const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

function extensionFromMimeType(mimeType) {
  switch (mimeType) {
    case 'image/jpeg':
      return '.jpg';
    case 'image/png':
      return '.png';
    case 'image/webp':
      return '.webp';
    case 'image/gif':
      return '.gif';
    case 'video/mp4':
      return '.mp4';
    default:
      return '';
  }
}

async function uploadToS3(file, folder) {
  const s3 = getS3Client();
  const config = getS3Config();
  if (!s3 || !config) {
    throw new AppError('File upload not available (S3 not configured)', 503);
  }

  const ext =
    path.extname(file.originalname || '') || extensionFromMimeType(file.mimetype);
  const key = `${folder}/${uuidv4()}${ext}`;

  await s3.send(
    new PutObjectCommand({
      Bucket: config.bucket,
      Key: key,
      Body: file.buffer,
      ContentType: file.mimetype,
    })
  );

  const fileUrl = buildPublicFileUrl(key);
  if (!fileUrl) {
    throw new AppError('Failed to resolve uploaded file URL', 500);
  }

  return {
    fileUrl,
    fileName: key,
    fileSizeKb: Math.round((file.size || 0) / 1024),
  };
}

async function uploadPartnerMedia(partnerId, file, mediaType = 'PHOTO') {
  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(file, 'partner-media');

  return prisma.partnerMedia.create({
    data: {
      partnerId,
      mediaType,
      fileUrl,
      fileName,
      fileSizeKb,
    },
  });
}

async function uploadPartnerProfile(partnerId, file) {
  const { fileUrl } = await uploadToS3(file, 'partner-profiles');

  await prisma.partner.update({
    where: { id: partnerId },
    data: { profilePhotoUrl: fileUrl },
  });

  return { fileUrl };
}

async function uploadUserProfile(userId, file) {
  const { fileUrl } = await uploadToS3(file, 'user-profiles');

  await prisma.user.update({
    where: { id: userId },
    data: { profilePhotoUrl: fileUrl },
  });

  return { fileUrl };
}

async function uploadPromotionImage(partnerId, file) {
  const { fileUrl } = await uploadToS3(file, 'promotions');
  return { fileUrl };
}

async function uploadReviewMedia(userId, file) {
  const { fileUrl } = await uploadToS3(file, 'review-media');
  return { fileUrl };
}

async function uploadBusinessImage(partnerId, file) {
  const { fileUrl } = await uploadToS3(file, 'business-images');
  return { fileUrl };
}

async function uploadAmenityImage(partnerId, file) {
  const { fileUrl } = await uploadToS3(file, 'amenity-images');
  return { fileUrl };
}

async function uploadServiceProviderImage(partnerId, file) {
  const { fileUrl } = await uploadToS3(file, 'service-provider-images');
  return { fileUrl };
}

async function uploadProviderMedia(partnerId, serviceProviderId, file, mediaType = 'PHOTO') {
  const provider = await prisma.serviceProvider.findFirst({
    where: { id: serviceProviderId, partnerId },
  });
  if (!provider) throw new AppError('Service provider not found', 404);

  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(file, 'provider-media');
  return prisma.providerMedia.create({
    data: {
      serviceProviderId,
      mediaType,
      fileUrl,
      fileName,
      fileSizeKb,
    },
  });
}

async function uploadBusinessMedia(partnerId, businessId, file, mediaType = 'PHOTO') {
  const business = await prisma.business.findFirst({
    where: { id: businessId, partnerId },
  });
  if (!business) throw new AppError('Business not found', 404);

  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(file, 'business-media');
  return prisma.businessMedia.create({
    data: {
      businessId,
      mediaType,
      fileUrl,
      fileName,
      fileSizeKb,
    },
  });
}

async function uploadAmenityMedia(partnerId, amenityId, file, mediaType = 'PHOTO') {
  const amenity = await prisma.amenity.findFirst({
    where: { id: amenityId, partnerId },
  });
  if (!amenity) throw new AppError('Amenity not found', 404);

  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(file, 'amenity-media');
  return prisma.amenityMedia.create({
    data: {
      amenityId,
      mediaType,
      fileUrl,
      fileName,
      fileSizeKb,
    },
  });
}

module.exports = {
  uploadPartnerMedia,
  uploadPartnerProfile,
  uploadUserProfile,
  uploadPromotionImage,
  uploadReviewMedia,
  uploadBusinessImage,
  uploadAmenityImage,
  uploadServiceProviderImage,
  uploadProviderMedia,
  uploadBusinessMedia,
  uploadAmenityMedia,
};
