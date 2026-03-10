function asNumber(value) {
  if (typeof value === 'number' && Number.isFinite(value)) return value;
  if (typeof value === 'string') {
    const parsed = Number(value.trim());
    return Number.isFinite(parsed) ? parsed : null;
  }
  return null;
}

function parseLatLng(value) {
  if (!value) return { latitude: null, longitude: null };

  if (typeof value === 'object' && !Array.isArray(value)) {
    const latitude = asNumber(value.latitude ?? value.lat ?? value.locationLat);
    const longitude = asNumber(value.longitude ?? value.lng ?? value.locationLng);
    if (latitude != null && longitude != null) {
      return { latitude, longitude };
    }

    const coordinates = value.coordinates;
    if (Array.isArray(coordinates) && coordinates.length >= 2) {
      const lng = asNumber(coordinates[0]);
      const lat = asNumber(coordinates[1]);
      if (lat != null && lng != null) {
        return { latitude: lat, longitude: lng };
      }
    }
  }

  if (typeof value === 'string') {
    const match = value.trim().match(
      /^(-?\d+(?:\.\d+)?)\s*,\s*(-?\d+(?:\.\d+)?)$/,
    );
    if (match) {
      return {
        latitude: Number(match[1]),
        longitude: Number(match[2]),
      };
    }
  }

  return { latitude: null, longitude: null };
}

function toRadians(value) {
  return (value * Math.PI) / 180;
}

function haversineKm(lat1, lng1, lat2, lng2) {
  const R = 6371;
  const dLat = toRadians(lat2 - lat1);
  const dLng = toRadians(lng2 - lng1);
  const a =
    Math.sin(dLat / 2) * Math.sin(dLat / 2) +
    Math.cos(toRadians(lat1)) *
      Math.cos(toRadians(lat2)) *
      Math.sin(dLng / 2) *
      Math.sin(dLng / 2);
  const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
  return R * c;
}

function normalizeFilterQuery(query = {}) {
  const page = Math.max(1, Number(query.page || 1));
  const limit = Math.min(100, Math.max(1, Number(query.limit || 20)));
  return {
    page,
    limit,
    minRating: asNumber(query.minRating),
    locationMode: query.locationMode || null,
    area: (query.area || query.city || '').toString().trim() || null,
    latitude: asNumber(query.latitude),
    longitude: asNumber(query.longitude),
    radiusKm: asNumber(query.radiusKm) || 25,
    sortBy: query.sortBy || null,
    priceTier: query.priceTier || null,
    entityType: query.entityType || null,
  };
}

function applyDistanceFilterAndSort(items, filter, locationGetter) {
  const shouldDistanceFilter =
    filter.locationMode === 'DISTANCE' &&
    filter.latitude != null &&
    filter.longitude != null;

  const enriched = items.map((item) => {
    const { latitude, longitude } = locationGetter(item);
    const distanceKm =
      shouldDistanceFilter && latitude != null && longitude != null
        ? haversineKm(filter.latitude, filter.longitude, latitude, longitude)
        : null;
    return { ...item, latitude, longitude, distanceKm };
  });

  if (shouldDistanceFilter) {
    const withinRadius = enriched.filter(
      (item) => item.distanceKm != null && item.distanceKm <= filter.radiusKm,
    );
    withinRadius.sort((a, b) => (a.distanceKm || 999999) - (b.distanceKm || 999999));
    return withinRadius;
  }

  if (filter.sortBy === 'NEAR_ME' && filter.latitude != null && filter.longitude != null) {
    const sorted = [...enriched];
    sorted.sort((a, b) => (a.distanceKm || 999999) - (b.distanceKm || 999999));
    return sorted;
  }

  return enriched;
}

module.exports = {
  asNumber,
  parseLatLng,
  haversineKm,
  normalizeFilterQuery,
  applyDistanceFilterAndSort,
};
