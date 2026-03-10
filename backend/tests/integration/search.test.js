const request = require('supertest');
const app = require('../../src/app');
const { prisma, cleanDatabase } = require('../setup');

describe('Search API', () => {
  let userToken;

  beforeAll(async () => {
    await cleanDatabase();

    // Seed some searchable data
    const cat = await prisma.serviceCategory.create({
      data: { name: 'Electrician', slug: 'electrician', sortOrder: 1 },
    });

    await prisma.serviceProvider.create({
      data: {
        name: 'Baber M Rizwan',
        categoryId: cat.id,
        serviceType: 'ELECTRICIAN',
        rating: 4.8,
        city: 'Lahore',
        isTopRated: true,
        skills: {
          create: [{ tagName: 'Wiring' }, { tagName: 'LED Installation' }],
        },
      },
    });

    await prisma.business.create({
      data: {
        name: 'Al-Fatah Store',
        category: 'STORE',
        rating: 4.5,
        location: 'Gulberg, Lahore',
      },
    });

    await prisma.amenity.create({
      data: {
        name: 'Badshahi Mosque',
        amenityType: 'MASJID',
        rating: 4.9,
      },
    });

    // Create user for authenticated endpoints
    const res = await request(app)
      .post('/api/v1/auth/register')
      .send({
        name: 'Search User',
        email: 'search@test.com',
        password: 'Password123!',
      });
    userToken = res.body.data.accessToken;
  });

  afterAll(async () => {
    await cleanDatabase();
    await prisma.$disconnect();
  });

  describe('GET /api/v1/search', () => {
    it('should search across services', async () => {
      const res = await request(app)
        .get('/api/v1/search?q=Baber');

      expect(res.status).toBe(200);
      expect(res.body.data.serviceProviders.length).toBeGreaterThan(0);
    });

    it('should search businesses', async () => {
      const res = await request(app)
        .get('/api/v1/search?q=Al-Fatah&category=Shop');

      expect(res.status).toBe(200);
      expect(res.body.data.businesses.length).toBeGreaterThan(0);
    });

    it('should return empty for no matches', async () => {
      const res = await request(app)
        .get('/api/v1/search?q=zzznonexistent');

      expect(res.status).toBe(200);
      expect(res.body.data.serviceProviders.length).toBe(0);
      expect(res.body.data.businesses.length).toBe(0);
    });

    it('should require query parameter', async () => {
      const res = await request(app)
        .get('/api/v1/search');

      expect(res.status).toBe(400);
    });
  });

  describe('GET /api/v1/search/suggestions', () => {
    it('should return suggestions', async () => {
      const res = await request(app)
        .get('/api/v1/search/suggestions?q=Ba');

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });
  });

  describe('GET /api/v1/search/popular', () => {
    it('should return popular services and businesses', async () => {
      const res = await request(app)
        .get('/api/v1/search/popular');

      expect(res.status).toBe(200);
      expect(res.body.data.topServices).toBeDefined();
      expect(res.body.data.topBusinesses).toBeDefined();
    });
  });

  describe('Search History', () => {
    it('should save search history', async () => {
      const res = await request(app)
        .post('/api/v1/search/history')
        .set('Authorization', `Bearer ${userToken}`)
        .send({ query: 'electrician', category: 'Service' });

      expect(res.status).toBe(201);
    });

    it('should get search history', async () => {
      const res = await request(app)
        .get('/api/v1/search/history')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
      expect(res.body.data.length).toBeGreaterThan(0);
    });

    it('should delete search history', async () => {
      const res = await request(app)
        .delete('/api/v1/search/history')
        .set('Authorization', `Bearer ${userToken}`);

      expect(res.status).toBe(200);
    });
  });
});

