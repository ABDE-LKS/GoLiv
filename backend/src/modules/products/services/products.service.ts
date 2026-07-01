import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { CreateProductDto, UpdateProductDto } from '../dto/products.dto';

@Injectable()
export class ProductsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params: {
    storeId?: string;
    search?: string;
    status?: string;
    page?: number;
    limit?: number;
  }) {
    const where: Record<string, unknown> = {};
    if (params.storeId) where.storeId = params.storeId;
    if (params.search) {
      where.name = { contains: params.search, mode: 'insensitive' };
    }
    if (params.status === 'active') where.isActive = true;
    if (params.status === 'inactive') where.isActive = false;

    const include = {
      store: { select: { id: true, name: true, category: { select: { id: true, name: true } } } },
    };

    if (params.page && params.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.product.findMany({
          where,
          include,
          orderBy: { displayOrder: 'asc' },
          skip,
          take: limit,
        }),
        this.prisma.product.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.product.findMany({
      where,
      include,
      orderBy: { displayOrder: 'asc' },
    });
  }

  async findOne(id: string) {
    const product = await this.prisma.product.findUnique({
      where: { id },
      include: {
        store: { select: { id: true, name: true, category: { select: { id: true, name: true } } } },
      },
    });
    if (!product) throw new NotFoundException(`Product with ID ${id} not found`);
    return product;
  }

  async create(data: CreateProductDto) {
    const store = await this.prisma.store.findUnique({ where: { id: data.storeId } });
    if (!store) throw new NotFoundException(`Store with ID ${data.storeId} not found`);
    return this.prisma.product.create({ data });
  }

  async update(id: string, data: UpdateProductDto) {
    await this.findOne(id);
    if (data.storeId) {
      const store = await this.prisma.store.findUnique({ where: { id: data.storeId } });
      if (!store) throw new NotFoundException(`Store with ID ${data.storeId} not found`);
    }
    return this.prisma.product.update({ where: { id }, data });
  }

  async remove(id: string) {
    await this.findOne(id);
    return this.prisma.product.delete({ where: { id } });
  }
}
