const { prisma } = require('../config/database');

async function list(req, res, next) {
  try {
    const rows = await prisma.locationMaster.findMany({
      where: { isActive: true },
      orderBy: [{ city: 'asc' }, { sortOrder: 'asc' }, { area: 'asc' }],
      select: { country: true, city: true, area: true },
    });

    const grouped = {};
    for (const row of rows) {
      if (!grouped[row.city]) {
        grouped[row.city] = [];
      }
      grouped[row.city].push(row.area);
    }

    res.json({ success: true, data: grouped });
  } catch (err) {
    next(err);
  }
}

module.exports = { list };
