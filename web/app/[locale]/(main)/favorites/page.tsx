'use client';

import { useParams } from 'next/navigation';
import { t, Locale } from '@/lib/i18n';

import { Heart } from 'lucide-react';
import { EmptyState } from '@/components/shared/EmptyState';

export default function FavoritesPage() {
  const favorites: any[] = [];

  return (
    <div className="p-6 lg:p-8">
      <h1 className="text-3xl font-bold text-foreground mb-8">Saved Favorites</h1>

      {favorites.length === 0 ? (
        <EmptyState
          icon={Heart}
          title="No Favorites Yet"
          description="Start saving your favorite listings to view them later. Browse the marketplace and click the heart icon to save items."
          action={{
            label: 'Browse Marketplace',
            onClick: () => window.location.href = '/marketplace',
          }}
        />
      ) : (
        <div className="grid md:grid-cols-2 lg:grid-cols-4 gap-6">
          {favorites.map((item: any) => (
            <div
              key={item.id}
              className="bg-white dark:bg-card rounded-lg border border-border overflow-hidden hover:shadow-lg transition-shadow"
            >
              {/* Placeholder */}
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
