'use client';

import { create } from 'zustand';
import { persist, createJSONStorage } from 'zustand/middleware';
import { User, AuthResponse } from '@/types';

interface AuthStore {
  user: User | null;
  accessToken: string | null;
  refreshToken: string | null;
  isLoading: boolean;
  error: string | null;

  // Actions
  setAuth: (data: AuthResponse) => void;
  setUser: (user: User) => void;
  setAccessToken: (token: string) => void;
  setRefreshToken: (token: string) => void;
  logout: () => void;
  setError: (error: string | null) => void;
  setLoading: (loading: boolean) => void;
  isAuthenticated: () => boolean;
}

export const useAuthStore = create<AuthStore>()(
  persist(
    (set, get) => ({
      user: null,
      accessToken: null,
      refreshToken: null,
      isLoading: false,
      error: null,

      setAuth: (data: AuthResponse) => {
        set({
          user: data.user,
          accessToken: data.accessToken,
          refreshToken: data.refreshToken ?? null,
          error: null,
        });
      },

      setUser: (user: User) => set({ user }),

      setAccessToken: (token: string) => set({ accessToken: token }),

      setRefreshToken: (token: string) => set({ refreshToken: token }),

      logout: () => {
        set({
          user: null,
          accessToken: null,
          refreshToken: null,
          error: null,
        });
      },

      setError: (error: string | null) => set({ error }),

      setLoading: (loading: boolean) => set({ isLoading: loading }),

      isAuthenticated: () => {
        const { user, accessToken } = get();
        return !!user && !!accessToken;
      },
    }),
    {
      name: 'goliv-auth',           // localStorage key
      storage: createJSONStorage(() => localStorage),
      // Only persist the essential auth fields, not loading/error state
      partialize: (state) => ({
        user: state.user,
        accessToken: state.accessToken,
        refreshToken: state.refreshToken,
      }),
    }
  )
);
