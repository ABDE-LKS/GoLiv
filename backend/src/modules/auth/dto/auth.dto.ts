import { ApiProperty } from '@nestjs/swagger';
import { IsNotEmpty, IsString, IsOptional, Matches } from 'class-validator';

export class RegisterDto {
  @ApiProperty({ example: 'احمد' })
  @IsNotEmpty()
  @IsString()
  firstName: string;

  @ApiProperty({ example: 'دحماني' })
  @IsNotEmpty()
  @IsString()
  lastName: string;

  @ApiProperty({ example: '0550123456' })
  @IsNotEmpty()
  @Matches(/^(05|06|07)[0-9]{8}$/, { message: 'Invalid Algerian phone number' })
  phone: string;

  @ApiProperty({ example: 'password123' })
  @IsNotEmpty()
  @IsString()
  password: string;

  @ApiProperty({ example: 'ahmad@example.com', required: false })
  @IsOptional()
  @IsString()
  email?: string;
}

export class LoginDto {
  @ApiProperty({ example: '0550123456' })
  @IsNotEmpty()
  @IsString()
  phone: string;

  @ApiProperty({ example: 'password123' })
  @IsNotEmpty()
  @IsString()
  password: string;
}
