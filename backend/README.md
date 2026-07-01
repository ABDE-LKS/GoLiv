# Wassali Backend - Local Delivery Platform (El Guerrara)

Production-ready NestJS backend for a local delivery platform serving El Guerrara (القرارة), Ghardaïa, Algeria.

## Features

- **Auth**: Customer registration, Phone/Password login, JWT-based security.
- **Drivers**: Offline/Online status, Live location tracking.
- **Orders**: Lifecycle management (Pending -> Accepted -> Delivered).
- **Real-time**: Live chat and order updates via Socket.IO.
- **Security**: Helmet, Rate Limiting, CORS, Password hashing.
- **Documentation**: Automatic Swagger UI at `/docs`.

## Tech Stack

- **Framework**: NestJS
- **Database**: PostgreSQL with Prisma ORM
- **Real-time**: Socket.IO
- **Validation**: class-validator & Zod
- **Logs**: Winston

## Getting Started

### 1. Prerequisites

- Node.js (v18+)
- PostgreSQL Database
- Cloudinary Account (for uploads)

### 2. Installation

```bash
npm install
```

### 3. Environment Setup

Create a `.env` file based on `.env.example`.

```env
DATABASE_URL="postgresql://user:password@localhost:5432/wassali"
JWT_SECRET="your_secret_key"
CLOUDINARY_URL="cloudinary://api_key:api_secret@cloud_name"
```

### 4. Database Migration

```bash
npx prisma migrate dev --name init
```

### 5. Run the App

```bash
# development
npm run start:dev

# production
npm run build
npm run start:prod
```

## API Documentation

Once started, access Swagger at `http://localhost:3000/docs`.

## Project Structure

```
src/
├── config/             # Global configurations
├── common/             # Interceptors, guards, decorators
├── database/           # Prisma service and module
└── modules/            # Feature-based domains
    ├── auth/           # Identity & Access
    ├── users/          # Profile management
    ├── drivers/        # Driver operations
    ├── orders/         # Transaction flow
    └── chat/           # Real-time messaging
```

## License

Private / Commercial.
