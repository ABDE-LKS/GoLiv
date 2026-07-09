import { Controller, Get, Post, Body, Query, UseGuards, Param, Patch } from '@nestjs/common';
import { NotificationsService } from '../services/notifications.service';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { UserRole } from '@prisma/client';
import { BroadcastNotificationDto } from '../dto/notifications.dto';
import { CurrentUser } from '../../../common/decorators/current-user.decorator';

@Controller('notifications')
@UseGuards(JwtAuthGuard)
export class NotificationsController {
  constructor(private readonly notificationsService: NotificationsService) {}

  @Get('my')
  getMyNotifications(@CurrentUser() user: any) {
    return this.notificationsService.getMyNotifications(user.id);
  }

  @Patch('my/:id/read')
  markAsRead(@Param('id') id: string, @CurrentUser() user: any) {
    return this.notificationsService.markAsRead(user.id, id);
  }

  @Patch('my/read-all')
  markAllAsRead(@CurrentUser() user: any) {
    return this.notificationsService.markAllAsRead(user.id);
  }

  @Get()
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  findAll(@Query('page') page?: string, @Query('limit') limit?: string) {
    return this.notificationsService.findAll({
      page: page ? parseInt(page, 10) : undefined,
      limit: limit ? parseInt(limit, 10) : undefined,
    });
  }

  @Post('broadcast')
  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  broadcast(@Body() body: BroadcastNotificationDto) {
    return this.notificationsService.broadcast(body);
  }
}
