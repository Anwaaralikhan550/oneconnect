const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

async function listOffices(query) {
  const { type, page = 1, limit = 20 } = query;
  const skip = (page - 1) * limit;

  const where = {};
  if (type) where.officeType = type;

  const [data, total] = await Promise.all([
    prisma.adminOffice.findMany({
      where,
      orderBy: { name: 'asc' },
      skip,
      take: limit,
    }),
    prisma.adminOffice.count({ where }),
  ]);

  return {
    data,
    pagination: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

async function getOfficeById(id) {
  const office = await prisma.adminOffice.findUnique({ where: { id } });
  if (!office) throw new AppError('Admin office not found', 404);
  return office;
}

module.exports = { listOffices, getOfficeById };
