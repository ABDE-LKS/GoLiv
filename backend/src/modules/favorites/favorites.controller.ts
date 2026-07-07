import { Controller, Get, Post, Param, Delete, UseGuards, Req } from '@nestjs/common';
import { FavoritesService } from './favorites.service';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('favorites')
@UseGuards(JwtAuthGuard)
export class FavoritesController {
  constructor(private readonly favoritesService: FavoritesService) {}

  @Post(':adId')
  addFavorite(@Req() req: any, @Param('adId') adId: string) {
    return this.favoritesService.addFavorite(req.user.id, adId);
  }

  @Get()
  findAll(@Req() req: any) {
    return this.favoritesService.findAll(req.user.id);
  }

  @Delete(':adId')
  removeFavorite(@Req() req: any, @Param('adId') adId: string) {
    return this.favoritesService.removeFavorite(req.user.id, adId);
  }
}
