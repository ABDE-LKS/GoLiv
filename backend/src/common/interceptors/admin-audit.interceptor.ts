import { Injectable, NestInterceptor, ExecutionContext, CallHandler } from '@nestjs/common';
import { Observable, tap } from 'rxjs';
import { AuditService } from '../../modules/audit/services/audit.service';

@Injectable()
export class AdminAuditInterceptor implements NestInterceptor {
  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const req = context.switchToHttp().getRequest();
    const method = req.method;
    if (!['POST', 'PATCH', 'PUT', 'DELETE'].includes(method)) {
      return next.handle();
    }

    const userId = req.user?.userId ?? req.user?.sub ?? null;
    const path = req.route?.path ?? req.url;
    const action = `${method} ${path}`;

    return next.handle().pipe(
      tap(async () => {
        try {
          await this.auditService.log(userId, action, path, {
            body: req.body,
            params: req.params,
            ip: req.ip,
          });
        } catch {
          // Audit failure must not block admin operations
        }
      }),
    );
  }
}
