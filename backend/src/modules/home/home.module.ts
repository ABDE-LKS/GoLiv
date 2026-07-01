import { Module } from '@nestjs/common';
import { HomeService } from './services/home.service';
import { HomeController } from './controllers/home.controller';

@Module({
  controllers: [HomeController],
  providers: [HomeService],
})
export class HomeModule {}
