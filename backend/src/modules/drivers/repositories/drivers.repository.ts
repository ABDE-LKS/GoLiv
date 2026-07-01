import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { Driver, Prisma } from '@prisma/client';

@Injectable()
export class DriversRepository {
  constructor(private prisma: PrismaService) {}

  async create(data: Prisma.DriverCreateInput): Promise<Driver> {
    return this.prisma.driver.create({ data });
  }

  async findById(id: string): Promise<Driver | null> {
    return this.prisma.driver.findUnique({
      where: { id },
      include: { user: true },
    });
  }

  async findByUserId(userId: string): Promise<Driver | null> {
    return this.prisma.driver.findUnique({ where: { userId } });
  }

  async findAllOnline(): Promise<Driver[]> {
    return this.prisma.driver.findMany({
      where: { isOnline: true },
      include: { user: true },
    });
  }

  async updateStatus(id: string, isOnline: boolean): Promise<Driver> {
    return this.prisma.driver.update({
      where: { id },
      data: { isOnline },
    });
  }

  async updateLocation(id: string, lat: number, lng: number): Promise<Driver> {
    return this.prisma.driver.update({
      where: { id },
      data: { currentLat: lat, currentLng: lng },
    });
  }
}
