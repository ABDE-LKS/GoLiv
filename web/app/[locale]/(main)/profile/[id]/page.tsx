'use client';

import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import { userService } from '@/lib/services/userService';
import { chatService } from '@/lib/services/chatService';
import Link from 'next/link';
import { MessageCircle, Star, Phone, MapPin, Calendar, Briefcase, Shield, Edit2, Flag } from 'lucide-react';
import { formatDate, getRelativeTime } from '@/lib/utils/helpers';

export default function ProfileDetailPage() {
  const params = useParams();
  const router = useRouter();
  const userId = params.id as string;

  const { data: userProfile, isLoading } = useQuery({
    queryKey: ['userProfile', userId],
    queryFn: () => userService.getUserProfile(userId),
  });

  const { data: userListings } = useQuery({
    queryKey: ['userListings', userId],
    queryFn: () => userService.getUserListings(userId),
  });

  const handleContactUser = async () => {
    try {
      const conversation = await chatService.createConversation(userId);
      router.push(`/messages/${conversation.id}`);
    } catch (error) {
      console.error('Error creating conversation:', error);
    }
  };

  if (isLoading) {
    return (
      <div className="p-6 lg:p-8 flex items-center justify-center min-h-screen">
        <div className="animate-spin">
          <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
        </div>
      </div>
    );
  }

  if (!userProfile) {
    return (
      <div className="p-6 lg:p-8">
        <p className="text-muted-foreground">User not found</p>
      </div>
    );
  }

  return (
    <div className="p-6 lg:p-8">
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Main Content */}
        <div className="lg:col-span-2">
          {/* Profile Header */}
          <div className="bg-white dark:bg-card rounded-lg border border-border p-6 mb-6">
            <div className="flex items-start justify-between mb-6">
              <div className="flex gap-4">
                <div className="w-20 h-20 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-bold text-2xl">
                  {userProfile.firstName?.[0]}{userProfile.lastName?.[0]}
                </div>
                <div>
                  <h1 className="text-2xl font-bold text-foreground">
                    {userProfile.firstName} {userProfile.lastName}
                  </h1>
                  <div className="flex items-center gap-2 mt-2">
                    {userProfile.isVerified && (
                      <div className="flex items-center gap-1 px-2 py-1 bg-green-100 dark:bg-green-900/20 text-green-700 dark:text-green-400 rounded-full text-sm">
                        <Shield size={14} />
                        <span>Verified</span>
                      </div>
                    )}
                    {userProfile.role && (
                      <span className="text-sm text-muted-foreground capitalize">
                        {userProfile.role.toLowerCase()}
                      </span>
                    )}
                  </div>
                </div>
              </div>
            </div>

            {/* Info Grid */}
            <div className="grid md:grid-cols-2 gap-4 mb-6">
              <div>
                <p className="text-sm text-muted-foreground mb-1">Email</p>
                <p className="font-medium text-foreground">{userProfile.email}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground mb-1">Phone</p>
                <p className="font-medium text-foreground">{userProfile.phone}</p>
              </div>
              <div>
                <p className="text-sm text-muted-foreground mb-1">Member Since</p>
                <p className="font-medium text-foreground">{formatDate(userProfile.createdAt)}</p>
              </div>
              {userProfile.rating && (
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Rating</p>
                  <div className="flex items-center gap-2">
                    <span className="font-medium text-foreground">{userProfile.rating}/5</span>
                    <div className="flex gap-1">
                      {[...Array(5)].map((_, i) => (
                        <Star
                          key={i}
                          size={14}
                          className={
                            i < Math.floor(userProfile.rating || 0)
                              ? 'fill-yellow-400 text-yellow-400'
                              : 'text-muted-foreground'
                          }
                        />
                      ))}
                    </div>
                  </div>
                </div>
              )}
            </div>

            {/* Bio */}
            {userProfile.bio && (
              <div className="pt-6 border-t border-border">
                <h3 className="font-semibold text-foreground mb-2">About</h3>
                <p className="text-foreground">{userProfile.bio}</p>
              </div>
            )}
          </div>

          {/* Recent Listings */}
          {userListings && userListings.length > 0 && (
            <div className="bg-white dark:bg-card rounded-lg border border-border p-6 mb-6">
              <h3 className="font-semibold text-foreground mb-4">Recent Listings</h3>
              <div className="grid md:grid-cols-2 gap-4">
                {userListings.slice(0, 4).map((listing: any) => (
                  <Link
                    key={listing.id}
                    href={`/marketplace/${listing.id}`}
                    className="group rounded-lg border border-border overflow-hidden hover:shadow-lg transition-shadow"
                  >
                    <div className="relative w-full h-32 bg-muted">
                      {listing.images?.[0] ? (
                        <img
                          src={listing.images[0]}
                          alt={listing.title}
                          className="w-full h-full object-cover group-hover:scale-105 transition-transform"
                        />
                      ) : (
                        <div className="w-full h-full bg-gradient-to-br from-orange-100 to-orange-200 dark:from-orange-900/20 dark:to-orange-900/10"></div>
                      )}
                    </div>
                    <div className="p-3">
                      <h4 className="font-medium text-foreground text-sm line-clamp-2 group-hover:text-primary transition-colors">
                        {listing.title}
                      </h4>
                      <p className="text-primary font-semibold text-sm mt-1">
                        ${listing.price}
                      </p>
                    </div>
                  </Link>
                ))}
              </div>
            </div>
          )}

          {/* Stats */}
          <div className="grid md:grid-cols-3 gap-4">
            <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
              <p className="text-sm text-muted-foreground mb-2">Active Listings</p>
              <p className="text-3xl font-bold text-foreground">{userListings?.length || 0}</p>
            </div>

            <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
              <p className="text-sm text-muted-foreground mb-2">Reviews</p>
              <p className="text-3xl font-bold text-foreground">{userProfile.reviewCount || 0}</p>
            </div>

            <div className="bg-white dark:bg-card rounded-lg border border-border p-6">
              <p className="text-sm text-muted-foreground mb-2">Response Rate</p>
              <p className="text-3xl font-bold text-foreground">98%</p>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div>
          {/* Contact Card */}
          <div className="bg-white dark:bg-card rounded-lg border border-border p-6 sticky top-24">
            <button
              onClick={handleContactUser}
              className="w-full px-4 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors font-semibold mb-3 flex items-center justify-center gap-2"
            >
              <MessageCircle size={20} />
              Contact
            </button>

            <div className="space-y-3 pt-6 border-t border-border">
              <div className="flex items-center gap-3">
                <div className="p-2 bg-muted rounded-lg">
                  <Star size={20} className="text-primary" />
                </div>
                <div>
                  <p className="text-sm font-medium text-foreground">Seller Rating</p>
                  <p className="text-xs text-muted-foreground">
                    {userProfile.rating ? `${userProfile.rating}/5` : 'No ratings yet'}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="p-2 bg-muted rounded-lg">
                  <Briefcase size={20} className="text-primary" />
                </div>
                <div>
                  <p className="text-sm font-medium text-foreground">Items Sold</p>
                  <p className="text-xs text-muted-foreground">
                    {userListings?.filter((l: any) => l.status === 'SOLD').length || 0}
                  </p>
                </div>
              </div>

              <div className="flex items-center gap-3">
                <div className="p-2 bg-muted rounded-lg">
                  <Calendar size={20} className="text-primary" />
                </div>
                <div>
                  <p className="text-sm font-medium text-foreground">Member Since</p>
                  <p className="text-xs text-muted-foreground">
                    {new Date(userProfile.createdAt).getFullYear()}
                  </p>
                </div>
              </div>
            </div>
          </div>

          {/* Report Card */}
          <div className="bg-white dark:bg-card rounded-lg border border-red-200 dark:border-red-900/20 p-6 mt-4">
            <button className="w-full px-4 py-2 border border-red-200 text-red-600 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors flex items-center justify-center gap-2 text-sm font-medium">
              <Flag size={18} />
              Report User
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
