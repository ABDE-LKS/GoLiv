import apiClient from '@/lib/api';
import { User, Review, PaginatedResponse } from '@/types';

export const userService = {
  async getUserProfile(userId: string): Promise<User> {
    const response = await apiClient.get(`/users/${userId}`);
    return response.data;
  },

  async getUserListings(userId: string, limit: number = 50, offset: number = 0): Promise<any[]> {
    const response = await apiClient.get(`/users/${userId}/listings`, {
      params: { limit, offset },
    });
    return response.data;
  },

  async getUserReviews(userId: string, limit: number = 50, offset: number = 0): Promise<PaginatedResponse<Review>> {
    const response = await apiClient.get(`/users/${userId}/reviews`, {
      params: { limit, offset },
    });
    return response.data;
  },

  async leaveReview(data: {
    revieweeId: string;
    rating: number;
    comment: string;
    itemType: 'AD' | 'SERVICE' | 'JOB';
    itemId: string;
  }): Promise<Review> {
    const response = await apiClient.post('/reviews', data);
    return response.data;
  },

  async updateReview(reviewId: string, data: Partial<Review>): Promise<Review> {
    const response = await apiClient.patch(`/reviews/${reviewId}`, data);
    return response.data;
  },

  async deleteReview(reviewId: string): Promise<void> {
    await apiClient.delete(`/reviews/${reviewId}`);
  },

  async uploadProfileImage(file: File): Promise<{ url: string }> {
    const formData = new FormData();
    formData.append('avatar', file);

    const response = await apiClient.post('/users/upload-avatar', formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async searchUsers(query: string, limit: number = 20): Promise<User[]> {
    const response = await apiClient.get('/users/search', {
      params: { q: query, limit },
    });
    return response.data;
  },

  async getNotifications(limit: number = 50, offset: number = 0): Promise<PaginatedResponse<any>> {
    const response = await apiClient.get('/notifications', {
      params: { limit, offset },
    });
    return response.data;
  },

  async markNotificationAsRead(notificationId: string): Promise<void> {
    await apiClient.patch(`/notifications/${notificationId}/mark-as-read`);
  },

  async deleteNotification(notificationId: string): Promise<void> {
    await apiClient.delete(`/notifications/${notificationId}`);
  },
};
