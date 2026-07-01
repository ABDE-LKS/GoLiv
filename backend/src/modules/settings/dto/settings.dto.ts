import { IsString, IsOptional } from 'class-validator';

export class UpdateSettingDto {
  @IsString()
  key: string;

  @IsString()
  value: string;
}

export class UpdateSettingsBulkDto {
  @IsOptional()
  @IsString()
  deliveryFee?: string;

  @IsOptional()
  @IsString()
  commissionPercentage?: string;

  @IsOptional()
  @IsString()
  maintenanceMode?: string;

  @IsOptional()
  @IsString()
  appName?: string;
}
