import { IsString, IsNumber, IsOptional, IsBoolean, IsEnum, IsArray } from 'class-validator';

export enum ItemCondition {
  new_condition = 'new_condition',
  used_like_new = 'used_like_new',
  used_good = 'used_good',
  used_fair = 'used_fair'
}

export enum AdStatus {
  ACTIVE = 'ACTIVE',
  SOLD = 'SOLD',
  HIDDEN = 'HIDDEN',
  DELETED = 'DELETED'
}

export class CreateAdvertisementDto {
  @IsString()
  categoryId: string;

  @IsString()
  title: string;

  @IsString()
  description: string;

  @IsNumber()
  price: number;

  @IsBoolean()
  @IsOptional()
  isNegotiable?: boolean;

  @IsEnum(ItemCondition)
  @IsOptional()
  condition?: ItemCondition;

  @IsString()
  location: string;

  @IsArray()
  @IsOptional()
  images?: { url: string }[];
}
