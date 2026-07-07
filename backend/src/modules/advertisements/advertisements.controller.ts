import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards, Req } from '@nestjs/common';
import { AdvertisementsService } from './advertisements.service';
import { CreateAdvertisementDto } from './dto/create-advertisement.dto';
import { UpdateAdvertisementDto } from './dto/update-advertisement.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../common/guards/roles.guard';
import { Roles } from '../../common/decorators/roles.decorator';
import { UserRole } from '@prisma/client';

@Controller('advertisements')
export class AdvertisementsController {
  constructor(private readonly advertisementsService: AdvertisementsService) {}

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@Req() req: any, @Body() createAdvertisementDto: CreateAdvertisementDto) {
    return this.advertisementsService.create(req.user.id, createAdvertisementDto);
  }

  @Get()
  findAll(
    @Query('categoryId') categoryId?: string,
    @Query('search') search?: string,
    @Query('status') status?: string,
    @Query('sellerId') sellerId?: string,
  ) {
    return this.advertisementsService.findAll({ categoryId, search, status, sellerId });
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.advertisementsService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(@Req() req: any, @Param('id') id: string, @Body() updateAdvertisementDto: UpdateAdvertisementDto) {
    const isSuperAdmin = req.user.role === UserRole.SUPER_ADMIN || req.user.role === UserRole.ADMIN;
    return this.advertisementsService.update(id, updateAdvertisementDto, isSuperAdmin ? undefined : req.user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Req() req: any, @Param('id') id: string) {
    const isSuperAdmin = req.user.role === UserRole.SUPER_ADMIN || req.user.role === UserRole.ADMIN;
    return this.advertisementsService.remove(id, isSuperAdmin ? undefined : req.user.id);
  }
}
