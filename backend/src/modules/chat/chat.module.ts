import { Module } from '@nestjs/common';
import { ChatGateway } from './gateways/chat.gateway';
import { ConversationsModule } from '../conversations/conversations.module';
import { AuthModule } from '../auth/auth.module';

@Module({
  imports: [ConversationsModule, AuthModule],
  providers: [ChatGateway],
  exports: [ChatGateway],
})
export class ChatModule {}
