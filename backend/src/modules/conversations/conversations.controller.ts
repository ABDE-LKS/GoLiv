import { Controller, Get, Post, Body, Param, UseGuards, Req } from '@nestjs/common';
import { ConversationsService } from './conversations.service';
import { CreateConversationDto, SendMessageDto } from './dto/create-conversation.dto';
import { JwtAuthGuard } from '../../common/guards/jwt-auth.guard';

@Controller('conversations')
@UseGuards(JwtAuthGuard)
export class ConversationsController {
  constructor(private readonly conversationsService: ConversationsService) {}

  @Post()
  startConversation(@Req() req: any, @Body() dto: CreateConversationDto) {
    return this.conversationsService.createConversationOrSendMessage(req.user.id, dto);
  }

  @Post(':id/messages')
  sendMessage(@Req() req: any, @Param('id') conversationId: string, @Body() dto: SendMessageDto) {
    return this.conversationsService.sendMessage(req.user.id, conversationId, dto);
  }

  @Get()
  getUserConversations(@Req() req: any) {
    return this.conversationsService.getUserConversations(req.user.id);
  }

  @Get(':id/messages')
  getMessages(@Req() req: any, @Param('id') conversationId: string) {
    return this.conversationsService.getConversationMessages(req.user.id, conversationId);
  }
}
