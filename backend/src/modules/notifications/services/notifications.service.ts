import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { BroadcastNotificationDto, NotificationTarget } from '../dto/notifications.dto';
import { UserRole } from '@prisma/client';

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params?: { page?: number; limit?: number }) {
    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.notification.findMany({
          include: { user: { select: { firstName: true, lastName: true, phone: true, role: true } } },
          orderBy: { createdAt: 'desc' },
          skip,
          take: limit,
        }),
        this.prisma.notification.count(),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.notification.findMany({
      include: { user: { select: { firstName: true, lastName: true, phone: true, role: true } } },
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }

  async broadcast(dto: BroadcastNotificationDto) {
    let userIds: string[] = [];

    if (dto.target === NotificationTarget.ALL) {
      const users = await this.prisma.user.findMany({ select: { id: true } });
      userIds = users.map((u) => u.id);
    } else if (dto.target === NotificationTarget.CUSTOMERS) {
      const users = await this.prisma.user.findMany({
        where: { role: UserRole.CUSTOMER },
        select: { id: true },
      });
      userIds = users.map((u) => u.id);
    } else if (dto.target === NotificationTarget.DRIVERS) {
      const drivers = await this.prisma.driver.findMany({ select: { userId: true } });
      userIds = drivers.map((d) => d.userId);
    } else if (dto.target === NotificationTarget.STORES) {
      // Store owners not modeled separately; notify all admins as proxy
      const users = await this.prisma.user.findMany({
        where: { role: { in: [UserRole.ADMIN, UserRole.SUPER_ADMIN] } },
        select: { id: true },
      });
      userIds = users.map((u) => u.id);
    }

    const type = dto.type || 'BROADCAST';
    const notifications = await this.prisma.$transaction(
      userIds.map((userId) =>
        this.prisma.notification.create({
          data: { userId, title: dto.title, body: dto.body, type },
        }),
      ),
    );

    return { sent: notifications.length, target: dto.target };
  }
}
