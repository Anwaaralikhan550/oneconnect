const { prisma } = require('../config/database');

const BOOKING_STATUSES = ['PENDING', 'ACCEPTED', 'STARTED', 'COMPLETED', 'CANCELLED'];

function parsePagination(query) {
  const page = Math.max(1, parseInt(query.page, 10) || 1);
  const limit = Math.min(100, Math.max(1, parseInt(query.limit, 10) || 20));
  return { page, limit, skip: (page - 1) * limit };
}

function getDateRange(scope) {
  if (scope !== 'today') return {};

  const start = new Date();
  start.setHours(0, 0, 0, 0);

  const end = new Date(start);
  end.setDate(end.getDate() + 1);

  return {
    createdAt: {
      gte: start,
      lt: end,
    },
  };
}

async function getBookingStats(query = {}) {
  const scope = query.scope === 'all' ? 'all' : 'today';
  const { page, limit, skip } = parsePagination(query);
  const where = getDateRange(scope);

  const todayWhere = getDateRange('today');

  const [
    totalBookingsToday,
    totalFiltered,
    statusGroups,
    bookings,
  ] = await Promise.all([
    prisma.booking.count({ where: todayWhere }),
    prisma.booking.count({ where }),
    prisma.booking.groupBy({
      by: ['status'],
      where,
      _count: { status: true },
    }),
    prisma.booking.findMany({
      where,
      include: {
        customer: { select: { id: true, name: true } },
        provider: { select: { id: true, name: true, serviceType: true } },
      },
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
    }),
  ]);

  const statusCounts = BOOKING_STATUSES.reduce((acc, status) => {
    acc[status] = 0;
    return acc;
  }, {});

  for (const row of statusGroups) {
    statusCounts[row.status] = row._count.status;
  }

  const data = bookings.map((booking) => ({
    bookingId: booking.bookingId,
    status: booking.status,
    serviceType: booking.serviceType,
    bookingDate: booking.bookingDate,
    createdAt: booking.createdAt,
    customer: booking.customer,
    provider: booking.provider,
    userLatitude: booking.userLatitude,
    userLongitude: booking.userLongitude,
  }));

  return {
    scope,
    totalBookingsToday,
    totalBookings: totalFiltered,
    statusCounts,
    bookings: data,
    pagination: {
      page,
      limit,
      total: totalFiltered,
      totalPages: Math.ceil(totalFiltered / limit),
    },
  };
}

module.exports = {
  getBookingStats,
};
