'use client';

import { useParams } from 'next/navigation';
import { t, Locale } from '@/lib/i18n';

import { useAuthStore } from '@/stores/authStore';
import { Edit2, Phone, MapPin, Calendar, Star } from 'lucide-react';
import Link from 'next/link';

export default function ProfilePage() {
  const { user } = useAuthStore();

  return (
    <div className="p-6 lg:p-8">
      <div className="max-w-2xl">
        {/* Header */}
        <div className="bg-white dark:bg-card rounded-lg border border-border p-6 mb-6">
          <div className="flex items-start justify-between mb-6">
            <div className="flex gap-4">
              <div className="w-20 h-20 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-bold text-2xl">
                {user?.firstName?.[0]}{user?.lastName?.[0]}
              </div>
              <div>
                <h1 className="text-2xl font-bold text-foreground">
                  {user?.firstName} {user?.lastName}
                </h1>
                <p className="text-muted-foreground">Member since 2023</p>
              </div>
            </div>
            <Link
              href="/settings"
              className="px-4 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors flex items-center gap-2"
            >
              <Edit2 size={18} />
              Edit Profile
            </Link>
          </div>

          {/* Info Grid */}
          <div className="grid md:grid-cols-2 gap-4">
            <div>
              <p className="text-sm text-muted-foreground mb-1">Email</p>
              <p className="font-medium text-foreground">{user?.email}</p>
            </div>
            <div>
              <p className="text-sm text-muted-foreground mb-1">Phone</p>
              <p className="font-medium text-foreground">{user?.phone}</p>
            </div>
          </div>
        </div>

        {/* Stats */}
        <div className="grid md:grid-cols-3 gap-4 mb-6">
          <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
            <p className="text-sm text-muted-foreground mb-1">Rating</p>
            <div className="flex items-center gap-2">
              <span className="text-2xl font-bold text-foreground">{user?.rating || 0}</span>
              <div className="flex gap-1">
                {[...Array(5)].map((_, i) => (
                  <Star
                    key={i}
                    size={16}
                    className={i < Math.round(user?.rating || 0) ? 'fill-yellow-400 text-yellow-400' : 'text-muted-foreground'}
                  />
                ))}
              </div>
            </div>
            <p className="text-xs text-muted-foreground mt-2">
              ({user?.reviewCount || 0} reviews)
            </p>
          </div>

          <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
            <p className="text-sm text-muted-foreground mb-1">Active Listings</p>
            <p className="text-2xl font-bold text-foreground">0</p>
          </div>

          <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
            <p className="text-sm text-muted-foreground mb-1">Sales</p>
            <p className="text-2xl font-bold text-foreground">0</p>
          </div>
        </div>

        {/* Bio */}
        {user?.bio && (
          <div className="bg-white dark:bg-card rounded-lg border border-border p-6 mb-6">
            <h3 className="font-semibold text-foreground mb-2">About</h3>
            <p className="text-foreground">{user.bio}</p>
          </div>
        )}

        {/* Links */}
        <div className="grid md:grid-cols-2 gap-4">
          <Link
            href="/my-listings"
            className="px-6 py-3 border border-border text-foreground rounded-lg hover:bg-muted transition-colors text-center font-semibold"
          >
            My Listings
          </Link>
          <Link
            href="/settings"
            className="px-6 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors text-center font-semibold"
          >
            Settings
          </Link>
        </div>
      </div>
    </div>
  );
}
