'use client';

import { useParams } from 'next/navigation';
import { t, Locale } from '@/lib/i18n';

import { useQuery } from '@tanstack/react-query';
import { adsService } from '@/lib/services/adsService';
import Link from 'next/link';
import { Plus, Edit2, Trash2, Eye } from 'lucide-react';
import Image from 'next/image';
import { formatPrice, getRelativeTime } from '@/lib/utils/helpers';
import { EmptyState } from '@/components/shared/EmptyState';

export default function MyListingsPage() {
  const { data, isLoading } = useQuery({
    queryKey: ['myAds'],
    queryFn: () => adsService.getMyAds({ limit: 50 }),
  });

  const ads = data?.data || [];

  return (
    <div className="p-6 lg:p-8">
      <div className="flex items-center justify-between mb-8">
        <h1 className="text-3xl font-bold text-foreground">My Listings</h1>
        <Link
          href="/create-listing"
          className="px-4 py-2 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors flex items-center gap-2 font-semibold"
        >
          <Plus size={20} />
          Create Listing
        </Link>
      </div>

      {isLoading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin">
            <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
          </div>
        </div>
      ) : ads.length === 0 ? (
        <EmptyState
          icon={Plus}
          title="No Listings Yet"
          description="You haven't created any listings yet. Start by creating your first listing to reach potential buyers."
          action={{
            label: 'Create First Listing',
            onClick: () => window.location.href = '/create-listing',
          }}
        />
      ) : (
        <div className="space-y-4">
          {ads.map((ad) => (
            <div
              key={ad.id}
              className="bg-white dark:bg-card rounded-lg border border-border overflow-hidden hover:shadow-lg transition-shadow"
            >
              <div className="flex gap-4 p-4">
                {/* Image */}
                <div className="relative w-24 h-24 flex-shrink-0 rounded-lg overflow-hidden bg-muted">
                  {ad.images && ad.images[0] ? (
                    <Image
                      src={ad.images[0]}
                      alt={ad.title}
                      fill
                      className="object-cover"
                    />
                  ) : (
                    <div className="w-full h-full bg-gradient-to-br from-orange-100 to-orange-200"></div>
                  )}
                </div>

                {/* Content */}
                <div className="flex-1">
                  <div className="flex items-start justify-between mb-2">
                    <h3 className="text-lg font-semibold text-foreground">{ad.title}</h3>
                    <span
                      className={`px-3 py-1 rounded-full text-sm font-semibold ${
                        ad.status === 'ACTIVE'
                          ? 'bg-green-100 dark:bg-green-900/20 text-green-600 dark:text-green-400'
                          : 'bg-gray-100 dark:bg-gray-900/20 text-gray-600 dark:text-gray-400'
                      }`}
                    >
                      {ad.status}
                    </span>
                  </div>

                  <p className="text-sm text-muted-foreground mb-3 line-clamp-1">
                    {ad.description}
                  </p>

                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-lg font-bold text-primary">{formatPrice(ad.price)}</p>
                      <p className="text-xs text-muted-foreground">
                        Posted {getRelativeTime(ad.createdAt)}
                      </p>
                    </div>

                    {/* Actions */}
                    <div className="flex gap-2">
                      <button className="p-2 hover:bg-muted rounded-lg transition-colors">
                        <Eye size={18} className="text-foreground" />
                      </button>
                      <Link
                        href={`/my-listings/${ad.id}/edit`}
                        className="p-2 hover:bg-muted rounded-lg transition-colors"
                      >
                        <Edit2 size={18} className="text-foreground" />
                      </Link>
                      <button className="p-2 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg transition-colors">
                        <Trash2 size={18} className="text-red-600" />
                      </button>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
