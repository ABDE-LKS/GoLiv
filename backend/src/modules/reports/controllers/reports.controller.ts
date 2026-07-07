import { Controller, Get, Post, Body, Patch, Param, UseGuards, Req, Query } from '@nestjs/common';
import { ReportsService } from '../services/reports.service';
import { JwtAuthGuard } from '../../../common/guards/jwt-auth.guard';
import { RolesGuard } from '../../../common/guards/roles.guard';
import { Roles } from '../../../common/decorators/roles.decorator';
import { UserRole, ReportStatus } from '@prisma/client';

@Controller('reports')
@UseGuards(JwtAuthGuard)
export class ReportsController {
  constructor(private readonly reportsService: ReportsService) {}

  @Post()
  createReport(
    @Req() req: any,
    @Body() dto: { adId?: string; reportedUserId?: string; reason: string },
  ) {
    return this.reportsService.createReport(req.user.id, dto);
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get('summary')
  getSummary() {
    return this.reportsService.getSummary();
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Get()
  getReportsList(@Query('status') status?: ReportStatus) {
    return this.reportsService.getReportsList(status);
  }

  @UseGuards(RolesGuard)
  @Roles(UserRole.ADMIN, UserRole.SUPER_ADMIN)
  @Patch(':id/status')
  updateReportStatus(@Param('id') id: string, @Body('status') status: ReportStatus) {
    return this.reportsService.updateReportStatus(id, status);
  }
}
