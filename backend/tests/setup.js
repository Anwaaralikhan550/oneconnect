const { PrismaClient } = require('@prisma/client');

const prisma = new PrismaClient();

// Set test environment variables
process.env.NODE_ENV = 'test';
process.env.JWT_SECRET = 'test-jwt-secret-key-must-be-at-least-32-characters-long!!';
process.env.JWT_REFRESH_SECRET = 'test-refresh-secret-key-must-be-at-least-32-characters!!';
process.env.JWT_EXPIRES_IN = '15m';
process.env.JWT_REFRESH_EXPIRES_IN = '7d';
process.env.CORS_ORIGIN = 'http://localhost:3000';
process.env.ALLOW_PLAINTEXT_RESET_LOGS = 'true';

/**
 * Clean all tables in correct order (respecting FK constraints).
 */
async function cleanDatabase() {
  const tablenames = [
    'partner_refresh_tokens',
    'refresh_tokens',
    'notifications',
    'search_history',
    'favorites',
    'reviews',
    'property_images',
    'properties',
    'promotions',
    'provider_media',
    'business_media',
    'amenity_media',
    'service_provider_skills',
    'service_providers',
    'partner_categories',
    'partner_media',
    'partner_operating_days',
    'partner_phones',
    'businesses',
    'amenities',
    'admin_offices',
    'partners',
    'users',
    'service_categories',
  ];

  for (const table of tablenames) {
    try {
      await prisma.$executeRawUnsafe(`DELETE FROM "${table}"`);
    } catch (e) {
      // Table might not exist yet
    }
  }
}

module.exports = { prisma, cleanDatabase };

