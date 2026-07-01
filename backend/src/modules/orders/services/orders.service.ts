import { Injectable, NotFoundException } from '@nestjs/common';
import { OrdersRepository } from '../repositories/orders.repository';
import { OrderStatus } from '@prisma/client';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class OrdersService {
  constructor(
    private ordersRepository: OrdersRepository,
    private readonly prisma: PrismaService,
  ) {}

  // ========================
  // ADMIN: List all orders with filters
  // ========================
  async findAll(params: { status?: string; search?: string }) {
    const { status, search } = params;
    const whereClause: any = {};

    if (status && status !== 'all') {
      whereClause.status = status;
    }

    if (search) {
      whereClause.OR = [
        { id: { contains: search, mode: 'insensitive' } },
        { customer: { firstName: { contains: search, mode: 'insensitive' } } },
        { customer: { lastName: { contains: search, mode: 'insensitive' } } },
        { customer: { phone: { contains: search, mode: 'insensitive' } } },
      ];
    }

    return this.prisma.order.findMany({
      where: whereClause,
      include: {
        customer: { select: { id: true, firstName: true, lastName: true, phone: true } },
        driver: { include: { user: { select: { id: true, firstName: true, lastName: true, phone: true } } } },
        statusHistory: { orderBy: { timestamp: 'desc' } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  // ========================
  // ADMIN: Get single order details
  // ========================
  async findOne(orderId: string) {
    const order = await this.prisma.order.findUnique({
      where: { id: orderId },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true, phone: true, email: true } },
        driver: { include: { user: { select: { id: true, firstName: true, lastName: true, phone: true } } } },
        statusHistory: { orderBy: { timestamp: 'desc' } },
        chat: { include: { messages: { orderBy: { createdAt: 'desc' }, take: 5 } } },
      },
    });

    if (!order) throw new NotFoundException('Order not found');
    return order;
  }

  // ========================
  // ADMIN: Update order status
  // ========================
  async updateStatus(orderId: string, status: OrderStatus) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');

    const updateData: any = { status };
    if (status === 'PICKED_UP') updateData.pickupTime = new Date();
    if (status === 'DELIVERED') updateData.deliveryTime = new Date();

    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        ...updateData,
        statusHistory: { create: { status } },
      },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true, phone: true } },
        driver: { include: { user: { select: { id: true, firstName: true, lastName: true, phone: true } } } },
        statusHistory: { orderBy: { timestamp: 'desc' } },
      },
    });
  }

  // ========================
  // ADMIN: Assign driver to order
  // ========================
  async assignDriver(orderId: string, driverId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');

    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        driverId,
        status: 'ACCEPTED',
        statusHistory: { create: { status: 'ACCEPTED' } },
      },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true, phone: true } },
        driver: { include: { user: { select: { id: true, firstName: true, lastName: true, phone: true } } } },
        statusHistory: { orderBy: { timestamp: 'desc' } },
      },
    });
  }

  // ========================
  // ADMIN: Cancel order
  // ========================
  async cancelOrder(orderId: string) {
    const order = await this.prisma.order.findUnique({ where: { id: orderId } });
    if (!order) throw new NotFoundException('Order not found');

    return this.prisma.order.update({
      where: { id: orderId },
      data: {
        status: 'CANCELLED',
        statusHistory: { create: { status: 'CANCELLED' } },
      },
    });
  }

  // ========================
  // CUSTOMER: My orders
  // ========================
  async findMyOrders(customerId: string) {
    return this.prisma.order.findMany({
      where: { customerId },
      include: {
        driver: { include: { user: { select: { firstName: true, lastName: true, phone: true } } } },
        statusHistory: { orderBy: { timestamp: 'desc' }, take: 1 },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
    });
  }

  // ========================
  // CUSTOMER: Create custom request
  // ========================
  async createCustomRequest(customerId: string, data: any) {
    const order = await this.prisma.order.create({
      data: {
        customerId,
        status: 'PENDING',
        pickupLocation: data.pickupLocation ?? 'CUSTOM_REQUEST',
        deliveryLocation: data.deliveryLocation ?? '',
        totalAmount: 0,
        deliveryFee: 200,
        commission: 0,
      },
    });
    return order;
  }

  // ========================
  // ADMIN: Get available drivers for assignment
  // ========================
  async getAvailableDrivers() {
    return this.prisma.driver.findMany({
      where: { isOnline: true },
      include: { user: { select: { id: true, firstName: true, lastName: true, phone: true } } },
    });
  }
}
