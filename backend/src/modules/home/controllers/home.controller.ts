import { Controller, Get, UseGuards } from '@nestjs/common';
import { HomeService } from '../services/home.service';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';

@Controller('home')
export class HomeController {
  constructor(private readonly homeService: HomeService) {}

  @Get()
  //@UseGuards(JwtAuthGuard) // Will enable if we specifically want custom home config per user, but for now Public layout is fine with user specifics driven by client.
  async getHomeFeed() {
    return this.homeService.getAggregatedFeed();
  }
}
