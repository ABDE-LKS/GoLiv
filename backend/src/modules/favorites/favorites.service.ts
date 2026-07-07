import { Injectable, ConflictException, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';

@Injectable()
export class FavoritesService {
  constructor(private readonly prisma: PrismaService) {}

  async addFavorite(userId: string, adId: string) {
    const existing = await this.prisma.favorite.findUnique({
      where: { userId_adId: { userId, adId } },
    });
    if (existing) throw new ConflictException('Already in favorites');

    return this.prisma.favorite.create({
      data: { userId, adId },
    });
  }

  findAll(userId: string) {
    return this.prisma.favorite.findMany({
      where: { userId },
      include: {
        ad: {
          include: { images: true },
        },
      },
    });
  }

  async removeFavorite(userId: string, adId: string) {
    try {
      return await this.prisma.favorite.delete({
        where: { userId_adId: { userId, adId } },
      });
    } catch (error) {
      throw new NotFoundException('Favorite not found');
    }
  }
}
