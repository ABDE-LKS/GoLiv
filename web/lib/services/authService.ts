import apiClient from '@/lib/api';
import { AuthResponse, User } from '@/types';

export const authService = {
  /**
   * Login — backend expects { phone, password } ONLY
   * Algerian phone format: 05XXXXXXXX / 06XXXXXXXX / 07XXXXXXXX
   * POST /api/v1/auth/login
   */
  async login(phone: string, password: string): Promise<AuthResponse> {
    const response = await apiClient.post('/auth/login', { phone, password });
    return response.data;
  },

  /**
   * Register — backend expects { firstName, lastName, phone, password, email? }
   * POST /api/v1/auth/register
   */
  async register(data: {
    firstName: string;
    lastName: string;
    phone: string;
    password: string;
    email?: string;
  }): Promise<AuthResponse> {
    const response = await apiClient.post('/auth/register', data);
    return response.data;
  },

  /**
   * Logout — invalidates refresh token on backend
   * POST /api/v1/auth/logout
   */
  async logout(): Promise<void> {
    await apiClient.post('/auth/logout');
  },

  /**
   * Get currently authenticated user profile
   * GET /api/v1/auth/me
   */
  async getCurrentUser(): Promise<User> {
    const response = await apiClient.get('/auth/me');
    return response.data;
  },
};
