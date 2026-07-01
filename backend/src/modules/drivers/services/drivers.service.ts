import {
  Injectable,
  NotFoundException,
  ConflictException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { PrismaService } from '../../../database/prisma.service';
import { CreateDriverDto, UpdateDriverDto } from '../dto/drivers.dto';
import { UserRole } from '@prisma/client';

@Injectable()
export class DriversService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params?: { search?: string; status?: string; page?: number; limit?: number }) {
    const where: Record<string, unknown> = {};
    if (params?.status === 'online') where.isOnline = true;
    if (params?.status === 'offline') where.isOnline = false;

    const userWhere: Record<string, unknown> = {};
    if (params?.search) {
      userWhere.OR = [
        { firstName: { contains: params.search, mode: 'insensitive' } },
        { lastName: { contains: params.search, mode: 'insensitive' } },
        { phone: { contains: params.search } },
      ];
    }
    if (Object.keys(userWhere).length > 0) where.user = userWhere;

    const include = {
      user: { select: { id: true, firstName: true, lastName: true, phone: true, profilePhoto: true } },
      _count: { select: { orders: true } },
    };

    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.driver.findMany({ where, include, orderBy: { createdAt: 'desc' }, skip, take: limit }),
        this.prisma.driver.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.driver.findMany({ where, include, orderBy: { createdAt: 'desc' } });
  }

  async findOne(id: string) {
    const driver = await this.prisma.driver.findUnique({
      where: { id },
      include: {
        user: { select: { id: true, firstName: true, lastName: true, phone: true, profilePhoto: true } },
        orders: {
          take: 20,
          orderBy: { createdAt: 'desc' },
          include: { customer: { select: { firstName: true, lastName: true, phone: true } } },
        },
        earnings: { take: 10, orderBy: { createdAt: 'desc' } },
      },
    });
    if (!driver) throw new NotFoundException(`Driver with ID ${id} not found`);
    return driver;
  }

  async create(dto: CreateDriverDto) {
    const existing = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
    if (existing) throw new ConflictException('Phone number already registered');

    const hashedPassword = await bcrypt.hash(dto.password, 10);

    return this.prisma.driver.create({
      data: {
        vehicleType: dto.vehicleType,
        licenseNumber: dto.licenseNumber,
        user: {
          create: {
            firstName: dto.firstName,
            lastName: dto.lastName,
            phone: dto.phone,
            password: hashedPassword,
            role: UserRole.DRIVER,
          },
        },
      },
      include: {
        user: { select: { id: true, firstName: true, lastName: true, phone: true } },
      },
    });
  }

  async update(id: string, dto: UpdateDriverDto) {
    await this.findOne(id);
    const driver = await this.prisma.driver.findUnique({ where: { id }, include: { user: true } });
    if (!driver) throw new NotFoundException(`Driver with ID ${id} not found`);

    const userUpdate: Record<string, string> = {};
    if (dto.firstName) userUpdate.firstName = dto.firstName;
    if (dto.lastName) userUpdate.lastName = dto.lastName;
    if (dto.phone) userUpdate.phone = dto.phone;

    const driverUpdate: Record<string, unknown> = {};
    if (dto.vehicleType !== undefined) driverUpdate.vehicleType = dto.vehicleType;
    if (dto.licenseNumber !== undefined) driverUpdate.licenseNumber = dto.licenseNumber;
    if (dto.isOnline !== undefined) driverUpdate.isOnline = dto.isOnline;

    return this.prisma.driver.update({
      where: { id },
      data: {
        ...driverUpdate,
        user: Object.keys(userUpdate).length > 0 ? { update: userUpdate } : undefined,
      },
      include: {
        user: { select: { id: true, firstName: true, lastName: true, phone: true } },
      },
    });
  }

  async suspend(id: string) {
    return this.update(id, { isOnline: false });
  }

  async remove(id: string) {
    const driver = await this.prisma.driver.findUnique({ where: { id } });
    if (!driver) throw new NotFoundException(`Driver with ID ${id} not found`);
    await this.prisma.$transaction([
      this.prisma.driver.delete({ where: { id } }),
      this.prisma.user.delete({ where: { id: driver.userId } }),
    ]);
    return { success: true };
  }

  async toggleStatus(driverId: string, isOnline: boolean) {
    const driver = await this.prisma.driver.findUnique({ where: { id: driverId } });
    if (!driver) throw new NotFoundException('Driver not found');
    return this.prisma.driver.update({ where: { id: driverId }, data: { isOnline } });
  }

  async updateLocation(driverId: string, lat: number, lng: number) {
    return this.prisma.driver.update({
      where: { id: driverId },
      data: { currentLat: lat, currentLng: lng },
    });
  }

  async getOnlineDrivers() {
    return this.prisma.driver.findMany({
      where: { isOnline: true },
      include: { user: { select: { firstName: true, lastName: true, phone: true } } },
    });
  }
}
