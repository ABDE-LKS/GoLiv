import { PrismaClient, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';

const prisma = new PrismaClient();

async function main() {
  const adminPhone = '0550000001';
  const adminPassword = 'admin123';

  const existing = await prisma.user.findUnique({ where: { phone: adminPhone } });
  if (!existing) {
    const hashed = await bcrypt.hash(adminPassword, 10);
    await prisma.user.create({
      data: {
        firstName: 'Admin',
        lastName: 'Guliv',
        phone: adminPhone,
        password: hashed,
        role: UserRole.SUPER_ADMIN,
      },
    });
    console.log(`Created admin: ${adminPhone} / ${adminPassword}`);
  } else {
    console.log(`Admin already exists: ${adminPhone}`);
  }
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(() => prisma.$disconnect());
