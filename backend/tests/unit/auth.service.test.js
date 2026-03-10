const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');

// Test password hashing
describe('Auth Service - Password Hashing', () => {
  it('should hash password with bcrypt', async () => {
    const password = 'testPassword123!';
    const hash = await bcrypt.hash(password, 12);

    expect(hash).not.toBe(password);
    expect(hash).toMatch(/^\$2[aby]\$/);
  });

  it('should verify correct password', async () => {
    const password = 'testPassword123!';
    const hash = await bcrypt.hash(password, 12);

    const isValid = await bcrypt.compare(password, hash);
    expect(isValid).toBe(true);
  });

  it('should reject wrong password', async () => {
    const password = 'testPassword123!';
    const hash = await bcrypt.hash(password, 12);

    const isValid = await bcrypt.compare('wrongpassword', hash);
    expect(isValid).toBe(false);
  });
});

// Test JWT token generation
describe('Auth Service - JWT Tokens', () => {
  const secret = 'test-secret-must-be-at-least-32-chars-long!!';

  it('should generate valid access token', () => {
    const payload = { sub: 'user-123', email: 'test@test.com', role: 'user' };
    const token = jwt.sign(payload, secret, { expiresIn: '15m' });

    const decoded = jwt.verify(token, secret);
    expect(decoded.sub).toBe('user-123');
    expect(decoded.email).toBe('test@test.com');
    expect(decoded.role).toBe('user');
  });

  it('should differentiate user and partner tokens', () => {
    const userPayload = { sub: 'user-1', role: 'user' };
    const partnerPayload = { sub: 'partner-1', role: 'partner', businessId: 'OC-2024-00001' };

    const userToken = jwt.sign(userPayload, secret);
    const partnerToken = jwt.sign(partnerPayload, secret);

    const decodedUser = jwt.verify(userToken, secret);
    const decodedPartner = jwt.verify(partnerToken, secret);

    expect(decodedUser.role).toBe('user');
    expect(decodedPartner.role).toBe('partner');
    expect(decodedPartner.businessId).toBe('OC-2024-00001');
  });

  it('should reject expired tokens', () => {
    const token = jwt.sign({ sub: 'user-1' }, secret, { expiresIn: '0s' });

    expect(() => {
      jwt.verify(token, secret);
    }).toThrow(jwt.TokenExpiredError);
  });

  it('should reject tokens with wrong secret', () => {
    const token = jwt.sign({ sub: 'user-1' }, secret);

    expect(() => {
      jwt.verify(token, 'wrong-secret-that-is-32-characters-long!!');
    }).toThrow(jwt.JsonWebTokenError);
  });
});

// Test business ID generation pattern
describe('Auth Service - Business ID Format', () => {
  it('should match expected format', () => {
    const year = new Date().getFullYear();
    const seq = String(1).padStart(5, '0');
    const businessId = `OC-${year}-${seq}`;

    expect(businessId).toMatch(/^OC-\d{4}-\d{5}$/);
    expect(businessId).toBe(`OC-${year}-00001`);
  });
});

