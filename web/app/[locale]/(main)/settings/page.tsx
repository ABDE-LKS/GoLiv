'use client';

import { useParams } from 'next/navigation';
import { t, Locale } from '@/lib/i18n';

import { useState } from 'react';
import { useAuthStore } from '@/stores/authStore';
import { useUIStore } from '@/stores/uiStore';
import { Bell, Lock, Eye, Moon, Sun, LogOut } from 'lucide-react';
import { useRouter } from 'next/navigation';

export default function SettingsPage() {
  const router = useRouter();
  const { user, logout } = useAuthStore();
  const { isDarkMode, toggleDarkMode } = useUIStore();
  const [formData, setFormData] = useState({
    firstName: user?.firstName || '',
    lastName: user?.lastName || '',
    email: user?.email || '',
    phone: user?.phone || '',
  });

  const handleLogout = () => {
    logout();
    router.push('/auth/login');
  };

  return (
    <div className="p-6 lg:p-8">
      <h1 className="text-3xl font-bold text-foreground mb-8">Settings</h1>

      <div className="max-w-2xl space-y-6">
        {/* Profile Settings */}
        <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
          <h2 className="text-xl font-semibold text-foreground mb-4">Profile Information</h2>
          <div className="space-y-4">
            <div className="grid md:grid-cols-2 gap-4">
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">
                  First Name
                </label>
                <input
                  type="text"
                  value={formData.firstName}
                  onChange={(e) =>
                    setFormData({ ...formData, firstName: e.target.value })
                  }
                  className="w-full px-4 py-2 border border-border rounded-lg bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
              <div>
                <label className="block text-sm font-medium text-foreground mb-2">
                  Last Name
                </label>
                <input
                  type="text"
                  value={formData.lastName}
                  onChange={(e) =>
                    setFormData({ ...formData, lastName: e.target.value })
                  }
                  className="w-full px-4 py-2 border border-border rounded-lg bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
                />
              </div>
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Email
              </label>
              <input
                type="email"
                value={formData.email}
                disabled
                className="w-full px-4 py-2 border border-border rounded-lg bg-muted text-foreground focus:outline-none"
              />
            </div>
            <div>
              <label className="block text-sm font-medium text-foreground mb-2">
                Phone
              </label>
              <input
                type="tel"
                value={formData.phone}
                onChange={(e) =>
                  setFormData({ ...formData, phone: e.target.value })
                }
                className="w-full px-4 py-2 border border-border rounded-lg bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
              />
            </div>
            <button className="px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors font-semibold">
              Save Changes
            </button>
          </div>
        </div>

        {/* Preferences */}
        <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
          <h2 className="text-xl font-semibold text-foreground mb-4">Preferences</h2>
          <div className="space-y-4">
            {/* Dark Mode */}
            <div className="flex items-center justify-between p-4 border border-border rounded-lg">
              <div className="flex items-center gap-3">
                {isDarkMode ? (
                  <Moon className="text-foreground" size={20} />
                ) : (
                  <Sun className="text-foreground" size={20} />
                )}
                <div>
                  <p className="font-medium text-foreground">Dark Mode</p>
                  <p className="text-sm text-muted-foreground">
                    {isDarkMode ? 'Enabled' : 'Disabled'}
                  </p>
                </div>
              </div>
              <button
                onClick={toggleDarkMode}
                className={`relative w-12 h-6 rounded-full transition-colors ${
                  isDarkMode ? 'bg-primary' : 'bg-gray-300'
                }`}
              >
                <div
                  className={`absolute top-1 w-4 h-4 bg-white rounded-full transition-transform ${
                    isDarkMode ? 'translate-x-6' : 'translate-x-1'
                  }`}
                ></div>
              </button>
            </div>

            {/* Notifications */}
            <div className="flex items-center justify-between p-4 border border-border rounded-lg">
              <div className="flex items-center gap-3">
                <Bell className="text-foreground" size={20} />
                <div>
                  <p className="font-medium text-foreground">Notifications</p>
                  <p className="text-sm text-muted-foreground">Receive push notifications</p>
                </div>
              </div>
              <div className="relative w-12 h-6 bg-primary rounded-full">
                <div className="absolute top-1 right-1 w-4 h-4 bg-white rounded-full"></div>
              </div>
            </div>
          </div>
        </div>

        {/* Security */}
        <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
          <h2 className="text-xl font-semibold text-foreground mb-4">Security</h2>
          <div className="space-y-3">
            <button className="w-full flex items-center gap-3 px-4 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors">
              <Lock size={18} />
              <span>Change Password</span>
            </button>
            <button className="w-full flex items-center gap-3 px-4 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors">
              <Eye size={18} />
              <span>Privacy Settings</span>
            </button>
          </div>
        </div>

        {/* Logout */}
        <button
          onClick={handleLogout}
          className="w-full flex items-center justify-center gap-2 px-4 py-3 bg-red-600 text-white rounded-lg hover:bg-red-700 transition-colors font-semibold"
        >
          <LogOut size={20} />
          Logout
        </button>
      </div>
    </div>
  );
}
