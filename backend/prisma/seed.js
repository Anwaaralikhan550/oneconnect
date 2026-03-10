const { PrismaClient } = require('@prisma/client');
const bcrypt = require('bcryptjs');

const prisma = new PrismaClient();

async function tableExists(tableName) {
  const result = await prisma.$queryRawUnsafe(
    `SELECT EXISTS (
      SELECT 1
      FROM information_schema.tables
      WHERE table_schema = 'public' AND table_name = $1
    ) AS "exists"`,
    tableName,
  );
  return result?.[0]?.exists === true;
}

const SERVICE_CATEGORIES = [
  { name: 'Laundry', slug: 'laundry', sortOrder: 1 },
  { name: 'Plumber', slug: 'plumber', sortOrder: 2 },
  { name: 'Electrician', slug: 'electrician', sortOrder: 3 },
  { name: 'Painter', slug: 'painter', sortOrder: 4 },
  { name: 'Carpenter', slug: 'carpenter', sortOrder: 5 },
  { name: 'Barber', slug: 'barber', sortOrder: 6 },
  { name: 'Maid', slug: 'maid', sortOrder: 7 },
  { name: 'Salon', slug: 'salon', sortOrder: 8 },
  { name: 'Real Estate', slug: 'real-estate', sortOrder: 9 },
  { name: 'Doctor', slug: 'doctor', sortOrder: 10 },
  { name: 'Water', slug: 'water', sortOrder: 11 },
  { name: 'Gas', slug: 'gas', sortOrder: 12 },
];

const LOCATION_MASTER = {
  Islamabad: [
    'Blue Area', 'Bani Gala', 'Bahria Enclave', 'Chak Shahzad', 'DHA Islamabad',
    'Diplomatic Enclave', 'E-7', 'E-8', 'E-9', 'E-10', 'E-11',
    'F-5', 'F-6', 'F-7', 'F-8', 'F-10', 'F-11',
    'G-5', 'G-6', 'G-7', 'G-8', 'G-9', 'G-10', 'G-11', 'G-12', 'G-13', 'G-14', 'G-15', 'G-16',
    'H-8', 'H-9', 'H-10', 'H-11', 'H-12',
    'I-8', 'I-9', 'I-10', 'I-11', 'I-12', 'I-14', 'I-15', 'I-16',
    'Jinnah Garden', 'Kurri Road', 'Lehtarar Road', 'Mumtaz City', 'Naval Anchorage',
    'PWD Housing Society', 'Soan Garden', 'Tarnol', 'Taramri', 'Top City-1',
  ],
  Rawalpindi: [
    'Adiala Road', 'Afshan Colony', 'Airport Housing Society', 'Asghar Mall', 'Askari 14', 'Askari 15',
    'Bahria Town Phase 1', 'Bahria Town Phase 2', 'Bahria Town Phase 3', 'Bahria Town Phase 4',
    'Bahria Town Phase 5', 'Bahria Town Phase 6', 'Bahria Town Phase 7', 'Bahria Town Phase 8',
    'Chaklala Scheme 1', 'Chaklala Scheme 2', 'Chakri Road',
    'DHA Phase 1', 'DHA Phase 2', 'DHA Phase 3', 'DHA Phase 4', 'DHA Phase 5',
    'Dhoke Kala Khan', 'Gulistan Colony', 'Gulraiz Housing Scheme', 'Khayaban-e-Sir Syed',
    'Lalkurti', 'Morgah', 'Murid Chowk', 'Naseerabad', 'Peshawar Road', 'Pirwadhai',
    'Race Course', 'Raja Bazar', 'Rangpur Road', 'Saddar', 'Satellite Town', 'Scheme 3',
    'Shamsabad', 'Shalley Valley', 'Sihala', 'Tench Bhatta', 'Westridge', 'Westridge 1', 'Westridge 2', 'Westridge 3',
  ],
};

async function seedSuperAdmin() {
  const adminSeedPassword = process.env.ADMIN_SEED_PASSWORD || 'Admin@12345678';
  const passwordHash = await bcrypt.hash(adminSeedPassword, 12);

  await prisma.admin.upsert({
    where: { email: 'admin@oneconnect.pk' },
    update: {
      name: 'Super Admin',
    },
    create: {
      email: 'admin@oneconnect.pk',
      name: 'Super Admin',
      passwordHash,
    },
  });

  console.log('  - Super Admin ensured: admin@oneconnect.pk');
}

async function seedServiceCategories() {
  for (const category of SERVICE_CATEGORIES) {
    await prisma.serviceCategory.upsert({
      where: { slug: category.slug },
      update: {
        name: category.name,
        sortOrder: category.sortOrder,
        isActive: true,
      },
      create: {
        ...category,
        isActive: true,
      },
    });
  }

  console.log(`  - Service categories ensured: ${SERVICE_CATEGORIES.length}`);
}

async function seedLocationMaster() {
  let count = 0;
  for (const [city, areas] of Object.entries(LOCATION_MASTER)) {
    for (const [index, area] of areas.entries()) {
      await prisma.locationMaster.upsert({
        where: {
          city_area: {
            city,
            area,
          },
        },
        update: {
          country: 'Pakistan',
          isActive: true,
          sortOrder: index + 1,
        },
        create: {
          country: 'Pakistan',
          city,
          area,
          isActive: true,
          sortOrder: index + 1,
        },
      });
      count += 1;
    }
  }

  console.log(`  - Location master ensured: ${count} areas`);
}

async function main() {
  const requiredTables = ['admins', 'service_categories', 'location_master'];
  for (const table of requiredTables) {
    if (!(await tableExists(table))) {
      throw new Error(
        `Seed preflight failed: missing table "${table}". Run "npx prisma db push" before seeding.`,
      );
    }
  }

  console.log('Starting essential seed (admin + categories + locations)...');

  await seedSuperAdmin();
  await seedServiceCategories();
  await seedLocationMaster();

  console.log('Essential seed completed successfully.');
}

main()
  .catch((e) => {
    console.error('Seed failed:', e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });
