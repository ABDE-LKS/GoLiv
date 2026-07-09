import apiClient from '@/lib/api';
import { Conversation, Message, PaginatedResponse } from '@/types';

export const chatService = {
  async getConversations(limit: number = 50, offset: number = 0): Promise<PaginatedResponse<Conversation>> {
    const response = await apiClient.get('/conversations', {
      params: { limit, offset },
    });
    return response.data;
  },

  async getConversationById(id: string): Promise<Conversation> {
    const response = await apiClient.get(`/conversations/${id}`);
    return response.data;
  },

  async createConversation(userId: string): Promise<Conversation> {
    const response = await apiClient.post('/conversations', { userId });
    return response.data;
  },

  async getMessages(
    conversationId: string,
    limit: number = 50,
    offset: number = 0
  ): Promise<PaginatedResponse<Message>> {
    const response = await apiClient.get(`/conversations/${conversationId}/messages`, {
      params: { limit, offset },
    });
    return response.data;
  },

  async getConversationMessages(
    conversationId: string,
    limit: number = 50,
    offset: number = 0
  ): Promise<PaginatedResponse<Message>> {
    const response = await apiClient.get(`/conversations/${conversationId}/messages`, {
      params: { limit, offset },
    });
    return response.data;
  },

  async sendMessage(conversationId: string, data: {
    content: string;
    images?: File[];
  }): Promise<Message> {
    const formData = new FormData();
    formData.append('content', data.content);

    if (data.images) {
      data.images.forEach((file) => formData.append('images', file));
    }

    const response = await apiClient.post(`/conversations/${conversationId}/messages`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async markConversationAsRead(conversationId: string): Promise<void> {
    await apiClient.post(`/conversations/${conversationId}/mark-as-read`);
  },

  async markMessageAsRead(conversationId: string, messageId: string): Promise<void> {
    await apiClient.post(`/conversations/${conversationId}/messages/${messageId}/mark-as-read`);
  },

  async deleteMessage(conversationId: string, messageId: string): Promise<void> {
    await apiClient.delete(`/conversations/${conversationId}/messages/${messageId}`);
  },

  async deleteConversation(conversationId: string): Promise<void> {
    await apiClient.delete(`/conversations/${conversationId}`);
  },
};
