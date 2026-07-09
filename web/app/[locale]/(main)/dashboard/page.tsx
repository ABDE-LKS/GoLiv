'use client';

import { useEffect, useState } from 'react';
import { useParams } from 'next/navigation';
import Link from 'next/link';
import { useAuthStore } from '@/stores/authStore';
import { t, Locale } from '@/lib/i18n';
import { TrendingUp, MessageSquare, Heart, Package } from 'lucide-react';

export default function DashboardPage() {
  const params = useParams();
  const locale = (params.locale as Locale) || 'ar';
  const translate = (key: string) => t(locale, key);
  
  const { user } = useAuthStore();
  const [stats, setStats] = useState({
    activeListings: 0,
    messages: 3,
    favorites: 12,
    views: 245,
  });

  return (
    <div className="p-6 lg:p-8">
      {/* Header */}
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-foreground mb-2">
          Welcome back, {user?.firstName}!
        </h1>
        <p className="text-muted-foreground">Here&apos;s what&apos;s happening with your account today</p>
      </div>

      {/* Stats Grid */}
      <div className="grid md:grid-cols-4 gap-4 mb-8">
        {/* Active Listings */}
        <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-muted-foreground text-sm mb-1">Active Listings</p>
              <p className="text-3xl font-bold text-foreground">{stats.activeListings}</p>
            </div>
            <div className="bg-blue-100 dark:bg-blue-900/20 p-3 rounded-lg">
              <Package className="text-blue-600 dark:text-blue-400" size={24} />
            </div>
          </div>
        </div>

        {/* Messages */}
        <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-muted-foreground text-sm mb-1">New Messages</p>
              <p className="text-3xl font-bold text-foreground">{stats.messages}</p>
            </div>
            <div className="bg-green-100 dark:bg-green-900/20 p-3 rounded-lg">
              <MessageSquare className="text-green-600 dark:text-green-400" size={24} />
            </div>
          </div>
        </div>

        {/* Favorites */}
        <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-muted-foreground text-sm mb-1">Saved Favorites</p>
              <p className="text-3xl font-bold text-foreground">{stats.favorites}</p>
            </div>
            <div className="bg-pink-100 dark:bg-pink-900/20 p-3 rounded-lg">
              <Heart className="text-pink-600 dark:text-pink-400" size={24} />
            </div>
          </div>
        </div>

        {/* Views */}
        <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
          <div className="flex items-center justify-between">
            <div>
              <p className="text-muted-foreground text-sm mb-1">Total Views</p>
              <p className="text-3xl font-bold text-foreground">{stats.views}</p>
            </div>
            <div className="bg-orange-100 dark:bg-orange-900/20 p-3 rounded-lg">
              <TrendingUp className="text-orange-600 dark:text-orange-400" size={24} />
            </div>
          </div>
        </div>
      </div>

      {/* Quick Actions */}
      <div className="grid md:grid-cols-3 gap-6">
        {/* Recent Listings */}
        <div className="md:col-span-2 bg-white dark:bg-card rounded-lg p-6 border border-border">
          <h2 className="text-xl font-bold text-foreground mb-4">Recent Listings</h2>
          <div className="space-y-4">
            {[1, 2, 3].map((i) => (
              <div key={i} className="flex items-center gap-4 pb-4 border-b border-border last:border-0">
                <div className="w-16 h-16 bg-muted rounded-lg flex-shrink-0"></div>
                <div className="flex-1">
                  <h3 className="font-semibold text-foreground">iPhone 15 Pro</h3>
                  <p className="text-sm text-muted-foreground">Posted 2 days ago</p>
                </div>
                <span className="text-sm font-semibold text-primary">Active</span>
              </div>
            ))}
          </div>
        </div>

        {/* Quick Links */}
        <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
          <h2 className="text-xl font-bold text-foreground mb-4">Quick Links</h2>
          <div className="space-y-2">
            <Link
              href="/create-listing"
              className="block px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors text-center font-semibold"
            >
              Create Listing
            </Link>
            <Link
              href="/my-listings"
              className="block px-4 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors text-center"
            >
              My Listings
            </Link>
            <Link
              href="/marketplace"
              className="block px-4 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors text-center"
            >
              Browse Marketplace
            </Link>
            <Link
              href="/profile"
              className="block px-4 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors text-center"
            >
              My Profile
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
