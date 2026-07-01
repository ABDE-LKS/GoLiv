import { Module } from '@nestjs/common';
import { DriversService } from './services/drivers.service';
import { DriversRepository } from './repositories/drivers.repository';
import { DriversController } from './controllers/drivers.controller';

@Module({
  controllers: [DriversController],
  providers: [DriversService, DriversRepository],
  exports: [DriversService, DriversRepository],
})
export class DriversModule {}
