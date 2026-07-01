import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { CreateOfferDto, UpdateOfferDto } from '../dto/offers.dto';

@Injectable()
export class OffersService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params?: { storeId?: string; search?: string; status?: string; page?: number; limit?: number }) {
    const where: Record<string, unknown> = {};
    if (params?.storeId) where.storeId = params.storeId;
    if (params?.search) where.title = { contains: params.search, mode: 'insensitive' };
    if (params?.status === 'active') where.isActive = true;
    if (params?.status === 'inactive') where.isActive = false;

    const include = { store: { select: { id: true, name: true } } };

    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.offer.findMany({ where, include, orderBy: { displayPriority: 'desc' }, skip, take: limit }),
        this.prisma.offer.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.offer.findMany({ where, include, orderBy: { displayPriority: 'desc' } });
  }

  async findOne(id: string) {
    const offer = await this.prisma.offer.findUnique({
      where: { id },
      include: { store: { select: { id: true, name: true } } },
    });
    if (!offer) throw new NotFoundException(`Offer with ID ${id} not found`);
    return offer;
  }

  async create(data: CreateOfferDto) {
    const store = await this.prisma.store.findUnique({ where: { id: data.storeId } });
    if (!store) throw new NotFoundException(`Store with ID ${data.storeId} not found`);

    return this.prisma.offer.create({
      data: {
        ...data,
        bannerImage: data.bannerImage || '',
        startDate: new Date(data.startDate),
        endDate: new Date(data.endDate),
      },
      include: { store: { select: { id: true, name: true } } },
    });
  }

  async update(id: string, data: UpdateOfferDto) {
    await this.findOne(id);
    const updateData: Record<string, unknown> = { ...data };
    if (data.startDate) updateData.startDate = new Date(data.startDate);
    if (data.endDate) updateData.endDate = new Date(data.endDate);

    return this.prisma.offer.update({
      where: { id },
      data: updateData,
      include: { store: { select: { id: true, name: true } } },
    });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.offer.delete({ where: { id } });
  }
}
