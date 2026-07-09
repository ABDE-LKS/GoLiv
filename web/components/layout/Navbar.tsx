'use client';

import Link from 'next/link';
import { useRouter } from 'next/navigation';
import { useAuthStore } from '@/stores/authStore';
import { useUIStore } from '@/stores/uiStore';
import { Menu, Bell, User, LogOut, Moon, Sun, Search, ChevronDown } from 'lucide-react';
import { useState } from 'react';

interface NavbarProps {
  onMenuToggle: () => void;
}

export default function Navbar({ onMenuToggle }: NavbarProps) {
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const { isDarkMode, toggleDarkMode } = useUIStore();
  const [isProfileOpen, setIsProfileOpen] = useState(false);

  const handleLogout = async () => {
    logout();
    router.push('/auth/login');
  };

  const initials = user ? `${user.firstName?.[0]}${user.lastName?.[0]}`.toUpperCase() : '?';

  return (
    <nav className="sticky top-0 z-40 border-b border-border bg-card/80 backdrop-blur-sm">
      <div className="px-4 sm:px-6 lg:px-8 py-3">
        <div className="flex items-center justify-between gap-4">
          {/* Left: Menu & Logo */}
          <div className="flex items-center gap-4">
            <button
              onClick={onMenuToggle}
              className="lg:hidden p-2 hover:bg-muted rounded-lg transition-colors"
              aria-label="Toggle menu"
            >
              <Menu size={20} className="text-foreground" />
            </button>
            <Link href="/" className="text-xl font-bold text-primary flex-shrink-0">
              GoLiv
            </Link>
          </div>

          {/* Center: Search */}
          <div className="hidden md:flex flex-1 max-w-md">
            <div className="w-full relative">
              <Search className="absolute left-3 top-2.5 text-muted-foreground" size={18} />
              <input
                type="text"
                placeholder="Search listings..."
                className="input-base pl-10 text-sm"
              />
            </div>
          </div>

          {/* Right: Actions */}
          <div className="flex items-center gap-1 sm:gap-2">
            {/* Notifications */}
            <button 
              className="p-2 hover:bg-muted rounded-lg transition-colors relative"
              aria-label="Notifications"
            >
              <Bell size={20} className="text-foreground" />
              <span className="absolute top-1 right-1 w-2 h-2 bg-danger rounded-full"></span>
            </button>

            {/* Theme Toggle */}
            <button
              onClick={toggleDarkMode}
              className="p-2 hover:bg-muted rounded-lg transition-colors"
              aria-label="Toggle theme"
            >
              {isDarkMode ? (
                <Sun size={20} className="text-foreground" />
              ) : (
                <Moon size={20} className="text-foreground" />
              )}
            </button>

            {/* Profile Menu */}
            <div className="relative ml-2">
              <button
                onClick={() => setIsProfileOpen(!isProfileOpen)}
                className="flex items-center gap-2 px-2 py-1.5 hover:bg-muted rounded-lg transition-colors"
              >
                <div className="w-8 h-8 bg-primary text-primary-foreground rounded-full flex items-center justify-center text-xs font-bold">
                  {initials}
                </div>
                <ChevronDown size={16} className="text-muted-foreground hidden sm:block" />
              </button>

              {/* Dropdown Menu */}
              {isProfileOpen && (
                <div className="absolute right-0 mt-1 w-48 bg-card border border-border rounded-lg shadow-elevated z-50 overflow-hidden">
                  <Link
                    href="/profile"
                    className="flex items-center gap-3 px-4 py-2.5 hover:bg-muted transition-colors border-b border-border text-sm"
                    onClick={() => setIsProfileOpen(false)}
                  >
                    <User size={16} />
                    <span>My Profile</span>
                  </Link>
                  <button
                    onClick={handleLogout}
                    className="w-full flex items-center gap-3 px-4 py-2.5 hover:bg-muted transition-colors text-danger text-sm"
                  >
                    <LogOut size={16} />
                    <span>Logout</span>
                  </button>
                </div>
              )}
            </div>
          </div>
        </div>
      </div>
    </nav>
  );
}
