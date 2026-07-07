import { IsString, IsNotEmpty, IsOptional } from 'class-validator';

export class CreateConversationDto {
  @IsString()
  @IsNotEmpty()
  adId: string;

  @IsString()
  @IsNotEmpty()
  text: string;
}

export class SendMessageDto {
  @IsString()
  @IsOptional()
  text?: string;
  
  @IsString()
  @IsOptional()
  image?: string;
}
