const { v4: uuidv4 } = require('uuid');
const path = require('path');
const fs = require('fs/promises');
const { PutObjectCommand } = require('@aws-sdk/client-s3');
const { getS3Client, getS3Config, buildPublicFileUrl } = require('../config/s3');
const { env } = require('../config/env');
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

function _normalizeBaseUrl(baseUrl) {
  const raw = String(baseUrl || '').trim();
  if (!raw) return null;
  return raw.replace(/\/+$/, '');
}

async function uploadToS3(file, folder, requestBaseUrl) {
  const s3 = getS3Client();
  const config = getS3Config();
  const ext =
    path.extname(file.originalname || '') || extensionFromMimeType(file.mimetype);
  const key = `${folder}/${uuidv4()}${ext}`;

  if (s3 && config) {
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

  const uploadsRoot = path.join(__dirname, '..', '..', 'uploads');
  const diskPath = path.join(uploadsRoot, ...key.split('/'));
  await fs.mkdir(path.dirname(diskPath), { recursive: true });
  await fs.writeFile(diskPath, file.buffer);

  const normalizedBaseUrl =
    _normalizeBaseUrl(requestBaseUrl) ||
    _normalizeBaseUrl(process.env.PUBLIC_BASE_URL) ||
    `http://localhost:${env.PORT}`;
  const fileUrl = `${normalizedBaseUrl}/uploads/${key}`;

  return {
    fileUrl,
    fileName: key,
    fileSizeKb: Math.round((file.size || 0) / 1024),
  };
}

async function uploadPartnerMedia(partnerId, file, mediaType = 'PHOTO', requestBaseUrl) {
  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(
    file,
    'partner-media',
    requestBaseUrl,
  );

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

async function uploadPartnerProfile(partnerId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(file, 'partner-profiles', requestBaseUrl);

  await prisma.partner.update({
    where: { id: partnerId },
    data: { profilePhotoUrl: fileUrl },
  });

  return { fileUrl };
}

async function uploadUserProfile(userId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(file, 'user-profiles', requestBaseUrl);

  await prisma.user.update({
    where: { id: userId },
    data: { profilePhotoUrl: fileUrl },
  });

  return { fileUrl };
}

async function uploadPromotionImage(partnerId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(file, 'promotions', requestBaseUrl);
  return { fileUrl };
}

async function uploadReviewMedia(userId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(file, 'review-media', requestBaseUrl);
  return { fileUrl };
}

async function uploadBusinessImage(partnerId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(file, 'business-images', requestBaseUrl);
  return { fileUrl };
}

async function uploadAmenityImage(partnerId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(file, 'amenity-images', requestBaseUrl);
  return { fileUrl };
}

async function uploadServiceProviderImage(partnerId, file, requestBaseUrl) {
  const { fileUrl } = await uploadToS3(
    file,
    'service-provider-images',
    requestBaseUrl,
  );
  return { fileUrl };
}

async function uploadProviderMedia(
  partnerId,
  serviceProviderId,
  file,
  mediaType = 'PHOTO',
  requestBaseUrl,
) {
  const provider = await prisma.serviceProvider.findFirst({
    where: { id: serviceProviderId, partnerId },
  });
  if (!provider) throw new AppError('Service provider not found', 404);

  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(
    file,
    'provider-media',
    requestBaseUrl,
  );
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

async function uploadBusinessMedia(
  partnerId,
  businessId,
  file,
  mediaType = 'PHOTO',
  requestBaseUrl,
) {
  const business = await prisma.business.findFirst({
    where: { id: businessId, partnerId },
  });
  if (!business) throw new AppError('Business not found', 404);

  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(
    file,
    'business-media',
    requestBaseUrl,
  );
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

async function uploadAmenityMedia(
  partnerId,
  amenityId,
  file,
  mediaType = 'PHOTO',
  requestBaseUrl,
) {
  const amenity = await prisma.amenity.findFirst({
    where: { id: amenityId, partnerId },
  });
  if (!amenity) throw new AppError('Amenity not found', 404);

  const { fileUrl, fileName, fileSizeKb } = await uploadToS3(
    file,
    'amenity-media',
    requestBaseUrl,
  );
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
