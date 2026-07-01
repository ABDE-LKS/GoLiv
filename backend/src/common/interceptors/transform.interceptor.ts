import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';

export interface Response<T> {
  success: boolean;
  data: T;
  meta?: any;
}

@Injectable()
export class TransformInterceptor<T>
  implements NestInterceptor<T, Response<T>>
{
  intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Observable<Response<T>> {
    return next.handle().pipe(
      map((data) => {
        // If the controller already returned a wrapped success object, keep it
        if (data && typeof data === 'object' && 'success' in data && 'data' in data) {
          return data;
        }

        // If pagination format
        if (data && typeof data === 'object' && 'items' in data && 'total' in data) {
          return {
            success: true,
            data: data.items,
            meta: {
              total: data.total,
              page: data.page,
              limit: data.limit,
              totalPages: Math.ceil(data.total / (data.limit || 1)),
            },
          };
        }

        return {
          success: true,
          data,
        };
      }),
    );
  }
}
