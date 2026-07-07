import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../../database/prisma.service';
import { CreateConversationDto, SendMessageDto } from './dto/create-conversation.dto';

@Injectable()
export class ConversationsService {
  constructor(private readonly prisma: PrismaService) {}

  async createConversationOrSendMessage(buyerId: string, { adId, text }: CreateConversationDto) {
    const ad = await this.prisma.advertisement.findUnique({ where: { id: adId } });
    if (!ad) throw new NotFoundException('Advertisement not found');

    let conversation = await this.prisma.conversation.findFirst({
      where: { adId, buyerId },
    });

    if (!conversation) {
      conversation = await this.prisma.conversation.create({
        data: {
          adId,
          buyerId,
          sellerId: ad.sellerId,
        },
      });
    }

    const message = await this.prisma.conversationMessage.create({
      data: {
        conversationId: conversation.id,
        senderId: buyerId,
        text,
      },
    });

    // Update conversation updatedAt timestamp
    await this.prisma.conversation.update({
      where: { id: conversation.id },
      data: { updatedAt: new Date() },
    });

    return { conversation, message };
  }

  async sendMessage(userId: string, conversationId: string, dto: SendMessageDto) {
    const conversation = await this.prisma.conversation.findUnique({
      where: { id: conversationId },
    });

    if (!conversation) throw new NotFoundException('Conversation not found');

    const message = await this.prisma.conversationMessage.create({
      data: {
        conversationId,
        senderId: userId,
        text: dto.text,
        image: dto.image,
      },
    });

    await this.prisma.conversation.update({
      where: { id: conversation.id },
      data: { updatedAt: new Date() },
    });

    return message;
  }

  async getUserConversations(userId: string) {
    return this.prisma.conversation.findMany({
      where: {
        OR: [{ buyerId: userId }, { sellerId: userId }],
      },
      include: {
        ad: { select: { id: true, title: true, images: { take: 1 } } },
        buyer: { select: { id: true, firstName: true, lastName: true, profilePhoto: true } },
        seller: { select: { id: true, firstName: true, lastName: true, profilePhoto: true } },
        messages: {
          orderBy: { createdAt: 'desc' },
          take: 1,
        },
      },
      orderBy: { updatedAt: 'desc' },
    });
  }

  async getConversationMessages(userId: string, conversationId: string) {
    const conversation = await this.prisma.conversation.findFirst({
      where: {
        id: conversationId,
        OR: [{ buyerId: userId }, { sellerId: userId }],
      },
    });

    if (!conversation) throw new NotFoundException('Conversation not found or unauthorized');

    // Mark as read asynchronously
    this.prisma.conversationMessage.updateMany({
      where: { conversationId, senderId: { not: userId }, isRead: false },
      data: { isRead: true }
    }).catch(() => {});

    return this.prisma.conversationMessage.findMany({
      where: { conversationId },
      orderBy: { createdAt: 'asc' },
    });
  }
}
