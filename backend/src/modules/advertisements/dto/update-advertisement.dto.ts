import { PartialType } from '@nestjs/mapped-types';
import { CreateAdvertisementDto, AdStatus } from './create-advertisement.dto';
import { IsEnum, IsOptional } from 'class-validator';

export class UpdateAdvertisementDto extends PartialType(CreateAdvertisementDto) {
  @IsEnum(AdStatus)
  @IsOptional()
  status?: AdStatus;
}
