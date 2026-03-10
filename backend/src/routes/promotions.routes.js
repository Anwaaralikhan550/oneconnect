const { Router } = require('express');
const { prisma } = require('../config/database');

const router = Router();

// Public promotions feed
router.get('/', async (req, res, next) => {
  try {
    const page = parseInt(req.query.page, 10) || 1;
    const limit = Math.min(parseInt(req.query.limit, 10) || 20, 100);
    const skip = (page - 1) * limit;

    const [data, total] = await Promise.all([
      prisma.promotion.findMany({
        where: { isActive: true, contentStatus: 'APPROVED' },
        include: {
          partner: {
            select: { businessName: true, businessId: true, profilePhotoUrl: true },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip,
        take: limit,
      }),
      prisma.promotion.count({ where: { isActive: true, contentStatus: 'APPROVED' } }),
    ]);

    res.json({
      success: true,
      data,
      pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
    });
  } catch (err) {
    next(err);
  }
});

module.exports = router;
