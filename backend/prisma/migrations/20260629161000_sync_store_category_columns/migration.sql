-- Sync Category and Store columns with Prisma schema
-- Fixes HTTP 500: Category.icon, Store.latitude, etc. missing in database

-- AlterTable Category
ALTER TABLE "public"."Category" ADD COLUMN "icon" TEXT;
ALTER TABLE "public"."Category" ADD COLUMN "sortOrder" INTEGER NOT NULL DEFAULT 0;

-- AlterTable Store
ALTER TABLE "public"."Store" ADD COLUMN "latitude" DOUBLE PRECISION;
ALTER TABLE "public"."Store" ADD COLUMN "longitude" DOUBLE PRECISION;
ALTER TABLE "public"."Store" ADD COLUMN "minOrderAmount" DOUBLE PRECISION NOT NULL DEFAULT 0.0;
ALTER TABLE "public"."Store" ADD COLUMN "closingHours" TEXT;

-- Add SUPER_ADMIN to UserRole enum
ALTER TYPE "public"."UserRole" ADD VALUE IF NOT EXISTS 'SUPER_ADMIN';
