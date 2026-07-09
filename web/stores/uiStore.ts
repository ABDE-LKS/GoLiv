import { create } from 'zustand';

interface UIStore {
  isDarkMode: boolean;
  isMobileMenuOpen: boolean;
  selectedLocale: 'en' | 'ar';
  isRTL: boolean;

  // Actions
  toggleDarkMode: () => void;
  setDarkMode: (isDark: boolean) => void;
  toggleMobileMenu: () => void;
  setMobileMenuOpen: (isOpen: boolean) => void;
  setLocale: (locale: 'en' | 'ar') => void;
}

export const useUIStore = create<UIStore>((set, get) => ({
  isDarkMode: false,
  isMobileMenuOpen: false,
  selectedLocale: 'en',
  isRTL: false,

  toggleDarkMode: () => {
    set((state) => {
      const isDark = !state.isDarkMode;
      if (typeof window !== 'undefined') {
        if (isDark) {
          document.documentElement.classList.add('dark');
        } else {
          document.documentElement.classList.remove('dark');
        }
      }
      return { isDarkMode: isDark };
    });
  },

  setDarkMode: (isDark: boolean) => {
    set({ isDarkMode: isDark });
    if (typeof window !== 'undefined') {
      if (isDark) {
        document.documentElement.classList.add('dark');
      } else {
        document.documentElement.classList.remove('dark');
      }
    }
  },

  toggleMobileMenu: () => {
    set((state) => ({ isMobileMenuOpen: !state.isMobileMenuOpen }));
  },

  setMobileMenuOpen: (isOpen: boolean) => {
    set({ isMobileMenuOpen: isOpen });
  },

  setLocale: (locale: 'en' | 'ar') => {
    set({
      selectedLocale: locale,
      isRTL: locale === 'ar',
    });
  },
}));
