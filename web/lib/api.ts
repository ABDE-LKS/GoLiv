import axios, { AxiosInstance, AxiosError } from 'axios';
import { useAuthStore } from '@/stores/authStore';

let refreshPromise: Promise<string> | null = null;

// ✅ Backend is on port 3000 with /api/v1 prefix
// Frontend is on port 3001 — they are different ports on purpose
const API_BASE_URL = process.env.NEXT_PUBLIC_API_URL ?? 'http://localhost:3000/api/v1';

export const apiClient: AxiosInstance = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
  },
  withCredentials: true,
});

// ── Request interceptor: attach JWT ──────────────────────────────────────────
apiClient.interceptors.request.use(
  (config) => {
    const { accessToken } = useAuthStore.getState();
    if (accessToken) {
      config.headers.Authorization = `Bearer ${accessToken}`;
    }
    return config;
  },
  (error) => Promise.reject(error)
);

// ── Response interceptor: unwrap { success, data } + handle 401 ──────────────
apiClient.interceptors.response.use(
  // The NestJS TransformInterceptor wraps every response as { success: true, data: <payload> }
  // Unwrap it here so all service methods receive the real payload directly
  (response) => {
    if (
      response.data &&
      typeof response.data === 'object' &&
      'success' in response.data &&
      'data' in response.data
    ) {
      response.data = response.data.data;
    }
    return response;
  },
  async (error: AxiosError) => {
    const originalRequest = error.config as any;

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;

      try {
        if (!refreshPromise) {
          refreshPromise = refreshAccessToken();
        }

        const newAccessToken = await refreshPromise;
        refreshPromise = null;

        useAuthStore.getState().setAccessToken(newAccessToken);
        originalRequest.headers.Authorization = `Bearer ${newAccessToken}`;
        return apiClient(originalRequest);
      } catch (refreshError) {
        refreshPromise = null;
        useAuthStore.getState().logout();
        if (typeof window !== 'undefined') {
          window.location.href = '/ar/auth/login';
        }
        return Promise.reject(refreshError);
      }
    }

    return Promise.reject(error);
  }
);

/**
 * Refresh access token using refreshToken stored in Zustand.
 * Backend: POST /api/v1/auth/refresh  Body: { refreshToken }
 */
async function refreshAccessToken(): Promise<string> {
  const refreshToken = useAuthStore.getState().refreshToken;
  if (!refreshToken) throw new Error('No refresh token');

  const response = await axios.post(`${API_BASE_URL}/auth/refresh`, { refreshToken });
  const payload = response.data?.data ?? response.data;
  if (payload.refreshToken) {
    useAuthStore.getState().setRefreshToken(payload.refreshToken);
  }
  return payload.accessToken;
}

export default apiClient;
