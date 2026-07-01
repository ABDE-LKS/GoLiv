import {
  Injectable,
  NotFoundException,
  ConflictException,
  BadRequestException,
} from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { CreateCategoryDto, UpdateCategoryDto } from '../dto/categories.dto';

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(params?: {
    search?: string;
    status?: string;
    page?: number;
    limit?: number;
  }) {
    const where: Record<string, unknown> = {};

    if (params?.search) {
      where.name = { contains: params.search, mode: 'insensitive' };
    }
    if (params?.status === 'active') where.isActive = true;
    if (params?.status === 'inactive') where.isActive = false;

    const orderBy = { sortOrder: 'asc' as const };

    if (params?.page && params?.limit) {
      const page = Math.max(1, params.page);
      const limit = Math.min(100, Math.max(1, params.limit));
      const skip = (page - 1) * limit;

      const [items, total] = await Promise.all([
        this.prisma.category.findMany({ where, orderBy, skip, take: limit }),
        this.prisma.category.count({ where }),
      ]);

      return { items, total, page, limit, totalPages: Math.ceil(total / limit) };
    }

    return this.prisma.category.findMany({ where, orderBy });
  }

  async findOne(id: string) {
    const category = await this.prisma.category.findUnique({ where: { id } });
    if (!category) throw new NotFoundException(`Category with ID ${id} not found`);
    return category;
  }

  async create(data: CreateCategoryDto) {
    try {
      return await this.prisma.category.create({ data });
    } catch (error: any) {
      if (error?.code === 'P2002') {
        throw new ConflictException('Category name already exists');
      }
      throw error;
    }
  }

  async update(id: string, data: UpdateCategoryDto) {
    await this.findOne(id);
    try {
      return await this.prisma.category.update({ where: { id }, data });
    } catch (error: any) {
      if (error?.code === 'P2002') {
        throw new ConflictException('Category name already exists');
      }
      throw error;
    }
  }

  async remove(id: string) {
    await this.findOne(id);
    const storeCount = await this.prisma.store.count({ where: { categoryId: id } });
    if (storeCount > 0) {
      throw new BadRequestException(
        `Cannot delete category with ${storeCount} linked store(s). Disable it instead.`,
      );
    }
    return this.prisma.category.delete({ where: { id } });
  }
}
