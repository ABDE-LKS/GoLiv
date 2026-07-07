import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { ReportStatus } from '@prisma/client';

@Injectable()
export class ReportsService {
  constructor(private readonly prisma: PrismaService) {}

  // =====================================
  // USER CONTENT REPORTING (MARKETPLACE)
  // =====================================
  async createReport(userId: string, dto: { adId?: string; reportedUserId?: string; reason: string }) {
    if (!dto.adId && !dto.reportedUserId) {
      throw new NotFoundException('Must provide either adId or reportedUserId');
    }

    return this.prisma.report.create({
      data: {
        userId,
        adId: dto.adId,
        reportedUserId: dto.reportedUserId,
        reason: dto.reason,
        status: ReportStatus.PENDING,
      },
    });
  }

  async getReportsList(status?: ReportStatus) {
    return this.prisma.report.findMany({
      where: status ? { status } : undefined,
      include: {
        user: { select: { id: true, firstName: true } },
        ad: { select: { id: true, title: true } },
        reportedUser: { select: { id: true, firstName: true } },
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async updateReportStatus(reportId: string, status: ReportStatus) {
    return this.prisma.report.update({
      where: { id: reportId },
      data: { status },
    });
  }

  // =====================================
  // ADMIN DASHBOARD STATS (MARKETPLACE)
  // =====================================
  async getSummary() {
    const today = new Date();
    today.setHours(0, 0, 0, 0);

    const [
      totalUsers,
      totalAds,
      totalCategories,
      dailyRegistrations,
      reportedAds,
      reportedUsersCount,
    ] = await Promise.all([
      this.prisma.user.count(),
      this.prisma.advertisement.count(),
      this.prisma.category.count(),
      this.prisma.user.count({ where: { createdAt: { gte: today } } }),
      this.prisma.report.count({ where: { adId: { not: null }, status: 'PENDING' } }),
      this.prisma.report.count({ where: { reportedUserId: { not: null }, status: 'PENDING' } }),
    ]);

    const popularCategories = await this.prisma.advertisement.groupBy({
      by: ['categoryId'],
      _count: { id: true },
      orderBy: { _count: { id: 'desc' } },
      take: 5,
    });

    const mostViewedAds = await this.prisma.advertisement.findMany({
      take: 5,
      orderBy: { viewsCount: 'desc' },
      select: { id: true, title: true, viewsCount: true },
    });

    return {
      users: { total: totalUsers, active: totalUsers, dailyRegistrations },
      content: { advertisements: totalAds, categories: totalCategories },
      moderation: { pendingReportedAds: reportedAds, pendingReportedUsers: reportedUsersCount },
      analytics: { popularCategories, mostViewedAds },
    };
  }
}
