import { NestFactory } from '@nestjs/core';
import { ValidationPipe, VersioningType } from '@nestjs/common';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from 'helmet';
import * as compression from 'compression';
import { AppModule } from './app.module';
import { AllExceptionsFilter } from './common/filters/all-exceptions.filter';
import { PrismaExceptionFilter } from './common/filters/prisma-exception.filter';
import { TransformInterceptor } from './common/interceptors/transform.interceptor';
import { RequestLoggingInterceptor } from './common/interceptors/request-logging.interceptor';
import { AdminAuditInterceptor } from './common/interceptors/admin-audit.interceptor';
import { AuditService } from './modules/audit/services/audit.service';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  // Security
  // app.use(helmet()); // Temporarily disabled to debug connection issues
  // Allow requests from the web frontend (port 3001) and mobile/Swagger
  app.enableCors({
    origin: [
      'http://localhost:3001', // Next.js web app
      'http://localhost:3000', // Swagger / Prisma Studio
      'http://127.0.0.1:3001',
      'http://10.0.2.2:3001',  // Android emulator
    ],
    credentials: true,          // Enable cookies & Authorization header
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization', 'Accept'],
  });

  // Global Response & Logging Interceptors
  app.useGlobalInterceptors(new RequestLoggingInterceptor());
  app.useGlobalInterceptors(new TransformInterceptor());
  app.useGlobalInterceptors(new AdminAuditInterceptor(app.get(AuditService)));
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
      forbidNonWhitelisted: true,
      errorHttpStatusCode: 422,
    }),
  );

  // Global Exception Filters (Prisma first, then catch-all)
  app.useGlobalFilters(new PrismaExceptionFilter(), new AllExceptionsFilter());

  // Validation
  app.setGlobalPrefix('api');
  app.enableVersioning({
    type: VersioningType.URI,
    defaultVersion: '1',
  });

  // Swagger Documentation
  const config = new DocumentBuilder()
    .setTitle('Wassali API')
    .setDescription('The official backend for Wassali Local Delivery Platform (El Guerrara)')
    .setVersion('1.0')
    .addBearerAuth()
    .build();
  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('docs', app, document);

  // Graceful shutdown — ensures port is freed on Ctrl+C / process exit
  app.enableShutdownHooks();

  const port = process.env.PORT || 3000;
  await app.listen(port, '0.0.0.0');
  console.log(`🚀 Wassali Backend is running on: http://localhost:${port}/api/v1`);
  console.log(`📝 Swagger Documentation: http://localhost:${port}/docs`);
}
bootstrap();
