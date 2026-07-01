import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { UserRole } from '@prisma/client';

@Injectable()
export class CustomersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params?: { search?: string; page?: number; limit?: number }) {
    const where: Record<string, unknown> = { role: UserRole.CUSTOMER };

    if (params?.search) {
      where.OR = [
        { firstName: { contains: params.search, mode: 'insensitive' } },
        { lastName: { contains: params.search, mode: 'insensitive' } },
        { phone: { contains: params.search } },
      ];
    }

    const select = {
      id: true,
      firstName: true,
      lastName: true,
      phone: true,
      email: true,
      profilePhoto: true,
      createdAt: true,
      _count: { select: { orders: true, complaints: true } },
    };

    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.user.findMany({ where, select, orderBy: { createdAt: 'desc' }, skip, take: limit }),
        this.prisma.user.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.user.findMany({ where, select, orderBy: { createdAt: 'desc' } });
  }

  async findOne(id: string) {
    const customer = await this.prisma.user.findFirst({
      where: { id, role: UserRole.CUSTOMER },
      select: {
        id: true,
        firstName: true,
        lastName: true,
        phone: true,
        email: true,
        profilePhoto: true,
        createdAt: true,
        orders: {
          take: 20,
          orderBy: { createdAt: 'desc' },
          include: { driver: { include: { user: { select: { firstName: true, lastName: true } } } } },
        },
        complaints: { orderBy: { createdAt: 'desc' } },
      },
    });
    if (!customer) throw new NotFoundException(`Customer with ID ${id} not found`);
    return customer;
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.user.delete({ where: { id } });
  }
}
