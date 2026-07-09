// User Types
export interface User {
  id: string;
  email: string;
  firstName: string;
  lastName: string;
  phone: string;
  avatar?: string;
  bio?: string;
  role: 'BUYER' | 'SELLER' | 'ADMIN';
  isVerified: boolean;
  createdAt: string;
  updatedAt: string;
  rating?: number;
  reviewCount?: number;
}

export interface AuthResponse {
  accessToken: string;
  refreshToken: string;
  user: User;
}

// Ad Types
export type AdCategory = 'ELECTRONICS' | 'FURNITURE' | 'VEHICLES' | 'REAL_ESTATE' | 'CLOTHING' | 'OTHER';
export type AdCondition = 'NEW' | 'LIKE_NEW' | 'GOOD' | 'FAIR' | 'FOR_PARTS';
export type AdStatus = 'ACTIVE' | 'SOLD' | 'ARCHIVED';

export interface Ad {
  id: string;
  title: string;
  description: string;
  category: AdCategory;
  condition: AdCondition;
  price: number;
  images: string[];
  location: string;
  status: AdStatus;
  seller: User;
  sellerId: string;
  views: number;
  createdAt: string;
  updatedAt: string;
}

export interface AdDetail extends Ad {
  specifications?: Record<string, string>;
  meetingPoints?: string[];
}

// Service Types
export type ServiceCategory = 'PLUMBING' | 'ELECTRICAL' | 'CARPENTRY' | 'CLEANING' | 'TUTORING' | 'OTHER';
export type ServiceStatus = 'AVAILABLE' | 'BOOKED' | 'COMPLETED' | 'CANCELLED';

export interface Service {
  id: string;
  title: string;
  description: string;
  category: ServiceCategory;
  price: number;
  priceType: 'FIXED' | 'HOURLY' | 'NEGOTIABLE';
  provider: User;
  providerId: string;
  images: string[];
  status: ServiceStatus;
  location: string;
  rating?: number;
  reviewCount?: number;
  createdAt: string;
  updatedAt: string;
}

// Job Types
export type JobType = 'FULL_TIME' | 'PART_TIME' | 'CONTRACT' | 'TEMPORARY';
export type JobStatus = 'OPEN' | 'IN_PROGRESS' | 'COMPLETED' | 'CANCELLED';

export interface Job {
  id: string;
  title: string;
  description: string;
  company: string;
  jobType: JobType;
  salary?: number;
  location: string;
  status: JobStatus;
  postedBy: User;
  postedById: string;
  applications?: number;
  createdAt: string;
  updatedAt: string;
}

// Chat Types
export interface Message {
  id: string;
  conversationId: string;
  senderId: string;
  sender: User;
  content: string;
  images?: string[];
  createdAt: string;
  readAt?: string;
}

export interface Conversation {
  id: string;
  participants: User[];
  lastMessage?: Message;
  lastMessageAt: string;
  unreadCount: number;
  createdAt: string;
  updatedAt: string;
}

// Review Types
export interface Review {
  id: string;
  reviewerId: string;
  reviewer: User;
  revieweeId: string;
  reviewee: User;
  rating: number;
  comment: string;
  itemType: 'AD' | 'SERVICE' | 'JOB';
  itemId: string;
  createdAt: string;
  updatedAt: string;
}

// Notification Types
export type NotificationType = 'MESSAGE' | 'PURCHASE' | 'SERVICE_REQUEST' | 'JOB_APPLICATION' | 'REVIEW' | 'SYSTEM';

export interface Notification {
  id: string;
  userId: string;
  type: NotificationType;
  title: string;
  message: string;
  data?: Record<string, any>;
  read: boolean;
  createdAt: string;
}

// Pagination
export interface PaginatedResponse<T> {
  data: T[];
  total: number;
  page: number;
  limit: number;
  hasMore: boolean;
}

// Filter Types
export interface AdFilters {
  category?: AdCategory;
  condition?: AdCondition;
  minPrice?: number;
  maxPrice?: number;
  location?: string;
  sortBy?: 'NEWEST' | 'PRICE_LOW' | 'PRICE_HIGH' | 'POPULAR';
  page?: number;
  limit?: number;
}

export interface ServiceFilters {
  category?: ServiceCategory;
  minPrice?: number;
  maxPrice?: number;
  location?: string;
  sortBy?: 'NEWEST' | 'PRICE_LOW' | 'PRICE_HIGH' | 'RATING';
  page?: number;
  limit?: number;
}

// API Request/Response Types
export interface ApiError {
  statusCode: number;
  message: string;
  errors?: Record<string, string[]>;
}

export interface ApiResponse<T> {
  success: boolean;
  data?: T;
  error?: ApiError;
  message?: string;
}
