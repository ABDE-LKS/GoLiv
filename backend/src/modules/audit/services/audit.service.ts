import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  async log(userId: string | null, action: string, resource: string, meta?: Record<string, unknown>) {
    return this.prisma.auditLog.create({
      data: { userId, action, resource, meta: meta as any ?? undefined },
    });
  }

  async findAll(params?: { search?: string; page?: number; limit?: number }) {
    const where: Record<string, unknown> = {};
    if (params?.search) {
      where.OR = [
        { action: { contains: params.search, mode: 'insensitive' } },
        { resource: { contains: params.search, mode: 'insensitive' } },
      ];
    }

    const include = {
      user: { select: { firstName: true, lastName: true, phone: true, role: true } },
    };

    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.auditLog.findMany({ where, include, orderBy: { createdAt: 'desc' }, skip, take: limit }),
        this.prisma.auditLog.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.auditLog.findMany({
      where,
      include,
      orderBy: { createdAt: 'desc' },
      take: 100,
    });
  }
}
