import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpStatus,
  ConflictException,
  NotFoundException,
  BadRequestException,
} from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { Response } from 'express';

@Catch(Prisma.PrismaClientKnownRequestError)
export class PrismaExceptionFilter implements ExceptionFilter {
  catch(exception: Prisma.PrismaClientKnownRequestError, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let httpException: { status: number; message: string };

    switch (exception.code) {
      case 'P2002':
        httpException = {
          status: HttpStatus.CONFLICT,
          message: 'A record with this value already exists.',
        };
        break;
      case 'P2025':
        httpException = {
          status: HttpStatus.NOT_FOUND,
          message: 'Record not found.',
        };
        break;
      case 'P2003':
        httpException = {
          status: HttpStatus.BAD_REQUEST,
          message: 'Related record not found. Check foreign key references.',
        };
        break;
      default:
        httpException = {
          status: HttpStatus.BAD_REQUEST,
          message: exception.message,
        };
    }

    response.status(httpException.status).json({
      success: false,
      statusCode: httpException.status,
      message: httpException.message,
    });
  }
}
