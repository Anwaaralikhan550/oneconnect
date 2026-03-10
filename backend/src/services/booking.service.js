const { prisma } = require('../config/database');
const { AppError } = require('../middleware/errorHandler');

const BOOKING_STATUSES = ['PENDING', 'ACCEPTED', 'STARTED', 'COMPLETED', 'CANCELLED'];

async function createBooking(customerId, data) {
  const provider = await prisma.serviceProvider.findUnique({
    where: { id: data.providerId },
    select: {
      id: true,
      serviceType: true,
      contentStatus: true,
      partner: { select: { status: true } },
    },
  });

  if (!provider) throw new AppError('Service provider not found', 404);
  if (
    provider.contentStatus !== 'APPROVED' ||
    (provider.partner && provider.partner.status !== 'APPROVED')
  ) {
    throw new AppError('Provider is not available for booking', 400);
  }

  const requestedType = data.serviceType ? String(data.serviceType).trim().toUpperCase() : null;
  if (requestedType && requestedType !== provider.serviceType) {
    throw new AppError('serviceType does not match provider', 400);
  }

  return prisma.booking.create({
    data: {
      customerId,
      providerId: provider.id,
      serviceType: provider.serviceType,
      status: 'PENDING',
      bookingDate: new Date(data.bookingDate),
      userLatitude: data.userLatitude ?? null,
      userLongitude: data.userLongitude ?? null,
    },
    include: {
      provider: {
        select: {
          id: true,
          name: true,
          serviceType: true,
          phone: true,
          imageUrl: true,
          city: true,
          address: true,
        },
      },
    },
  });
}

async function listMyBookings(actor, query = {}) {
  const status = query.status ? String(query.status).trim().toUpperCase() : null;
  if (status && !BOOKING_STATUSES.includes(status)) {
    throw new AppError(`Invalid status. Must be one of: ${BOOKING_STATUSES.join(', ')}`, 400);
  }

  if (actor.role === 'user') {
    const where = { customerId: actor.id };
    if (status) where.status = status;
    return prisma.booking.findMany({
      where,
      include: {
        provider: {
          select: {
            id: true,
            name: true,
            serviceType: true,
            phone: true,
            imageUrl: true,
            city: true,
            address: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  if (actor.role === 'partner') {
    const where = {
      provider: {
        partnerId: actor.id,
      },
    };
    if (status) where.status = status;
    return prisma.booking.findMany({
      where,
      include: {
        customer: {
          select: {
            id: true,
            name: true,
            email: true,
            phone: true,
            profilePhotoUrl: true,
          },
        },
        provider: {
          select: {
            id: true,
            name: true,
            serviceType: true,
            phone: true,
            imageUrl: true,
          },
        },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  throw new AppError('Unsupported actor role', 403);
}

async function updateBookingStatus(actor, bookingId, nextStatus) {
  const status = String(nextStatus || '').trim().toUpperCase();
  if (!BOOKING_STATUSES.includes(status)) {
    throw new AppError(`Invalid status. Must be one of: ${BOOKING_STATUSES.join(', ')}`, 400);
  }

  const booking = await prisma.booking.findUnique({
    where: { bookingId },
    include: {
      provider: { select: { id: true, partnerId: true } },
    },
  });
  if (!booking) throw new AppError('Booking not found', 404);

  if (actor.role === 'partner') {
    if (!booking.provider || booking.provider.partnerId !== actor.id) {
      throw new AppError('Forbidden', 403);
    }
    const allowedTransitions = {
      PENDING: ['ACCEPTED', 'CANCELLED'],
      ACCEPTED: ['STARTED', 'CANCELLED'],
      STARTED: ['COMPLETED', 'CANCELLED'],
      COMPLETED: [],
      CANCELLED: [],
    };
    const nextAllowed = allowedTransitions[booking.status] || [];
    if (!nextAllowed.includes(status)) {
      throw new AppError(`Invalid transition from ${booking.status} to ${status}`, 400);
    }
  } else if (actor.role === 'user') {
    if (booking.customerId !== actor.id) {
      throw new AppError('Forbidden', 403);
    }
    if (status !== 'CANCELLED') {
      throw new AppError('Users can only cancel bookings', 403);
    }
    if (booking.status === 'COMPLETED' || booking.status === 'CANCELLED') {
      throw new AppError('Booking can no longer be cancelled', 400);
    }
  } else {
    throw new AppError('Unsupported actor role', 403);
  }

  return prisma.booking.update({
    where: { bookingId },
    data: { status },
    include: {
      customer: {
        select: { id: true, name: true, email: true, phone: true, profilePhotoUrl: true },
      },
      provider: {
        select: { id: true, name: true, serviceType: true, phone: true, imageUrl: true },
      },
    },
  });
}

module.exports = {
  createBooking,
  listMyBookings,
  updateBookingStatus,
};
