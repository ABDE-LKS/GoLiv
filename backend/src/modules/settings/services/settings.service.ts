import { Injectable } from '@nestjs/common';
import { PrismaService } from '../../../database/prisma.service';
import { UpdateSettingsBulkDto } from '../dto/settings.dto';

const DEFAULT_SETTINGS = {
  deliveryFee: '200',
  commissionPercentage: '10',
  maintenanceMode: 'false',
  appName: 'Guliv',
};

@Injectable()
export class SettingsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    const settings = await this.prisma.setting.findMany();
    const map: Record<string, string> = { ...DEFAULT_SETTINGS };

    for (const s of settings) {
      map[s.key] = s.value;
    }

    return map;
  }

  async updateBulk(dto: UpdateSettingsBulkDto) {
    const entries = Object.entries(dto).filter(([, v]) => v !== undefined);

    await this.prisma.$transaction(
      entries.map(([key, value]) =>
        this.prisma.setting.upsert({
          where: { key },
          create: { key, value: value! },
          update: { value: value! },
        }),
      ),
    );

    return this.findAll();
  }
}
