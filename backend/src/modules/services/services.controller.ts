import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards, Req } from '@nestjs/common';
import { ServicesService } from './services.service';
import { CreateServiceDto } from './dto/create-service.dto';
import { UpdateServiceDto } from './dto/update-service.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('services')
export class ServicesController {
  constructor(private readonly servicesService: ServicesService) {}

  @Get('categories')
  getCategories() {
    return this.servicesService.getCategories();
  }

  @UseGuards(JwtAuthGuard)
  @Get('my')
  getMyServices(@CurrentUser() user: any) {
    return this.servicesService.getMyServices(user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/favorite')
  toggleFavorite(@Param('id') id: string, @CurrentUser() user: any) {
    return this.servicesService.toggleFavorite(user.id, id);
  }

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@CurrentUser() user: any, @Body() createServiceDto: CreateServiceDto) {
    return this.servicesService.create(user.id, createServiceDto);
  }

  @Get()
  findAll(@Query() query: any) {
    return this.servicesService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.servicesService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(@CurrentUser() user: any, @Param('id') id: string, @Body() updateServiceDto: UpdateServiceDto) {
    return this.servicesService.update(user.id, id, updateServiceDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@CurrentUser() user: any, @Param('id') id: string) {
    return this.servicesService.remove(user.id, id);
  }
}
