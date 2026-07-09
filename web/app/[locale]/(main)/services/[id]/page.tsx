'use client';

import { useEffect, useState } from 'react';
import { useQuery } from '@tanstack/react-query';
import { useParams, useRouter } from 'next/navigation';
import { servicesService } from '@/lib/services/servicesService';
import { chatService } from '@/lib/services/chatService';
import Image from 'next/image';
import Link from 'next/link';
import { Heart, Share2, Flag, MessageCircle, MapPin, User, Calendar, Star, Clock, Tag } from 'lucide-react';
import { formatPrice, formatDate, getRelativeTime } from '@/lib/utils/helpers';

export default function ServiceDetailPage() {
  const params = useParams();
  const router = useRouter();
  const serviceId = params.id as string;
  const [currentImageIndex, setCurrentImageIndex] = useState(0);

  const { data: service, isLoading } = useQuery({
    queryKey: ['service', serviceId],
    queryFn: () => servicesService.getServiceById(serviceId),
  });

  const handleContactProvider = async () => {
    try {
      const conversation = await chatService.createConversation(service!.providerId);
      router.push(`/messages/${conversation.id}`);
    } catch (error) {
      console.error('Error creating conversation:', error);
    }
  };

  const handleBookService = async () => {
    // TODO: Open booking modal/form
    console.log('Book service:', serviceId);
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

  if (!service) {
    return (
      <div className="p-6 lg:p-8">
        <p className="text-muted-foreground">Service not found</p>
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
              {service.images && service.images[0] ? (
                <Image
                  src={service.images[currentImageIndex] || service.images[0]}
                  alt={service.title}
                  fill
                  className="object-cover"
                />
              ) : (
                <div className="w-full h-full bg-gradient-to-br from-blue-100 to-blue-200 dark:from-blue-900/20 dark:to-blue-900/10"></div>
              )}
              <button className="absolute top-4 right-4 p-2 bg-white dark:bg-card rounded-full shadow-md hover:bg-gray-100 transition-colors">
                <Heart size={24} className="text-red-500" />
              </button>
            </div>

            {/* Thumbnails */}
            {service.images && service.images.length > 1 && (
              <div className="flex gap-2 p-4 overflow-x-auto">
                {service.images.map((image, index) => (
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
            <h1 className="text-3xl font-bold text-foreground mb-4">{service.title}</h1>
            
            <div className="flex flex-wrap gap-4 mb-6">
              <div className="flex items-center gap-2 text-muted-foreground">
                <MapPin size={18} />
                <span>{service.location}</span>
              </div>
              <div className="flex items-center gap-2 text-muted-foreground">
                <Calendar size={18} />
                <span>{getRelativeTime(service.createdAt)}</span>
              </div>
              <div className="flex items-center gap-2 text-muted-foreground">
                <Tag size={18} />
                <span className="capitalize">{service.category.toLowerCase()}</span>
              </div>
            </div>

            {service.rating && (
              <div className="flex items-center gap-2 mb-6 pb-6 border-b border-border">
                <div className="flex items-center gap-1">
                  {[...Array(5)].map((_, i) => (
                    <Star
                      key={i}
                      size={16}
                      className={`${
                        i < Math.floor(service.rating || 0)
                          ? 'text-yellow-500 fill-yellow-500'
                          : 'text-gray-300'
                      }`}
                    />
                  ))}
                </div>
                <span className="font-medium text-foreground">{service.rating}/5</span>
                <span className="text-sm text-muted-foreground">
                  ({service.reviewCount || 0} reviews)
                </span>
              </div>
            )}

            <p className="text-foreground mb-6 leading-relaxed">{service.description}</p>

            <div className="bg-muted/50 rounded-lg p-4 mb-6">
              <div className="grid md:grid-cols-2 gap-4">
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Service Type</p>
                  <p className="font-medium text-foreground capitalize">{service.category.toLowerCase()}</p>
                </div>
                <div>
                  <p className="text-sm text-muted-foreground mb-1">Status</p>
                  <p className="font-medium text-foreground capitalize">{service.status.toLowerCase()}</p>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Sidebar */}
        <div>
          {/* Price Card */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border mb-4 sticky top-24">
            <div className="mb-4">
              <p className="text-sm text-muted-foreground mb-1">Price</p>
              <p className="text-4xl font-bold text-primary">{formatPrice(service.price)}</p>
              {service.priceType !== 'FIXED' && (
                <p className="text-sm text-muted-foreground mt-2">
                  {service.priceType === 'HOURLY' ? 'Per Hour' : 'Negotiable'}
                </p>
              )}
            </div>

            <button
              onClick={handleBookService}
              className="w-full px-4 py-3 bg-primary text-primary-foreground rounded-lg hover:bg-orange-600 transition-colors font-semibold mb-2 flex items-center justify-center gap-2"
            >
              <Clock size={20} />
              Book Service
            </button>

            <button
              onClick={handleContactProvider}
              className="w-full px-4 py-3 border border-primary text-primary rounded-lg hover:bg-orange-50 dark:hover:bg-orange-900/20 transition-colors font-semibold mb-4 flex items-center justify-center gap-2"
            >
              <MessageCircle size={20} />
              Contact Provider
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

          {/* Provider Info */}
          <div className="bg-white dark:bg-card rounded-lg p-6 border border-border">
            <h3 className="font-semibold text-foreground mb-4">Service Provider</h3>

            <div className="flex items-center gap-4 pb-4 border-b border-border mb-4">
              <div className="w-12 h-12 bg-primary text-primary-foreground rounded-full flex items-center justify-center font-semibold text-lg">
                {service.provider.firstName[0]}{service.provider.lastName[0]}
              </div>
              <div>
                <p className="font-semibold text-foreground">
                  {service.provider.firstName} {service.provider.lastName}
                </p>
                <p className="text-sm text-muted-foreground">Service Provider</p>
              </div>
            </div>

            {service.rating && (
              <div className="mb-4 pb-4 border-b border-border">
                <p className="text-sm text-muted-foreground">Rating: {service.rating} / 5</p>
              </div>
            )}

            <Link
              href={`/profile/${service.provider.id}`}
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
