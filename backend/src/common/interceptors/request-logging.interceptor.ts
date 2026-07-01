import { Injectable, NestInterceptor, ExecutionContext, CallHandler, Logger } from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';

@Injectable()
export class RequestLoggingInterceptor implements NestInterceptor {
  private readonly logger = new Logger('HTTP');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const { method, url, body, ip } = req;
    const userId = req.user?.id ?? 'anonymous';
    const start = Date.now();

    this.logger.log(`→ [${ip}] ${method} ${url} | user=${userId} | body=${JSON.stringify(body)}`);

    return next.handle().pipe(
      tap({
        next: (data) => {
          const ms = Date.now() - start;
          const res = context.switchToHttp().getResponse();
          this.logger.log(`← [${ip}] ${method} ${url} | ${res.statusCode} | ${ms}ms | user=${userId}`);
        },
        error: (err) => {
          const ms = Date.now() - start;
          this.logger.error(
            `✗ [${ip}] ${method} ${url} | ${err?.status ?? 500} | ${ms}ms | user=${userId} | error=${err?.message ?? err}`,
          );
        },
      }),
    );
  }
}
