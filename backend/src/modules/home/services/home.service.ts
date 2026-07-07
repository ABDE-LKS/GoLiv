import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';

@Injectable()
export class HomeService {
  constructor(private readonly prisma: PrismaService) {}

  async getAggregatedFeed() {
    const [banners, announcements, categories, featuredOffers, featuredStores, featuredProducts, featuredAdvertisements] = await Promise.all([
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
      // Featured Stores
      this.prisma.store.findMany({
        where: { isActive: true, isFeatured: true },
        orderBy: { rating: 'desc' },
        take: 10,
      }),
      // Featured Products (Delivery)
      this.prisma.product.findMany({
        where: { isActive: true, isFeatured: true },
        include: { store: true },
        take: 10,
      }),
      // Featured Advertisements (Marketplace)
      this.prisma.advertisement.findMany({
        where: { status: 'ACTIVE' },
        orderBy: { createdAt: 'desc' },
        include: { 
          images: true,
          seller: { select: { id: true, firstName: true, lastName: true, phone: true } },
          category: true 
        },
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
      featuredAdvertisements,
    };
  }
}
