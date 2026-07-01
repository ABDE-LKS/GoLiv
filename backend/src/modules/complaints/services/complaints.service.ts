import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { UpdateComplaintDto } from '../dto/complaints.dto';

@Injectable()
export class ComplaintsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params?: { search?: string; status?: string; page?: number; limit?: number }) {
    const where: Record<string, unknown> = {};
    if (params?.status && params.status !== 'all') where.status = params.status;
    if (params?.search) {
      where.OR = [
        { subject: { contains: params.search, mode: 'insensitive' } },
        { body: { contains: params.search, mode: 'insensitive' } },
      ];
    }

    const include = {
      customer: { select: { id: true, firstName: true, lastName: true, phone: true } },
    };

    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.complaint.findMany({ where, include, orderBy: { createdAt: 'desc' }, skip, take: limit }),
        this.prisma.complaint.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.complaint.findMany({ where, include, orderBy: { createdAt: 'desc' } });
  }

  async findOne(id: string) {
    const complaint = await this.prisma.complaint.findUnique({
      where: { id },
      include: {
        customer: { select: { id: true, firstName: true, lastName: true, phone: true, email: true } },
      },
    });
    if (!complaint) throw new NotFoundException(`Complaint with ID ${id} not found`);
    return complaint;
  }

  async update(id: string, data: UpdateComplaintDto) {
    await this.findOne(id);
    return this.prisma.complaint.update({ where: { id }, data });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.complaint.delete({ where: { id } });
  }
}
