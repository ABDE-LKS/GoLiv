import { Controller, Get, Post, Body, Patch, Param, Delete, Query, UseGuards, Req } from '@nestjs/common';
import { JobsService } from './jobs.service';
import { CreateJobDto } from './dto/create-job.dto';
import { UpdateJobDto } from './dto/update-job.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';
import { CurrentUser } from '../../common/decorators/current-user.decorator';

@Controller('jobs')
export class JobsController {
  constructor(private readonly jobsService: JobsService) {}

  @Get('categories')
  getCategories() {
    return this.jobsService.getCategories();
  }

  @UseGuards(JwtAuthGuard)
  @Get('my')
  getMyJobs(@CurrentUser() user: any) {
    return this.jobsService.getMyJobs(user.id);
  }

  @UseGuards(JwtAuthGuard)
  @Post(':id/save')
  toggleSave(@Param('id') id: string, @CurrentUser() user: any) {
    return this.jobsService.toggleSave(user.id, id);
  }

  @UseGuards(JwtAuthGuard)
  @Post()
  create(@CurrentUser() user: any, @Body() createJobDto: CreateJobDto) {
    return this.jobsService.create(user.id, createJobDto);
  }

  @Get()
  findAll(@Query() query: any) {
    return this.jobsService.findAll(query);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.jobsService.findOne(id);
  }

  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(@CurrentUser() user: any, @Param('id') id: string, @Body() updateJobDto: UpdateJobDto) {
    return this.jobsService.update(user.id, id, updateJobDto);
  }

  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@CurrentUser() user: any, @Param('id') id: string) {
    return this.jobsService.remove(user.id, id);
  }
}
