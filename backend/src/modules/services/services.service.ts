import { Injectable, NotFoundException, UnauthorizedException } from '@nestjs/common';
import { CreateServiceDto } from './dto/create-service.dto';
import { UpdateServiceDto } from './dto/update-service.dto';
import { PrismaService } from '../../database/prisma.service';
import { ServiceStatus } from '@prisma/client';

@Injectable()
export class ServicesService {
  constructor(private prisma: PrismaService) {}

  async create(userId: string, dto: CreateServiceDto) {
    const { images, ...data } = dto;
    
    return this.prisma.service.create({
      data: {
        ...data,
        providerId: userId,
        status: ServiceStatus.ACTIVE,
        images: {
          create: images?.map((url) => ({ url })) || [],
        },
      },
      include: {
        images: true,
        category: true,
        provider: { select: { id: true, firstName: true, lastName: true, profilePhoto: true, phone: true } },
      },
    });
  }

  async findAll(query: any = {}) {
    const { categoryId, city, search, page = 1, limit = 10 } = query;
    const skip = (Number(page) - 1) * Number(limit);
    
    const where: any = { status: ServiceStatus.ACTIVE };
    
    if (categoryId) where.categoryId = categoryId;
    if (city) where.city = city;
    if (search) {
      where.OR = [
        { title: { contains: search, mode: 'insensitive' } },
        { description: { contains: search, mode: 'insensitive' } },
      ];
    }

    const [data, total] = await Promise.all([
      this.prisma.service.findMany({
        where,
        skip,
        take: Number(limit),
        orderBy: { createdAt: 'desc' },
        include: {
          images: { take: 1 },
          category: true,
          provider: { select: { id: true, firstName: true, lastName: true, profilePhoto: true } },
        },
      }),
      this.prisma.service.count({ where }),
    ]);

    return { data, total, page: Number(page), lastPage: Math.ceil(total / Number(limit)) };
  }

  async findOne(id: string) {
    const service = await this.prisma.service.findUnique({
      where: { id },
      include: {
        images: true,
        category: true,
        provider: { select: { id: true, firstName: true, lastName: true, profilePhoto: true, phone: true } },
        reviews: { include: { user: { select: { firstName: true, lastName: true, profilePhoto: true } } } },
      },
    });

    if (!service) throw new NotFoundException('Service not found');

    // Increment views
    await this.prisma.service.update({
      where: { id },
      data: { viewsCount: { increment: 1 } },
    });

    return service;
  }

  async update(userId: string, id: string, dto: UpdateServiceDto) {
    const service = await this.prisma.service.findUnique({ where: { id } });
    if (!service) throw new NotFoundException('Service not found');
    if (service.providerId !== userId) throw new UnauthorizedException('You can only update your own services');

    const { images, ...data } = dto;
    
    // Simple update - if images changed, delete all and recreate (in a real app, optimize this)
    if (images !== undefined) {
      await this.prisma.serviceImage.deleteMany({ where: { serviceId: id } });
    }

    return this.prisma.service.update({
      where: { id },
      data: {
        ...data,
        ...(images !== undefined && {
          images: {
            create: images.map((url) => ({ url })),
          },
        }),
      },
      include: { images: true },
    });
  }

  async remove(userId: string, id: string) {
    const service = await this.prisma.service.findUnique({ where: { id } });
    if (!service) throw new NotFoundException('Service not found');
    if (service.providerId !== userId) throw new UnauthorizedException('You can only delete your own services');

    return this.prisma.service.delete({ where: { id } });
  }

  async getMyServices(userId: string) {
    return this.prisma.service.findMany({
      where: { providerId: userId },
      orderBy: { createdAt: 'desc' },
      include: {
        images: { take: 1 },
        category: true,
      },
    });
  }

  async toggleFavorite(userId: string, serviceId: string) {
    const existing = await this.prisma.favoriteService.findUnique({
      where: { userId_serviceId: { userId, serviceId } },
    });

    if (existing) {
      await this.prisma.favoriteService.delete({ where: { id: existing.id } });
      return { success: true, favorited: false };
    } else {
      await this.prisma.favoriteService.create({
        data: { userId, serviceId },
      });
      return { success: true, favorited: true };
    }
  }

  async getCategories() {
    return this.prisma.serviceCategory.findMany({
      where: { isActive: true },
      orderBy: { sortOrder: 'asc' },
    });
  }
}
