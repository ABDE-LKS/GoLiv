import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  async getSummary() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [
      totalOrders,
      deliveredOrders,
      totalRevenue,
      totalCommission,
      totalCustomers,
      totalDrivers,
      totalStores,
      openComplaints,
    ] = await Promise.all([
      this.prisma.order.count(),
      this.prisma.order.count({ where: { status: 'DELIVERED' } }),
      this.prisma.order.aggregate({ _sum: { totalAmount: true }, where: { status: 'DELIVERED' } }),
      this.prisma.order.aggregate({ _sum: { commission: true }, where: { status: 'DELIVERED' } }),
      this.prisma.user.count({ where: { role: 'CUSTOMER' } }),
      this.prisma.driver.count(),
      this.prisma.store.count(),
      this.prisma.complaint.count({ where: { status: { in: ['OPEN', 'IN_PROGRESS'] } } }),
    ]);

    const monthlyOrders = await this.prisma.order.findMany({
      where: { createdAt: { gte: firstDayOfMonth } },
      select: { createdAt: true, totalAmount: true, status: true },
    });

    return {
      orders: { total: totalOrders, delivered: deliveredOrders },
      revenue: { total: totalRevenue._sum.totalAmount || 0, commission: totalCommission._sum.commission || 0 },
      users: { customers: totalCustomers, drivers: totalDrivers },
      stores: totalStores,
      complaints: openComplaints,
      monthlyOrders,
    };
  }

  async exportOrdersCsv() {
    const orders = await this.prisma.order.findMany({
      include: {
        customer: { select: { firstName: true, lastName: true, phone: true } },
        driver: { include: { user: { select: { firstName: true, lastName: true } } } },
      },
      orderBy: { createdAt: 'desc' },
    });

    const header = 'ID,Date,Status,Customer,Phone,Driver,Total,DeliveryFee,Commission\n';
    const rows = orders.map((o) => {
      const customer = `${o.customer.firstName} ${o.customer.lastName}`;
      const driver = o.driver ? `${o.driver.user.firstName} ${o.driver.user.lastName}` : '';
      return [
        o.id,
        o.createdAt.toISOString(),
        o.status,
        customer,
        o.customer.phone,
        driver,
        o.totalAmount,
        o.deliveryFee,
        o.commission,
      ].join(',');
    });

    return header + rows.join('\n');
  }
}
