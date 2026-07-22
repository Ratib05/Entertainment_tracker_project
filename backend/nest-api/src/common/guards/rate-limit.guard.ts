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
    const ip =
      (request.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() ??
      request.ip ??
      request.socket?.remoteAddress ??
      'unknown';

    const now = Date.now();
    const entry = RateLimitGuard.hits.get(ip);

    if (!entry || now > entry.resetAt) {
      RateLimitGuard.hits.set(ip, { count: 1, resetAt: now + RateLimitGuard.ttlMs });
      return true;
    }

    if (entry.count >= RateLimitGuard.limit) {
      throw new HttpException('Too many requests', HttpStatus.TOO_MANY_REQUESTS);
    }

    entry.count += 1;
    return true;
  }
}
