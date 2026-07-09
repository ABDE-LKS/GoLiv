'use client';

import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import { adsService } from '@/lib/services/adsService';
import { chatService } from '@/lib/services/chatService';
import Image from 'next/image';
import Link from 'next/link';
import { Heart, Share2, Flag, MessageCircle, MapPin, User, Calendar } from 'lucide-react';
import { formatPrice, formatDate, getRelativeTime } from '@/lib/utils/helpers';

export default function AdDetailPage() {
  const params = useParams();
  const router = useRouter();
  const adId = params.id as string;
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const { data: ad, isLoading } = useQuery({
    queryKey: ['ad', adId],
    queryFn: () => adsService.getAdById(adId),
  });

  const handleContactSeller = async () => {
    try {
      const conversation = await chatService.createConversation(ad!.sellerId);
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

  if (!ad) {
    return (
      <div className="p-6 lg:p-8">
        <p className="text-muted-foreground">Listing not found</p>
      </div>
    );
  }

  return (
    <div className="p-6 lg:p-8">
      <div className="grid lg:grid-cols-3 gap-8">
        {/* Image Gallery */}
        <div className="lg:col-span-2">
          <div className="bg-white dark:bg-card rounded-lg overflow-hidden border border-border mb-4">
            <div className="relative w-full h-96 bg-muted">
              {ad.images && ad.images[0] ? (
                <Image
                  src={ad.images[currentImageIndex] || ad.images[0]}
                  alt={ad.title}
                  fill
                  className="object-cover"
                />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-orange-100 to-orange-200 dark:from-orange-900/20 dark:to-orange-900/10"></div>
              )}
              <button className="absolute top-4 right-4 p-2 bg-white dark:bg-card rounded-full shadow-md hover:bg-gray-100 transition-colors">
                <Heart size={24} className="text-red-500" />
              </button>
            </div>

            {/* Thumbnails */}
            {ad.images && ad.images.length > 1 && (
              <div className="flex gap-2 p-4 overflow-x-auto">
                {ad.images.map((image, index) => (
                  <button
                    key={index}
                    onClick={() => setCurrentImageIndex(index)}
                    className={`flex-shrink-0 w-20 h-20 rounded-lg border-2 overflow-hidden transition-all ${
                      currentImageIndex === index
                        ? 'border-primary'
                        : 'border-border'
                    }`}
                  >
                    <Image
                      src={image}
                      alt={`Thumbnail ${index}`}
                      width={80}
                      height={80}
                      className="object-cover w-full h-full"
                    />
                  </button>
                ))}
              </div>
            )}
          </div>

          {/* Details */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
            <h1 className="text-3xl font-bold text-foreground mb-4">{ad.title}</h1>
            
            <div className="flex flex-wrap gap-4 mb-6">
              <div className="flex items-center gap-2 text-muted-foreground">
                <MapPin size={18} />
                <span>{ad.location}</span>
              </div>
              <div className="flex items-center gap-2 text-muted-foreground">
                <Calendar size={18} />
                <span>{getRelativeTime(ad.createdAt)}</span>
              </div>
            </div>

            <p className="text-foreground mb-6 leading-relaxed">{ad.description}</p>

            {ad.specifications && Object.keys(ad.specifications).length > 0 && (
              <div className="mb-6">
                <h3 className="font-semibold text-foreground mb-3">Specifications</h3>
                <div className="grid md:grid-cols-2 gap-3">
                  {Object.entries(ad.specifications).map(([key, value]) => (
                    <div key={key} className="flex justify-between text-sm">
                      <span className="text-muted-foreground">{key}:</span>
                      <span className="font-medium text-foreground">{value}</span>
                    </div>
                  ))}
                </div>
              </div>
            )}
          </div>
        </div>

        {/* Sidebar */}
        <div>
          {/* Price Card */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border mb-4 sticky top-24">
            <p className="text-4xl font-bold text-primary mb-4">{formatPrice(ad.price)}</p>

            <button
              onClick={handleContactSeller}
              className="w-full px-4 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors font-semibold mb-2 flex items-center justify-center gap-2"
            >
              <MessageCircle size={20} />
              Contact Seller
            </button>

            <div className="flex gap-2 mb-6">
              <button className="flex-1 px-3 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors flex items-center justify-center gap-2">
                <Heart size={20} />
                <span>Save</span>
              </button>
              <button className="flex-1 px-3 py-2 border border-border text-foreground rounded-lg hover:bg-muted transition-colors flex items-center justify-center gap-2">
                <Share2 size={20} />
                <span>Share</span>
              </button>
            </div>

            <button className="w-full px-4 py-2 border border-red-200 text-red-600 rounded-lg hover:bg-red-50 dark:hover:bg-red-900/20 transition-colors flex items-center justify-center gap-2 text-sm">
              <Flag size={18} />
              Report
            </button>
          </div>

          {/* Seller Info */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
            <h3 className="font-semibold text-foreground mb-4">Seller Information</h3>

            <div className="flex items-center gap-4 pb-4 border-b border-border mb-4">
              <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-semibold text-lg">
                {ad.seller.firstName[0]}{ad.seller.lastName[0]}
              </div>
              <div>
                <p className="font-semibold text-foreground">
                  {ad.seller.firstName} {ad.seller.lastName}
                </p>
                <p className="text-sm text-muted-foreground">Member since 2023</p>
              </div>
            </div>

            {ad.seller.rating && (
              <div className="mb-4 pb-4 border-b border-border">
                <p className="text-sm text-muted-foreground">Rating: {ad.seller.rating} / 5</p>
              </div>
            )}

            <Link
              href={`/profile/${ad.seller.id}`}
              className="w-full px-4 py-2 border border-primary text-primary rounded-lg hover:bg-orange-50 dark:hover:bg-orange-900/20 transition-colors text-center font-medium"
            >
              View Profile
            </Link>
          </div>
        </div>
      </div>
    </div>
  );
}
