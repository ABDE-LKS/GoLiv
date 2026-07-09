import apiClient from '@/lib/api';
import { Ad, AdDetail, AdFilters, PaginatedResponse } from '@/types';

export const adsService = {
  async getAds(filters?: AdFilters): Promise<PaginatedResponse<Ad>> {
    const response = await apiClient.get('/ads', { params: filters });
    return response.data;
  },

  async getAdById(id: string): Promise<AdDetail> {
    const response = await apiClient.get(`/ads/${id}`);
    return response.data;
  },

  async createAd(data: FormData): Promise<Ad> {
    const response = await apiClient.post('/ads', data, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async updateAd(id: string, data: Partial<Ad>): Promise<Ad> {
    const response = await apiClient.patch(`/ads/${id}`, data);
    return response.data;
  },

  async deleteAd(id: string): Promise<void> {
    await apiClient.delete(`/ads/${id}`);
  },

  async getMyAds(filters?: Omit<AdFilters, 'location'>): Promise<PaginatedResponse<Ad>> {
    const response = await apiClient.get('/ads/my-ads', { params: filters });
    return response.data;
  },

  async uploadAdImages(adId: string, files: File[]): Promise<{ urls: string[] }> {
    const formData = new FormData();
    files.forEach((file) => formData.append('images', file));

    const response = await apiClient.post(`/ads/${adId}/images`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async incrementAdViews(adId: string): Promise<void> {
    await apiClient.post(`/ads/${adId}/view`);
  },

  async searchAds(query: string, filters?: AdFilters): Promise<PaginatedResponse<Ad>> {
    const response = await apiClient.get('/ads/search', {
      params: { q: query, ...filters },
    });
    return response.data;
  },

  async reportAd(adId: string, reason: string, description: string): Promise<void> {
    await apiClient.post(`/ads/${adId}/report`, { reason, description });
  },
};
