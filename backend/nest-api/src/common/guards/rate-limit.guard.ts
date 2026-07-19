import {
  CanActivate,
  ExecutionContext,
  HttpException,
  HttpStatus,
  Injectable,
} from '@nestjs/common';
import { Reflector } from '@nestjs/core';
import { SKIP_RATE_LIMIT_KEY } from '../decorators/skip-rate-limit.decorator';

interface RateLimitEntry {
  count: number;
  resetAt: number;
}

/**
 * In-memory rate limiter guard. Limits requests per IP to 100 per 60 seconds.
 *
 * WARNING: This implementation does not scale across distributed deployments.
 * For production multi-instance deployments, replace with a Redis-backed
 * limiter or use your cloud provider's API gateway rate limiting.
 * See: https://github.com/wyattjoh/rate-limiter-flexible
 *      or express-rate-limit with Redis store
 */
@Injectable()
export class RateLimitGuard implements CanActivate {
  private static readonly hits = new Map<string, RateLimitEntry>();
  private static readonly limit = 100;
  private static readonly ttlMs = 60_000;

  constructor(private readonly reflector: Reflector) {}

  canActivate(context: ExecutionContext): boolean {
    const skip = this.reflector.getAllAndOverride<boolean>(SKIP_RATE_LIMIT_KEY, [
      context.getHandler(),
      context.getClass(),
    ]);
    if (skip) {
      return true;
    }

    const request = context.switchToHttp().getRequest();
    const response = context.switchToHttp().getResponse();
    const ip =
      (request.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() ??
      request.ip ??
      request.socket?.remoteAddress ??
      'unknown';

    const now = Date.now();
    const entry = RateLimitGuard.hits.get(ip);

    if (!entry || now > entry.resetAt) {
      const resetAt = now + RateLimitGuard.ttlMs;
      RateLimitGuard.hits.set(ip, { count: 1, resetAt });
      this.setRateLimitHeaders(response, 1, RateLimitGuard.limit, resetAt);
      return true;
    }

    this.setRateLimitHeaders(response, entry.count + 1, RateLimitGuard.limit, entry.resetAt);

    if (entry.count >= RateLimitGuard.limit) {
      const retryAfter = Math.ceil((entry.resetAt - now) / 1000);
      response.setHeader('Retry-After', retryAfter);
      throw new HttpException('Too many requests', HttpStatus.TOO_MANY_REQUESTS);
    }

    entry.count += 1;
    return true;
  }

  private setRateLimitHeaders(response: any, current: number, limit: number, resetAt: number) {
    response.setHeader('X-RateLimit-Limit', limit);
    response.setHeader('X-RateLimit-Remaining', Math.max(0, limit - current));
    response.setHeader('X-RateLimit-Reset', Math.ceil(resetAt / 1000));
  }
}
