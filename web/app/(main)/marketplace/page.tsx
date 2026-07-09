'use client';

import { useEffect, useState } from 'react';
import { useQuery, useInfiniteQuery } from '@tanstack/react-query';
import { useInView } from 'react-intersection-observer';
import { adsService } from '@/lib/services/adsService';
import { Ad, AdCategory } from '@/types';
import Link from 'next/link';
import { Search, Filter, Heart, ShoppingCart } from 'lucide-react';
import Image from 'next/image';
import { formatPrice } from '@/lib/utils/helpers';

const categories: { value: AdCategory; label: string }[] = [
  { value: 'ELECTRONICS', label: 'Electronics' },
  { value: 'FURNITURE', label: 'Furniture' },
  { value: 'VEHICLES', label: 'Vehicles' },
  { value: 'REAL_ESTATE', label: 'Real Estate' },
  { value: 'CLOTHING', label: 'Clothing' },
  { value: 'OTHER', label: 'Other' },
];

export default function MarketplacePage() {
  const [selectedCategory, setSelectedCategory] = useState<AdCategory | undefined>();
  const [searchQuery, setSearchQuery] = useState('');
  const { ref, inView } = useInView();

  const {
    data,
    isLoading,
    hasNextPage,
    fetchNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['ads', selectedCategory, searchQuery],
    queryFn: async ({ pageParam = 1 }) => {
      const response = await adsService.getAds({
        category: selectedCategory,
        page: pageParam,
        limit: 20,
      });
      return response;
    },
    getNextPageParam: (lastPage) => {
      if (lastPage.hasMore) {
        return lastPage.page + 1;
      }
      return undefined;
    },
    initialPageParam: 1,
  });

  useEffect(() => {
    if (inView && hasNextPage && !isFetchingNextPage) {
      fetchNextPage();
    }
  }, [inView, hasNextPage, isFetchingNextPage, fetchNextPage]);

  const allAds = data?.pages.flatMap((page) => page.data) || [];

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      {/* Header */}
      <div className="mb-8 space-y-6">
        <div>
          <h1 className="heading-1 text-foreground mb-2">Marketplace</h1>
          <p className="subtitle">Browse thousands of local listings</p>
        </div>

        {/* Search & Filter */}
        <div className="flex flex-col sm:flex-row gap-3">
          <div className="flex-1 relative">
            <Search className="absolute left-4 top-3 text-muted-foreground" size={18} />
            <input
              type="text"
              placeholder="Search listings..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="input-base pl-11"
            />
          </div>

          <div className="flex gap-3 sm:w-auto">
            <button className="p-2.5 border border-border rounded-lg hover:bg-muted transition-colors" aria-label="Filters">
              <Filter size={18} className="text-foreground" />
            </button>
            <select
              value={selectedCategory || ''}
              onChange={(e) =>
                setSelectedCategory(e.target.value as AdCategory | undefined)
              }
              className="input-base sm:w-auto"
            >
              <option value="">All Categories</option>
              {categories.map((cat) => (
                <option key={cat.value} value={cat.value}>
                  {cat.label}
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Listings Grid */}
      {isLoading ? (
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {[...Array(8)].map((_, i) => (
            <div key={i} className="card overflow-hidden">
              <div className="skeleton h-48 w-full" />
              <div className="p-4 space-y-3">
                <div className="skeleton h-4 w-3/4" />
                <div className="skeleton h-3 w-full" />
                <div className="skeleton h-3 w-1/2" />
              </div>
            </div>
          ))}
        </div>
      ) : allAds.length === 0 ? (
        <div className="flex flex-col items-center justify-center py-16 text-center">
          <p className="heading-3 text-foreground mb-2">No listings found</p>
          <p className="subtitle">Try searching with different keywords or browse other categories</p>
        </div>
      ) : (
        <>
          <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
            {allAds.map((ad) => (
              <Link
                key={ad.id}
                href={`/marketplace/${ad.id}`}
                className="group card overflow-hidden hover:shadow-elevated transition-all duration-200 flex flex-col"
              >
                {/* Image */}
                <div className="relative w-full aspect-square bg-muted overflow-hidden">
                  {ad.images && ad.images[0] ? (
                    <Image
                      src={ad.images[0]}
                      alt={ad.title}
                      fill
                      className="object-cover group-hover:scale-105 transition-transform duration-200"
                    />
                  ) : (
                    <div className="w-full h-full bg-gradient-to-br from-primary/10 to-primary/5 flex items-center justify-center">
                      <ShoppingCart size={40} className="text-primary/20" />
                    </div>
                  )}
                  <button 
                    className="absolute top-3 right-3 p-2 bg-card rounded-full shadow-md hover:bg-primary hover:text-white transition-all duration-200"
                    onClick={(e) => e.preventDefault()}
                  >
                    <Heart size={18} className="text-red-500" fill="currentColor" />
                  </button>
                  {ad.condition && (
                    <div className="absolute top-3 left-3">
                      <span className="badge-primary text-xs">{ad.condition}</span>
                    </div>
                  )}
                </div>

                {/* Content */}
                <div className="p-4 flex flex-col flex-1">
                  <h3 className="font-semibold text-foreground mb-1 line-clamp-2 group-hover:text-primary transition-colors text-sm">
                    {ad.title}
                  </h3>
                  {ad.description && (
                    <p className="text-xs text-muted-foreground mb-3 line-clamp-2 flex-1">
                      {ad.description}
                    </p>
                  )}
                  <div className="mt-auto pt-3 border-t border-border flex items-center justify-between">
                    <p className="text-lg font-bold text-primary">
                      {formatPrice(ad.price)}
                    </p>
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {/* Load More Trigger */}
          {hasNextPage && (
            <div ref={ref} className="flex justify-center mt-8">
              {isFetchingNextPage && (
                <div className="skeleton w-8 h-8 rounded-full" />
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}
