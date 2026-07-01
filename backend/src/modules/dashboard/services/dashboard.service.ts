import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class DashboardService {
  constructor(private readonly prisma: PrismaService) {}

  async getAdminStatistics() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const firstDayOfWeek = new Date(today);
    firstDayOfWeek.setDate(today.getDate() - today.getDay()); 
    const firstDayOfMonth = new Date(today.getFullYear(), today.getMonth(), 1);

    const [
      // Orders breakdown
      todaysOrders,
      pendingOrders,
      shoppingOrders,
      deliveringOrders,
      completedOrders,
      cancelledOrders,
      // Users breakdown
      totalCustomers,
      totalDrivers,
      onlineDrivers,
      // Marketplace breakdown
      totalStores,
      totalProducts,
      activeOffers,
      openComplaints,
      // Revenue
      todaysRevenueAgg,
      totalCommissionAgg,
    ] = await Promise.all([
      this.prisma.order.count({ where: { createdAt: { gte: today } } }),
      this.prisma.order.count({ where: { status: 'PENDING' } }),
      this.prisma.order.count({ where: { status: 'ACCEPTED' } }), // Assuming Accepted means Shopping
      this.prisma.order.count({ where: { status: 'PICKED_UP' } }), // Delivering
      this.prisma.order.count({ where: { status: 'DELIVERED' } }),
      this.prisma.order.count({ where: { status: 'CANCELLED' } }),

      this.prisma.user.count({ where: { role: 'CUSTOMER' } }),
      this.prisma.driver.count(),
      this.prisma.driver.count({ where: { isOnline: true } }),

      this.prisma.store.count(),
      this.prisma.product.count(),
      this.prisma.offer.count({ where: { isActive: true } }),
      this.prisma.complaint.count({ where: { status: { in: ['OPEN', 'IN_PROGRESS'] } } }),

      this.prisma.order.aggregate({
        _sum: { totalAmount: true },
        where: { createdAt: { gte: today }, status: 'DELIVERED' }
      }),
      this.prisma.order.aggregate({
        _sum: { commission: true },
        where: { status: 'DELIVERED' }
      }),
    ]);

    // Simple manual chart aggregation for MVP charts
    const ordersThisWeekRaw = await this.prisma.order.findMany({
      where: { createdAt: { gte: firstDayOfWeek } },
      select: { createdAt: true },
    });

    const revenueThisMonthRaw = await this.prisma.order.findMany({
      where: { createdAt: { gte: firstDayOfMonth }, status: 'DELIVERED' },
      select: { createdAt: true, totalAmount: true },
    });

    // We can map these lightly for the frontend
    const ordersThisWeek = ordersThisWeekRaw.map(o => o.createdAt.getDay());

    return {
      orders: {
        today: todaysOrders,
        pending: pendingOrders,
        shopping: shoppingOrders,
        delivering: deliveringOrders,
        completed: completedOrders,
        cancelled: cancelledOrders,
      },
      users: {
        customers: totalCustomers,
        totalDrivers: totalDrivers,
        onlineDrivers: onlineDrivers,
      },
      marketplace: {
        stores: totalStores,
        products: totalProducts,
        activeOffers: activeOffers,
        openComplaints: openComplaints,
      },
      financials: {
        todaysRevenue: todaysRevenueAgg?._sum?.totalAmount ?? 0,
        totalCommission: totalCommissionAgg?._sum?.commission ?? 0,
      },
      charts: {
        ordersThisWeekCount: ordersThisWeekRaw?.length ?? 0,
        revenueThisMonthAmount: (revenueThisMonthRaw ?? []).reduce((sum, o) => sum + (o.totalAmount ?? 0), 0)
      }
    };
  }

  async getLiveOrders() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    // Fetch active orders for today or any order not delivered/cancelled yet
    const rawOrders = await this.prisma.order.findMany({
      where: {
        OR: [
          { createdAt: { gte: today } },
          { status: { notIn: ['DELIVERED', 'CANCELLED'] } }
        ]
      },
      include: {
        customer: { select: { firstName: true, lastName: true, phone: true } },
        driver: { include: { user: { select: { firstName: true, lastName: true, phone: true } } } },
        statusHistory: { orderBy: { timestamp: 'desc' } },
        // store: true // Requires Prisma Schema update for storeId in Order
      },
      orderBy: { createdAt: 'desc' }
    });

    const activeDrivers = await this.prisma.driver.findMany({
      include: {
        user: { select: { firstName: true, lastName: true, phone: true, profilePhoto: true } }
      }
    });

    return { orders: rawOrders, drivers: activeDrivers };
  }
}

