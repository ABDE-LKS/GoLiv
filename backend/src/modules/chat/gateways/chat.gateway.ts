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
import { Logger } from '@nestjs/common';

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

  handleConnection(client: Socket) {
    this.logger.log(`Client connected: ${client.id}`);
  }

  handleDisconnect(client: Socket) {
    this.logger.log(`Client disconnected: ${client.id}`);
  }

  @SubscribeMessage('joinOrder')
  handleJoinOrder(
    @MessageBody() orderId: string,
    @ConnectedSocket() client: Socket,
  ) {
    client.join(`order_${orderId}`);
    this.logger.log(`Client ${client.id} joined order_${orderId}`);
  }

  @SubscribeMessage('sendMessage')
  handleMessage(
    @MessageBody() data: { orderId: string; text: string; senderId: string },
  ) {
    // Save to DB here via service
    this.server.to(`order_${data.orderId}`).emit('newMessage', data);
  }

  @SubscribeMessage('typing')
  handleTyping(
    @MessageBody() data: { orderId: string; userId: string; isTyping: boolean },
  ) {
    this.server.to(`order_${data.orderId}`).emit('userTyping', data);
  }
}
