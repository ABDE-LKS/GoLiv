import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateAdvertisementDto } from './dto/create-advertisement.dto';
import { UpdateAdvertisementDto } from './dto/update-advertisement.dto';

@Injectable()
export class AdvertisementsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(sellerId: string, createAdvertisementDto: CreateAdvertisementDto) {
    const { images, isNegotiable, ...rest } = createAdvertisementDto;
    
    return this.prisma.advertisement.create({
      data: {
        ...rest,
        negotiable: isNegotiable ?? false,
        sellerId,
        images: images ? {
          create: images.map(img => ({ url: img.url }))
        } : undefined,
      },
      include: {
        images: true,
        category: true,
      }
    });
  }

  async findAll(params: { categoryId?: string; search?: string; status?: string; sellerId?: string }) {
    const where: any = {};
    if (params.categoryId) where.categoryId = params.categoryId;
    if (params.search) where.title = { contains: params.search, mode: 'insensitive' };
    if (params.status) where.status = params.status;
    if (params.sellerId) where.sellerId = params.sellerId;

    return this.prisma.advertisement.findMany({
      where,
      include: {
        seller: { select: { id: true, firstName: true, lastName: true, phone: true } },
        images: true,
        category: true,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const ad = await this.prisma.advertisement.findUnique({
      where: { id },
      include: {
        seller: { select: { id: true, firstName: true, lastName: true, phone: true, createdAt: true } },
        images: true,
        category: true,
      },
    });
    
    if (!ad) throw new NotFoundException(`Advertisement with ID ${id} not found`);
    
    // Increment views asynchronously
    this.prisma.advertisement.update({ where: { id }, data: { viewsCount: { increment: 1 } } }).catch(() => {});
    
    return ad;
  }

  async update(id: string, updateAdvertisementDto: UpdateAdvertisementDto, sellerId?: string) {
    const where: any = { id };
    if (sellerId) where.sellerId = sellerId; // Only allow seller or admin to update

    const ad = await this.prisma.advertisement.findFirst({ where });
    if (!ad) throw new NotFoundException(`Advertisement not found or unauthorized`);

    const { isNegotiable, images, ...rest } = updateAdvertisementDto;

    return this.prisma.advertisement.update({
      where: { id },
      data: {
        ...rest,
        ...(isNegotiable !== undefined ? { negotiable: isNegotiable } : {}),
        // images update logic could be added here if needed
      } as any,
    });
  }

  async remove(id: string, sellerId?: string) {
    const where: any = { id };
    if (sellerId) where.sellerId = sellerId;

    const ad = await this.prisma.advertisement.findFirst({ where });
    if (!ad) throw new NotFoundException(`Advertisement not found or unauthorized`);

    return this.prisma.advertisement.delete({ where: { id } });
  }
}
