import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { CreateStoreDto, UpdateStoreDto } from '../dto/stores.dto';

@Injectable()
export class StoresService {
  constructor(private prisma: PrismaService) {}

  async findAll(params: { categoryId?: string; search?: string; status?: string }) {
    const { categoryId, search, status } = params;

    const whereClause: Record<string, unknown> = {};
    if (categoryId) whereClause.categoryId = categoryId;
    if (search) whereClause.name = { contains: search, mode: 'insensitive' };

    if (status === 'suspended') {
      whereClause.isActive = false;
    } else if (status !== 'all') {
      whereClause.isActive = true;
    }

    return this.prisma.store.findMany({
      where: whereClause,
      include: { category: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const store = await this.prisma.store.findUnique({
      where: { id },
      include: {
        category: true,
        products: {
          where: { isActive: true },
          orderBy: { displayOrder: 'asc' },
        },
      },
    });

    if (!store) {
      throw new NotFoundException(`Store with ID ${id} not found`);
    }
    return store;
  }

  async create(data: CreateStoreDto) {
    const category = await this.prisma.category.findUnique({ where: { id: data.categoryId } });
    if (!category) throw new NotFoundException(`Category with ID ${data.categoryId} not found`);
    return this.prisma.store.create({ data, include: { category: true } });
  }

  async update(id: string, data: UpdateStoreDto) {
    await this.findOne(id);
    if (data.categoryId) {
      const category = await this.prisma.category.findUnique({ where: { id: data.categoryId } });
      if (!category) throw new NotFoundException(`Category with ID ${data.categoryId} not found`);
    }
    return this.prisma.store.update({ where: { id }, data, include: { category: true } });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.store.delete({ where: { id } });
  }
}
