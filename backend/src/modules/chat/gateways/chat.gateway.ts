import {
  WebSocketGateway,
  WebSocketServer,
  SubscribeMessage,
  OnGatewayConnection,
  OnGatewayDisconnect,
  MessageBody,
  ConnectedSocket,
} from '@nestjs/websockets';
import { Server, Socket } from 'socket.io';
import { Logger, UseGuards } from '@nestjs/common';
import { ConversationsService } from '../../conversations/conversations.service';
import { JwtService } from '@nestjs/jwt';

@WebSocketGateway({
  cors: {
    origin: '*',
  },
  namespace: 'chat',
})
export class ChatGateway implements OnGatewayConnection, OnGatewayDisconnect {
  @WebSocketServer()
  server: Server;

  private logger = new Logger('ChatGateway');
  private connectedUsers = new Map<string, string>(); // userId -> socketId

  constructor(
    private readonly conversationsService: ConversationsService,
    private readonly jwtService: JwtService,
  ) {}

  async handleConnection(client: Socket) {
    try {
      const token = client.handshake.headers.authorization?.split(' ')[1] || client.handshake.auth?.token;
      if (!token) {
        client.disconnect();
        return;
      }
      const payload = await this.jwtService.verifyAsync(token, {
        secret: process.env.JWT_SECRET || 'secret',
      });
      client.data.userId = payload.sub;
      this.connectedUsers.set(payload.sub, client.id);
      this.logger.log(`Client connected: ${client.id} (User: ${payload.sub})`);
      
      // Update online status
      this.server.emit('userStatus', { userId: payload.sub, status: 'online' });
    } catch (e) {
      this.logger.error(`Connection error: ${e.message}`);
      client.disconnect();
    }
  }

  handleDisconnect(client: Socket) {
    const userId = client.data.userId;
    if (userId) {
      this.connectedUsers.delete(userId);
      this.server.emit('userStatus', { userId, status: 'offline' });
    }
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinConversation')
  handleJoinConversation(
    @MessageBody() conversationId: string,
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`conv_${conversationId}`);
    this.logger.log(`Client ${client.id} joined conv_${conversationId}`);
  }

  @SubscribeMessage('sendMessage')
  async handleMessage(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string; text: string; image?: string },
  ) {
    const userId = client.data.userId;
    if (!userId) return;

    const message = await this.conversationsService.sendMessage(userId, data.conversationId, {
      text: data.text,
      image: data.image,
    });

    this.server.to(`conv_${data.conversationId}`).emit('newMessage', message);
    
    // Also notify the specific user room for unread badges etc.
    // (Optional: can emit to a per-user room if we implement that)
  }

  @SubscribeMessage('typing')
  handleTyping(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string; isTyping: boolean },
  ) {
    const userId = client.data.userId;
    client.to(`conv_${data.conversationId}`).emit('userTyping', {
      conversationId: data.conversationId,
      userId,
      isTyping: data.isTyping,
    });
  }

  @SubscribeMessage('markAsRead')
  async handleMarkAsRead(
    @ConnectedSocket() client: Socket,
    @MessageBody() data: { conversationId: string },
  ) {
    const userId = client.data.userId;
    if (!userId) return;

    // This logic is already in getConversationMessages, 
    // but for real-time seen events, we can trigger it here too.
    await this.conversationsService.getConversationMessages(userId, data.conversationId);
    
    client.to(`conv_${data.conversationId}`).emit('messagesSeen', {
      conversationId: data.conversationId,
      userId,
    });
  }
}
