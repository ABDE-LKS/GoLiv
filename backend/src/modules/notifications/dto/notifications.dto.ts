import { IsString, IsOptional, IsEnum } from 'class-validator';

export enum NotificationTarget {
  ALL = 'ALL',
  CUSTOMERS = 'CUSTOMERS',
  DRIVERS = 'DRIVERS',
  STORES = 'STORES',
}

export class BroadcastNotificationDto {
  @IsString()
  title: string;

  @IsString()
  body: string;

  @IsEnum(NotificationTarget)
  target: NotificationTarget;

  @IsOptional()
  @IsString()
  type?: string;
}
