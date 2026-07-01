import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { Order, Prisma, OrderStatus } from '@prisma/client';

@Injectable()
export class OrdersRepository {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.OrderCreateInput): Promise<Order> {
    return this.prisma.order.create({ data });
  }

  async findById(id: string): Promise<Order | null> {
    return this.prisma.order.findUnique({
      where: { id },
      include: {
        customer: true,
        driver: { include: { user: true } },
        statusHistory: true,
      },
    });
  }

  async updateStatus(id: string, status: OrderStatus): Promise<Order> {
    return this.prisma.order.update({
      where: { id },
      data: {
        status,
        statusHistory: {
          create: { status },
        },
      },
    });
  }

  async assignDriver(id: string, driverId: string): Promise<Order> {
    return this.prisma.order.update({
      where: { id },
      data: {
        driverId,
        status: 'ACCEPTED',
        statusHistory: {
          create: { status: 'ACCEPTED' },
        },
      },
    });
  }

  async findByCustomerId(customerId: string): Promise<Order[]> {
    return this.prisma.order.findMany({
      where: { customerId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findByDriverId(driverId: string): Promise<Order[]> {
    return this.prisma.order.findMany({
      where: { driverId },
      orderBy: { createdAt: 'desc' },
    });
  }
}
