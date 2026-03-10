const { S3Client } = require('@aws-sdk/client-s3');

let s3Client = null;
let cachedConfig = null;

function getS3Config() {
  if (cachedConfig) return cachedConfig;

  const config = {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
    region: process.env.AWS_REGION,
    bucket: process.env.AWS_S3_BUCKET,
    publicBaseUrl: process.env.AWS_S3_PUBLIC_BASE_URL,
  };

  if (
    !config.accessKeyId ||
    !config.secretAccessKey ||
    !config.region ||
    !config.bucket
  ) {
    return null;
  }

  cachedConfig = config;
  return cachedConfig;
}

function getS3Client() {
  const config = getS3Config();
  if (!config) return null;

  if (!s3Client) {
    s3Client = new S3Client({
      region: config.region,
      credentials: {
        accessKeyId: config.accessKeyId,
        secretAccessKey: config.secretAccessKey,
      },
    });
  }

  return s3Client;
}

function buildPublicFileUrl(key) {
  const config = getS3Config();
  if (!config) return null;

  if (config.publicBaseUrl) {
    return `${config.publicBaseUrl.replace(/\/+$/, '')}/${key}`;
  }

  return `https://${config.bucket}.s3.${config.region}.amazonaws.com/${key}`;
}

module.exports = {
  getS3Config,
  getS3Client,
  buildPublicFileUrl,
};
