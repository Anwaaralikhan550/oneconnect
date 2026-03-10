const SERVICE_SKILL_SUGGESTIONS = {
  LAUNDRY: [
    'Dry cleaning',
    'Steam press',
    'Stain removal',
    'Curtain cleaning',
    'Shoe cleaning',
  ],
  PLUMBER: [
    'Minor leak repair',
    'Major leak repair',
    'Drainage cleaning',
    'Flush and sink repair',
    'Fixture installation',
    'Geyser installation',
    'Pipe repair',
    'Appliances install',
    'Gas line plumbing',
  ],
  ELECTRICIAN: [
    'Wiring and rewiring',
    'Switchboard repair',
    'Fan installation',
    'Circuit breaker fix',
    'Generator troubleshooting',
  ],
  PAINTER: [
    'Interior painting',
    'Exterior painting',
    'Texture paint',
    'Wall putty work',
    'Wood polish',
  ],
  CARPENTER: [
    'Door repair',
    'Cabinet fitting',
    'Furniture assembly',
    'Kitchen woodwork',
    'Bed repair',
  ],
  BARBER: [
    'Hair cut',
    'Beard trim',
    'Hair styling',
    'Head massage',
    'Facial clean-up',
  ],
  MAID: [
    'Deep cleaning',
    'Kitchen cleaning',
    'Laundry and ironing',
    'Baby care',
    'Elderly care',
  ],
  SALON: [
    'Hair styling',
    'Facial treatment',
    'Manicure and pedicure',
    'Makeup service',
    'Waxing',
  ],
  REAL_ESTATE: [
    'Property buying',
    'Property selling',
    'Rental assistance',
    'Commercial listings',
    'Property valuation',
  ],
  DOCTOR: [
    'General consultation',
    'Follow-up checkup',
    'Prescription review',
    'Health screening',
    'Second opinion',
  ],
  WATER: [
    'Water tanker delivery',
    'Water filter installation',
    'RO maintenance',
    'Water quality testing',
    'Tank cleaning',
  ],
  GAS: [
    'Gas leak repair',
    'Gas pipeline fitting',
    'Geyser service',
    'Regulator replacement',
    'Safety inspection',
  ],
};

function getSkillSuggestionsByType(type) {
  const key = String(type || '').trim().toUpperCase();
  return SERVICE_SKILL_SUGGESTIONS[key] || [];
}

module.exports = {
  SERVICE_SKILL_SUGGESTIONS,
  getSkillSuggestionsByType,
};
