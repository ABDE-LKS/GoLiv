import apiClient from '@/lib/api';
import { Service, ServiceFilters, PaginatedResponse } from '@/types';

export const servicesService = {
  async getServices(filters?: ServiceFilters): Promise<PaginatedResponse<Service>> {
    const response = await apiClient.get('/services', { params: filters });
    return response.data;
  },

  async getServiceById(id: string): Promise<Service> {
    const response = await apiClient.get(`/services/${id}`);
    return response.data;
  },

  async createService(data: FormData): Promise<Service> {
    const response = await apiClient.post('/services', data, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async updateService(id: string, data: Partial<Service>): Promise<Service> {
    const response = await apiClient.patch(`/services/${id}`, data);
    return response.data;
  },

  async deleteService(id: string): Promise<void> {
    await apiClient.delete(`/services/${id}`);
  },

  async getMyServices(filters?: Omit<ServiceFilters, 'location'>): Promise<PaginatedResponse<Service>> {
    const response = await apiClient.get('/services/my-services', { params: filters });
    return response.data;
  },

  async uploadServiceImages(serviceId: string, files: File[]): Promise<{ urls: string[] }> {
    const formData = new FormData();
    files.forEach((file) => formData.append('images', file));

    const response = await apiClient.post(`/services/${serviceId}/images`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
    return response.data;
  },

  async searchServices(query: string, filters?: ServiceFilters): Promise<PaginatedResponse<Service>> {
    const response = await apiClient.get('/services/search', {
      params: { q: query, ...filters },
    });
    return response.data;
  },

  async bookService(serviceId: string, data: {
    startDate: string;
    endDate: string;
    message: string;
  }): Promise<void> {
    await apiClient.post(`/services/${serviceId}/book`, data);
  },

  async reportService(serviceId: string, reason: string, description: string): Promise<void> {
    await apiClient.post(`/services/${serviceId}/report`, { reason, description });
  },
};
