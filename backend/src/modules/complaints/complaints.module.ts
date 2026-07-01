import { Module } from '@nestjs/common';
import { ComplaintsController } from './controllers/complaints.controller';
import { ComplaintsService } from './services/complaints.service';

@Module({
  controllers: [ComplaintsController],
  providers: [ComplaintsService],
  exports: [ComplaintsService],
})
export class ComplaintsModule {}
