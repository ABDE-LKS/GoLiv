# GoLiv - Local Marketplace Web Application

A modern, full-featured Next.js 16 marketplace platform for buying, selling, and hiring services locally in Algeria.

## Project Overview

GoLiv is built following the provided specification with:
- **Frontend**: Next.js 16 with App Router, TypeScript, Tailwind CSS v4
- **State Management**: Zustand (auth, ui, chat stores)
- **Data Fetching**: TanStack React Query v5 with infinite scroll
- **API Client**: Axios with automatic token refresh and interceptors
- **Real-time**: Socket.io client for live chat and notifications
- **Internationalization**: next-intl ready (structure in place)
- **RTL Support**: Full RTL support for Arabic language

## Project Structure

```
/vercel/share/v0-project/
├── app/                          # Next.js app directory
│   ├── page.tsx                 # Landing page
│   ├── layout.tsx               # Root layout
│   ├── globals.css              # Global styles with design system
│   ├── auth/                    # Authentication pages
│   │   ├── login/page.tsx
│   │   ├── register/page.tsx
│   │   └── layout.tsx
│   └── (main)/                  # Protected app routes
│       ├── dashboard/           # Dashboard
│       ├── marketplace/         # Marketplace & listings
│       ├── services/            # Services browsing
│       ├── jobs/                # Jobs listing
│       ├── messages/            # Chat interface
│       ├── profile/             # User profile
│       ├── my-listings/         # User's listings management
│       ├── settings/            # Settings page
│       ├── favorites/           # Saved favorites
│       └── layout.tsx           # Main app layout
│
├── components/
│   ├── layout/
│   │   ├── Navbar.tsx          # Top navigation bar
│   │   └── Sidebar.tsx         # Side navigation menu
│   ├── shared/
│   │   ├── ImageUploader.tsx   # Drag & drop image uploader
│   │   └── EmptyState.tsx      # Empty state component
│   └── providers.tsx            # TanStack Query provider
│
├── lib/
│   ├── api.ts                   # Axios client with interceptors
│   ├── socket.ts                # Socket.io client singleton
│   ├── services/                # API service modules
│   │   ├── authService.ts
│   │   ├── adsService.ts
│   │   ├── servicesService.ts
│   │   ├── jobsService.ts
│   │   ├── chatService.ts
│   │   └── userService.ts
│   └── utils/
│       └── helpers.ts           # Utility functions
│
├── stores/                       # Zustand stores
│   ├── authStore.ts            # Authentication state
│   ├── uiStore.ts              # UI state (theme, locale)
│   └── chatStore.ts            # Chat state
│
├── types/
│   └── index.ts                # All TypeScript type definitions
│
├── public/                      # Static assets
├── .env.local                   # Environment variables
└── package.json                 # Dependencies

```

## Key Features Implemented

### ✅ Complete Setup
- Next.js 16 with TypeScript strict mode
- Tailwind CSS v4 with custom design system
- Orange primary color (#FF6B35) with accent colors
- Noto Sans Arabic + Inter fonts for RTL support
- Dark mode support

### ✅ State Management
- **Auth Store**: Manages user session, access token, authentication state
- **UI Store**: Handles dark mode, mobile menu, locale/RTL
- **Chat Store**: Manages conversations, messages, unread counts

### ✅ API Client
- Axios instance with automatic token refresh
- httpOnly cookie support for refresh token
- Exponential backoff for failed requests
- One refresh token queue to prevent duplicate calls
- Per-request userId scoping ready

### ✅ Authentication Pages
- Login page with email/password validation
- Register page with form validation (zod)
- Password reset flow ready
- Phone number validation for Algeria (+213)

### ✅ Core Pages
- **Landing Page**: Marketing/onboarding
- **Dashboard**: User stats, recent listings, quick links
- **Marketplace**: Browse ads with infinite scroll, filters by category
- **Ad Detail**: Full listing view with images, seller info, contact button
- **Services**: Browse & filter services by category
- **Jobs**: Job listings with search and filters
- **Messages**: Conversation list with unread badges
- **Profile**: User profile, ratings, listing stats
- **My Listings**: User's ad management (create, edit, delete)
- **Settings**: Profile edit, preferences, dark mode toggle
- **Favorites**: Saved items (placeholder)

### ✅ UI Components
- Navbar with search, notifications, profile menu, theme toggle
- Sidebar with navigation, create listing CTA
- Image uploader with drag & drop
- Empty state component
- Loading spinners
- Form validation with react-hook-form + zod

### ✅ Data Features
- TanStack Query v5 with infinite scroll
- Service layer abstraction for all API calls
- Type-safe data fetching
- Automatic cache management
- Stale time: 5 minutes, GC time: 10 minutes

## Environment Variables

Set in `.env.local`:

```env
# API Configuration
NEXT_PUBLIC_API_URL=http://localhost:3001/api
NEXT_PUBLIC_SOCKET_URL=http://localhost:3001

# Auth Configuration
NEXT_PUBLIC_AUTH_URL=http://localhost:3000

# Feature Flags
NEXT_PUBLIC_ENABLE_CHAT=true
NEXT_PUBLIC_ENABLE_SERVICES=true
NEXT_PUBLIC_ENABLE_JOBS=true
```

## Running the Project

### Development
```bash
pnpm install
pnpm dev
```

The app runs on `http://localhost:3000` (or next available port).

### Build
```bash
pnpm build
pnpm start
```

## Authentication Flow

1. User navigates to `/auth/login` or `/auth/register`
2. Credentials validated with backend
3. Backend returns `accessToken` (in-memory) + `refreshToken` (httpOnly cookie)
4. Auth store updated with user & token
5. User redirected to `/dashboard`
6. Protected routes in `(main)` layout verify authentication
7. Token auto-refresh via interceptor when 401 received
8. Logout clears store and redirects to login

## API Integration

All API calls go through typed service modules:

```typescript
// Example: Fetching ads
import { adsService } from '@/lib/services/adsService';

const { data } = await adsService.getAds({
  category: 'ELECTRONICS',
  page: 1,
  limit: 20,
});
```

Services handle:
- Request/response transformation
- Error handling
- File uploads (multipart/form-data)
- Pagination parameters
- Query string encoding

## Socket.io Integration

Ready for real-time chat:

```typescript
import { 
  initializeSocket, 
  onNewMessage, 
  emitTyping 
} from '@/lib/socket';

// Initialize on login
const socket = initializeSocket(accessToken);

// Listen to events
onNewMessage((data) => {
  console.log('New message:', data);
});

// Emit events
emitTyping(conversationId);
```

## Design System

### Colors
- **Primary**: #FF6B35 (Orange)
- **Accent**: #FF8C42 (Light Orange)
- **Background**: White (#ffffff) / Dark (#0f0f0f)
- **Foreground**: #0a0a0a / #ffffff
- **Border**: #e5e5e5 / #333333
- **Muted**: #f0f0f0 / #3a3a3a

### Typography
- **Headings**: Inter (English) / Noto Sans Arabic (Arabic)
- **Body**: Inter (English) / Noto Sans Arabic (Arabic)
- **Line Height**: 1.4-1.6 for readability

### Layout
- Mobile-first approach
- Flexbox for most layouts
- Max-width container pattern
- Responsive grid system
- RTL support via `[dir="rtl"]`

## Performance Optimizations

- Server-side rendering on detail pages (planned)
- Image optimization with Next.js Image
- Code splitting via dynamic imports
- Query caching to reduce API calls
- Infinite scroll instead of pagination
- Dark mode with system preference detection

## Security Implementation

- Access token stored in-memory (never localStorage)
- Refresh token in httpOnly cookie (HttpOnly, Secure, SameSite)
- CSRF protection via cookie handling
- Input validation with zod
- XSS protection via React escaping
- CORS handled by backend

## Next Steps for Completion

1. **Create Listing Form**: Multi-step form for posting ads with image upload
2. **Message Chat Page**: Real-time messaging with Socket.io integration
3. **Service Detail Page**: Service provider info and booking interface
4. **Job Detail & Apply**: Job details with application submission
5. **Admin Routes**: Redirect admin users to admin.goliv.dz
6. **JSON-LD Schemas**: Add for Google indexing on detail pages
7. **Internationalization**: Implement next-intl for multi-language support
8. **Error Pages**: 404, 500 error pages
9. **Search Optimization**: Full-text search with filters
10. **Notifications**: Real-time notifications via Socket.io

## Troubleshooting

### Port Issues
If port 3000 is in use, the dev server will use the next available port (3001, 3002, etc.).

### API Connection Issues
Ensure `NEXT_PUBLIC_API_URL` matches your backend URL (default: `http://localhost:3001/api`).

### Authentication Failed
- Clear cookies and localStorage
- Check backend is running on correct port
- Verify environment variables are set

### Infinite Scroll Not Working
- Check React Intersection Observer is installed
- Verify `fetchNextPage` is being called on intersection

## Database Schema Notes

The backend should have tables for:
- Users (auth, profile data)
- Ads (listings with images, status)
- Services (service provider listings)
- Jobs (job postings)
- Conversations (chat threads)
- Messages (chat messages)
- Reviews (seller/provider ratings)
- Notifications (user notifications)

All with appropriate relationships, indexes, and RLS policies.

## Deployment

When ready for production:

1. Set `NEXT_PUBLIC_API_URL` to production API
2. Build: `pnpm build`
3. Deploy to Vercel: `vercel deploy --prod`
4. Set production environment variables in Vercel dashboard
5. Enable Analytics: `@vercel/analytics` is pre-configured

---

**GoLiv is production-ready for development**. Connect to your NestJS backend and start extending features!
