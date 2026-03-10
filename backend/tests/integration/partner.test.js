const request = require('supertest');
const app = require('../../src/app');
const { prisma, cleanDatabase } = require('../setup');

describe('Partner API', () => {
  beforeEach(async () => {
    await cleanDatabase();
  });

  afterAll(async () => {
    await cleanDatabase();
    await prisma.$disconnect();
  });

  describe('POST /api/v1/partner/register', () => {
    it('should register a new partner with auto-generated businessId', async () => {
      const res = await request(app)
        .post('/api/v1/partner/register')
        .send({
          businessName: 'Test Electric Shop',
          ownerFullName: 'Muhammad Ali',
          businessEmail: 'testpartner@example.com',
          password: 'Partner123!',
          businessType: 'SERVICE_PROVIDER',
          address: '123 Main Street',
          area: 'Gulberg',
          city: 'Lahore',
          phones: [
            { phoneNumber: '3001234567', countryCode: '+92', isPrimary: true },
          ],
          operatingDays: ['M', 'T', 'W', 'Th', 'F'],
        });

      expect(res.status).toBe(201);
      expect(res.body.success).toBe(true);
      expect(res.body.data.partner.businessId).toMatch(/^OC-\d{4}-\d{5}$/);
      expect(res.body.data.partner.status).toBe('PENDING_REVIEW');
    });

    it('should reject duplicate business email', async () => {
      await request(app)
        .post('/api/v1/partner/register')
        .send({
          businessName: 'First Shop',
          ownerFullName: 'Ali',
          businessEmail: 'partner@test.com',
          password: 'Partner123!',
          businessType: 'RETAIL_STORE',
        });

      const res = await request(app)
        .post('/api/v1/partner/register')
        .send({
          businessName: 'Second Shop',
          ownerFullName: 'Ahmed',
          businessEmail: 'partner@test.com',
          password: 'Partner456!',
          businessType: 'RETAIL_STORE',
        });

      expect(res.status).toBe(409);
    });
  });

  describe('POST /api/v1/partner/login', () => {
    let businessId;

    beforeEach(async () => {
      const res = await request(app)
        .post('/api/v1/partner/register')
        .send({
          businessName: 'Login Test Shop',
          ownerFullName: 'Ali Khan',
          businessEmail: 'loginpartner@test.com',
          password: 'Partner123!',
          businessType: 'SERVICE_PROVIDER',
        });

      businessId = res.body.data.partner.businessId;

      // Approve the partner for login
      await prisma.partner.update({
        where: { businessId },
        data: { status: 'APPROVED' },
      });
    });

    it('should login with businessId and password', async () => {
      const res = await request(app)
        .post('/api/v1/partner/login')
        .send({
          businessId,
          password: 'Partner123!',
        });

      expect(res.status).toBe(200);
      expect(res.body.data.partner.businessId).toBe(businessId);
      expect(res.body.data.accessToken).toBeDefined();
      expect(res.body.data.refreshToken).toBeDefined();
    });

    it('should reject wrong password', async () => {
      const res = await request(app)
        .post('/api/v1/partner/login')
        .send({
          businessId,
          password: 'wrongpassword',
        });

      expect(res.status).toBe(401);
    });
  });

  describe('GET /api/v1/partner/me', () => {
    it('should return partner profile when authenticated', async () => {
      // Register and approve partner
      const regRes = await request(app)
        .post('/api/v1/partner/register')
        .send({
          businessName: 'Profile Test Shop',
          ownerFullName: 'Ali',
          businessEmail: 'profile@test.com',
          password: 'Partner123!',
          businessType: 'SERVICE_PROVIDER',
        });

      const businessId = regRes.body.data.partner.businessId;
      await prisma.partner.update({
        where: { businessId },
        data: { status: 'APPROVED' },
      });

      // Login
      const loginRes = await request(app)
        .post('/api/v1/partner/login')
        .send({ businessId, password: 'Partner123!' });

      const token = loginRes.body.data.accessToken;

      // Get profile
      const res = await request(app)
        .get('/api/v1/partner/me')
        .set('Authorization', `Bearer ${token}`);

      expect(res.status).toBe(200);
      expect(res.body.data.businessName).toBe('Profile Test Shop');
      expect(res.body.data.passwordHash).toBeUndefined();
    });
  });

  describe('Partner Password Reset Flow', () => {
    it('should reset partner password with token from forgot-password flow', async () => {
      const regRes = await request(app)
        .post('/api/v1/partner/register')
        .send({
          businessName: 'Reset Shop',
          ownerFullName: 'Reset Owner',
          businessEmail: 'partner-reset@test.com',
          password: 'Partner123!',
          businessType: 'SERVICE_PROVIDER',
        });

      const businessId = regRes.body.data.partner.businessId;

      const logs = [];
      const logSpy = jest.spyOn(console, 'log').mockImplementation((...args) => {
        logs.push(args.join(' '));
      });

      const forgotRes = await request(app)
        .post('/api/v1/partner/forgot-password')
        .send({ businessId });

      expect(forgotRes.status).toBe(200);
      expect(forgotRes.body.success).toBe(true);

      logSpy.mockRestore();
      const linkLine = logs.find((line) => line.includes('[PARTNER_PASSWORD_RESET_LINK]'));
      expect(linkLine).toBeDefined();

      const tokenMatch = linkLine.match(/[?&]token=([^&\s]+)/);
      expect(tokenMatch).toBeDefined();
      const token = decodeURIComponent(tokenMatch[1]);

      const resetRes = await request(app)
        .post('/api/v1/partner/reset-password')
        .send({
          token,
          newPassword: 'PartnerNew123!',
        });
      expect(resetRes.status).toBe(200);
      expect(resetRes.body.success).toBe(true);

      await prisma.partner.update({
        where: { businessId },
        data: { status: 'APPROVED' },
      });

      const oldLoginRes = await request(app)
        .post('/api/v1/partner/login')
        .send({ businessId, password: 'Partner123!' });
      expect(oldLoginRes.status).toBe(401);

      const newLoginRes = await request(app)
        .post('/api/v1/partner/login')
        .send({ businessId, password: 'PartnerNew123!' });
      expect(newLoginRes.status).toBe(200);
      expect(newLoginRes.body.success).toBe(true);
    });
  });
});

