import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class HomeService {
  constructor(private readonly prisma: PrismaService) {}

  async getAggregatedFeed() {
    const [banners, announcements, categories, featuredOffers, featuredStores, featuredProducts] = await Promise.all([
      // Top Banners
      this.prisma.banner.findMany({
        where: { isActive: true },
        orderBy: { priority: 'desc' },
        take: 5,
      }),
      // Announcements
      this.prisma.announcement.findMany({
        where: { isActive: true },
        orderBy: { createdAt: 'desc' },
        take: 3,
      }),
      // Categories
      this.prisma.category.findMany({
        where: { isActive: true },
        orderBy: { name: 'asc' },
      }),
      // Featured Offers
      this.prisma.offer.findMany({
        where: { 
            isActive: true,
            startDate: { lte: new Date() },
            endDate: { gte: new Date() }
        },
        orderBy: { displayPriority: 'desc' },
        include: { store: true },
        take: 10,
      }),
      // Featured Stores (replaces Favorites section based on priority)
      this.prisma.store.findMany({
        where: { isActive: true, isFeatured: true },
        orderBy: { rating: 'desc' },
        take: 10,
      }),
      // Featured Products Grid
      this.prisma.product.findMany({
        where: { isActive: true, isFeatured: true },
        include: { store: true },
        take: 10,
      })
    ]);

    return {
      banners,
      announcements,
      categories,
      offers: featuredOffers,
      featuredStores,
      featuredProducts,
    };
  }
}
