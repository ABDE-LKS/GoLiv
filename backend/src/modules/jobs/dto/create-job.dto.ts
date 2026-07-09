import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';
import { EmploymentType } from '@prisma/client';

export class CreateJobDto {
  @IsString()
  @IsNotEmpty()
  categoryId: string;

  @IsString()
  @IsNotEmpty()
  title: string;

  @IsString()
  @IsNotEmpty()
  companyName: string;

  @IsString()
  @IsOptional()
  logo?: string;

  @IsString()
  @IsNotEmpty()
  location: string;

  @IsString()
  @IsNotEmpty()
  description: string;

  @IsString()
  @IsNotEmpty()
  requirements: string;

  @IsEnum(EmploymentType)
  @IsNotEmpty()
  employmentType: EmploymentType;

  @IsString()
  @IsOptional()
  salary?: string;

  @IsString()
  @IsOptional()
  workingHours?: string;

  @IsString()
  @IsOptional()
  contactEmail?: string;

  @IsString()
  @IsOptional()
  contactPhone?: string;

  @IsString()
  @IsOptional()
  contactWhatsapp?: string;
}
