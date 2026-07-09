import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { CreateJobDto } from './dto/create-job.dto';
import { UpdateJobDto } from './dto/update-job.dto';
import { PrismaService } from '../../database/prisma.service';
import { JobStatus, EmploymentType } from '@prisma/client';

@Injectable()
export class JobsService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateJobDto) {
    return this.prisma.job.create({
      data: {
        ...dto,
        employerId: userId,
        status: JobStatus.ACTIVE,
      },
      include: {
        category: true,
        employer: { select: { id: true, firstName: true, lastName: true, profilePhoto: true } },
      },
    });
  }

  async findAll(query: any = {}) {
    const { categoryId, location, search, employmentType, page = 1, limit = 10 } = query;
    const skip = (Number(page) - 1) * Number(limit);
    
    const where: any = { status: JobStatus.ACTIVE };
    
    if (categoryId) where.categoryId = categoryId;
    if (location) where.location = location;
    if (employmentType && Object.values(EmploymentType).includes(employmentType)) {
      where.employmentType = employmentType;
    }
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
        { companyName: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.job.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          category: true,
          employer: { select: { id: true, firstName: true, lastName: true, profilePhoto: true } },
        },
      }),
      this.prisma.job.count({ where }),
    ]);

    return { data, total, page: Number(page), lastPage: Math.ceil(total / Number(limit)) };
  }

  async findOne(id: string) {
    const job = await this.prisma.job.findUnique({
      where: { id },
      include: {
        category: true,
        employer: { select: { id: true, firstName: true, lastName: true, profilePhoto: true } },
      },
    });

    if (!job) throw new NotFoundException('Job not found');

    // Increment views
    await this.prisma.job.update({
      where: { id },
      data: { viewsCount: { increment: 1 } },
    });

    return job;
  }

  async update(userId: string, id: string, dto: UpdateJobDto) {
    const job = await this.prisma.job.findUnique({ where: { id } });
    if (!job) throw new NotFoundException('Job not found');
    if (job.employerId !== userId) throw new UnauthorizedException('You can only update your own jobs');

    return this.prisma.job.update({
      where: { id },
      data: dto,
    });
  }

  async remove(userId: string, id: string) {
    const job = await this.prisma.job.findUnique({ where: { id } });
    if (!job) throw new NotFoundException('Job not found');
    if (job.employerId !== userId) throw new UnauthorizedException('You can only delete your own jobs');

    return this.prisma.job.delete({ where: { id } });
  }

  async getMyJobs(userId: string) {
    return this.prisma.job.findMany({
      where: { employerId: userId },
      orderBy: { createdAt: 'desc' },
      include: {
        category: true,
      },
    });
  }

  async toggleSave(userId: string, jobId: string) {
    const existing = await this.prisma.savedJob.findUnique({
      where: { userId_jobId: { userId, jobId } },
    });

    if (existing) {
      await this.prisma.savedJob.delete({ where: { id: existing.id } });
      return { success: true, saved: false };
    } else {
      await this.prisma.savedJob.create({
        data: { userId, jobId },
      });
      return { success: true, saved: true };
    }
  }

  async getCategories() {
    return this.prisma.jobCategory.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });
  }
}
