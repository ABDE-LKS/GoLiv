import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { WinstonModule } from 'nest-winston';
import { DatabaseModule } from './database/database.module';
import { loggerConfig } from './config/logger.config';
import { AuthModule } from './modules/auth/auth.module';
import { UploadsModule } from './modules/uploads/uploads.module';
import { DashboardModule } from './modules/dashboard/dashboard.module';
import { LocationsModule } from './modules/locations/locations.module';
import { NotificationsModule } from './modules/notifications/notifications.module';
import { ChatModule } from './modules/chat/chat.module';
import { OrdersModule } from './modules/orders/orders.module';
import { DriversModule } from './modules/drivers/drivers.module';
import { UsersModule } from './modules/users/users.module';
import { StoresModule } from './modules/stores/stores.module';
import { HomeModule } from './modules/home/home.module';
import { CategoriesModule } from './modules/categories/categories.module';
import { ProductsModule } from './modules/products/products.module';
import { CustomersModule } from './modules/customers/customers.module';
import { OffersModule } from './modules/offers/offers.module';
import { ComplaintsModule } from './modules/complaints/complaints.module';
import { SettingsModule } from './modules/settings/settings.module';
import { AuditModule } from './modules/audit/audit.module';
import { AdminsModule } from './modules/admins/admins.module';
import { ReportsModule } from './modules/reports/reports.module';
import { AdvertisementsModule } from './modules/advertisements/advertisements.module';
import { ConversationsModule } from './modules/conversations/conversations.module';
import { FavoritesModule } from './modules/favorites/favorites.module';
import { ServicesModule } from './modules/services/services.module';
import { JobsModule } from './modules/jobs/jobs.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    WinstonModule.forRoot(loggerConfig),
    DatabaseModule,
    AuthModule,
    UsersModule,
    DriversModule,
    OrdersModule,
    ChatModule,
    NotificationsModule,
    LocationsModule,
    DashboardModule,
    UploadsModule,
    StoresModule,
    HomeModule,
    CategoriesModule,
    ProductsModule,
    CustomersModule,
    OffersModule,
    ComplaintsModule,
    SettingsModule,
    AuditModule,
    AdminsModule,
    ReportsModule,
    AdvertisementsModule,
    ConversationsModule,
    FavoritesModule,
    ServicesModule,
    JobsModule,
  ],
})
export class AppModule {}
