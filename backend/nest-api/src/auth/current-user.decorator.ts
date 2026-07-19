import { createParamDecorator, ExecutionContext } from '@nestjs/common';

/**
 * Extracts the authenticated user attached to the request by
 * `SupabaseAuthGuard`. Use as a controller method parameter:
 *
 *   async handler(@CurrentUser() user: SupabaseUser) { ... }
 */
export const CurrentUser = createParamDecorator(
  (_data: unknown, context: ExecutionContext) => {
    const request = context.switchToHttp().getRequest();
    return request.user;
  },
);

/**
 * Extracts the raw Bearer access token from the request's Authorization
 * header. Services need this to construct a user-scoped Supabase client
 * (so RLS applies). The guard has already verified the token by the
 * time this decorator is used.
 */
export const CurrentAccessToken = createParamDecorator(
  (_data: unknown, context: ExecutionContext): string => {
    const request = context.switchToHttp().getRequest();
    const authorization = request.headers?.authorization as string | undefined;
    if (!authorization?.startsWith('Bearer ')) {
      return '';
    }
    return authorization.slice('Bearer '.length).trim();
  },
);
