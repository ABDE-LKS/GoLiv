'use client';

import { useState } from 'react';
import { useInfiniteQuery } from '@tanstack/react-query';
import { useInView } from 'react-intersection-observer';
import { servicesService } from '@/lib/services/servicesService';
import { ServiceCategory } from '@/types';
import Link from 'next/link';
import { Search, Filter, Star } from 'lucide-react';
import Image from 'next/image';
import { formatPrice } from '@/lib/utils/helpers';
import { useEffect } from 'react';

const categories: { value: ServiceCategory; label: string }[] = [
  { value: 'PLUMBING', label: 'Plumbing' },
  { value: 'ELECTRICAL', label: 'Electrical' },
  { value: 'CARPENTRY', label: 'Carpentry' },
  { value: 'CLEANING', label: 'Cleaning' },
  { value: 'TUTORING', label: 'Tutoring' },
  { value: 'OTHER', label: 'Other' },
];

export default function ServicesPage() {
  const [selectedCategory, setSelectedCategory] = useState<ServiceCategory | undefined>();
  const [searchQuery, setSearchQuery] = useState('');
  const { ref, inView } = useInView();

  const {
    data,
    isLoading,
    hasNextPage,
    fetchNextPage,
    isFetchingNextPage,
  } = useInfiniteQuery({
    queryKey: ['services', selectedCategory, searchQuery],
    queryFn: async ({ pageParam = 1 }) => {
      const response = await servicesService.getServices({
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

  const allServices = data?.pages.flatMap((page) => page.data) || [];

  return (
    <div className="p-6 lg:p-8">
      <div className="mb-8">
        <h1 className="text-3xl font-bold text-foreground mb-6">Services</h1>

        <div className="grid md:grid-cols-2 gap-4 mb-6">
          <div className="relative">
            <Search className="absolute left-3 top-3 text-muted-foreground" size={20} />
            <input
              type="text"
              placeholder="Search services..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full pl-10 pr-4 py-2 border border-border rounded-lg bg-background text-foreground placeholder:text-muted-foreground focus:outline-none focus:ring-2 focus:ring-primary"
            />
          </div>

          <div className="flex gap-2">
            <Filter className="w-10 h-10 p-2 border border-border rounded-lg bg-background text-foreground" />
            <select
              value={selectedCategory || ''}
              onChange={(e) => setSelectedCategory(e.target.value as ServiceCategory | undefined)}
              className="flex-1 px-4 py-2 border border-border rounded-lg bg-background text-foreground focus:outline-none focus:ring-2 focus:ring-primary"
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

      {isLoading ? (
        <div className="flex items-center justify-center py-12">
          <div className="animate-spin">
            <div className="w-12 h-12 border-4 border-primary/20 border-t-primary rounded-full"></div>
          </div>
        </div>
      ) : allServices.length === 0 ? (
        <div className="text-center py-12">
          <p className="text-muted-foreground">No services found</p>
        </div>
      ) : (
        <>
          <div className="grid md:grid-cols-2 lg:grid-cols-3 gap-6">
            {allServices.map((service) => (
              <Link
                key={service.id}
                href={`/services/${service.id}`}
                className="group bg-white dark:bg-card rounded-lg border border-border overflow-hidden hover:shadow-lg transition-shadow"
              >
                <div className="relative w-full h-40 bg-muted">
                  {service.images && service.images[0] ? (
                    <Image
                      src={service.images[0]}
                      alt={service.title}
                      fill
                      className="object-cover group-hover:scale-105 transition-transform"
                    />
                  ) : (
                    <div className="w-full h-full bg-gradient-to-br from-blue-100 to-blue-200 dark:from-blue-900/20 dark:to-blue-900/10"></div>
                  )}
                </div>

                <div className="p-4">
                  <h3 className="font-semibold text-foreground mb-2 line-clamp-2 group-hover:text-primary transition-colors">
                    {service.title}
                  </h3>
                  <p className="text-sm text-muted-foreground mb-3 line-clamp-2">
                    {service.description}
                  </p>

                  <div className="flex items-center justify-between mb-3">
                    <p className="text-lg font-bold text-primary">
                      {formatPrice(service.price)}
                      {service.priceType === 'HOURLY' && ' /hr'}
                    </p>
                  </div>

                  <div className="flex items-center gap-2">
                    {service.rating && (
                      <div className="flex items-center gap-1">
                        <Star size={16} className="text-yellow-500 fill-yellow-500" />
                        <span className="text-sm font-medium text-foreground">
                          {service.rating}
                        </span>
                      </div>
                    )}
                    <span className="text-xs text-muted-foreground">
                      ({service.reviewCount || 0} reviews)
                    </span>
                  </div>
                </div>
              </Link>
            ))}
          </div>

          {hasNextPage && (
            <div ref={ref} className="flex justify-center mt-8">
              {isFetchingNextPage && (
                <div className="animate-spin">
                  <div className="w-8 h-8 border-2 border-primary/20 border-t-primary rounded-full"></div>
                </div>
              )}
            </div>
          )}
        </>
      )}
    </div>
  );
}
