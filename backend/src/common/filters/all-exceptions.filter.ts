import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Request, Response } from 'express';

@Catch()
export class AllExceptionsFilter implements ExceptionFilter {
  private readonly logger = new Logger(AllExceptionsFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();
    const request = ctx.getRequest<Request>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let message: any = 'حدث خطأ داخلي في الخادم';

    const metadata = {
      url: request.url,
      method: request.method,
      body: request.body,
      params: request.params,
      query: request.query,
      ip: request.ip,
      user: (request as any).user?.id || 'anonymous',
    };

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const exceptionResponse = exception.getResponse();
      
      if (typeof exceptionResponse === 'string') {
        message = exceptionResponse;
      } else if (typeof exceptionResponse === 'object' && exceptionResponse !== null) {
        message = (exceptionResponse as any).message || exceptionResponse;
      }
      
      if (status >= 500) {
        this.logger.error(`[HttpException ${status}] ${JSON.stringify(metadata)}`, (exception as Error).stack);
      } else {
        this.logger.warn(`[HttpException ${status}] ${JSON.stringify(metadata)}`);
      }
    } else if (exception instanceof Error) {
      this.logger.error(`[Unhandled Exception] ${JSON.stringify(metadata)}`, exception.stack);
      message = exception.message;
    }

    response.status(status).json({
      success: false,
      statusCode: status,
      timestamp: new Date().toISOString(),
      path: request.url,
      message,
    });
  }
}
