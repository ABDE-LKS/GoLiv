import apiClient from '@/lib/api';
import { Job, PaginatedResponse } from '@/types';

export interface JobFilters {
  jobType?: string;
  location?: string;
  minSalary?: number;
  maxSalary?: number;
  sortBy?: 'NEWEST' | 'SALARY_HIGH' | 'SALARY_LOW';
  page?: number;
  limit?: number;
}

export const jobsService = {
  async getJobs(filters?: JobFilters): Promise<PaginatedResponse<Job>> {
    const response = await apiClient.get('/jobs', { params: filters });
    return response.data;
  },

  async getJobById(id: string): Promise<Job> {
    const response = await apiClient.get(`/jobs/${id}`);
    return response.data;
  },

  async createJob(data: Partial<Job>): Promise<Job> {
    const response = await apiClient.post('/jobs', data);
    return response.data;
  },

  async updateJob(id: string, data: Partial<Job>): Promise<Job> {
    const response = await apiClient.patch(`/jobs/${id}`, data);
    return response.data;
  },

  async deleteJob(id: string): Promise<void> {
    await apiClient.delete(`/jobs/${id}`);
  },

  async getMyJobs(filters?: Omit<JobFilters, 'location'>): Promise<PaginatedResponse<Job>> {
    const response = await apiClient.get('/jobs/my-jobs', { params: filters });
    return response.data;
  },

  async applyForJob(jobId: string, data: {
    message: string;
    resume?: File;
  }): Promise<void> {
    const formData = new FormData();
    formData.append('message', data.message);
    if (data.resume) {
      formData.append('resume', data.resume);
    }

    await apiClient.post(`/jobs/${jobId}/apply`, formData, {
      headers: {
        'Content-Type': 'multipart/form-data',
      },
    });
  },

  async searchJobs(query: string, filters?: JobFilters): Promise<PaginatedResponse<Job>> {
    const response = await apiClient.get('/jobs/search', {
      params: { q: query, ...filters },
    });
    return response.data;
  },

  async getJobApplications(jobId: string): Promise<any[]> {
    const response = await apiClient.get(`/jobs/${jobId}/applications`);
    return response.data;
  },
};
