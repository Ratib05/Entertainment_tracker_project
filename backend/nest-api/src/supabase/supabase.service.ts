import { Injectable, Logger, UnauthorizedException } from '@nestjs/common';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';

/**
 * Supabase access is split into two clients to keep RLS in play:
 *
 * - `getAdminClient()` uses SUPABASE_SERVICE_ROLE_KEY and bypasses RLS.
 *   It must only be used for truly privileged operations (e.g. token
 *   validation, account bootstrap). Audit every caller.
 *
 * - `getUserClient(jwt)` returns a Supabase client whose auth context is
 *   pinned to the calling user's JWT. RLS policies on the database are
 *   what enforce per-user data isolation, so this is the client that all
 *   per-user data services (library, reviews, lists, statistics, etc.)
 *   should use.
 *
 * The default `getClient()` deliberately does not exist any more: code
 * that previously called it must be updated to either `getAdminClient()`
 * (rare, audited) or `getUserClient(jwt)` (the common case).
 */
@Injectable()
export class SupabaseService {
  private readonly adminClient: SupabaseClient;
  private readonly logger = new Logger(SupabaseService.name);

  constructor() {
    const url = process.env.SUPABASE_URL;
    const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
    const anonKey = process.env.SUPABASE_ANON_KEY;

    if (!url || !serviceKey) {
      this.logger.error(
        'Missing SUPABASE_URL or SUPABASE_SERVICE_ROLE_KEY. ' +
          'Service-role key is required for token validation and admin operations.',
      );
      throw new Error('Supabase configuration is required');
    }

    if (!anonKey) {
      this.logger.warn(
        'SUPABASE_ANON_KEY is not set. User-scoped clients will fall back to the service-role key, ' +
          'which is unsafe for per-user data access. Set it before deploying.',
      );
    }

    this.adminClient = createClient(url, serviceKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  /**
   * Returns a Supabase client running as the service role. Bypasses RLS.
   * Use ONLY for admin-level operations (token validation, account
   * creation, scheduled jobs). Every call site is auditable and the
   * number of callers should stay very small.
   */
  getAdminClient(): SupabaseClient {
    return this.adminClient;
  }

  /**
   * Returns a Supabase client pinned to the calling user's JWT so that
   * Postgres RLS policies apply. This is the default client for any
   * per-user data access.
   *
   * If the SUPABASE_ANON_KEY is not configured this falls back to the
   * service-role key and logs a warning; in that case RLS is NOT
   * enforced and the caller MUST add explicit `eq('user_id', userId)`
   * filters and review every query.
   */
  getUserClient(jwt: string): SupabaseClient {
    const url = process.env.SUPABASE_URL;
    const anonKey =
      process.env.SUPABASE_ANON_KEY ?? process.env.SUPABASE_SERVICE_ROLE_KEY;

    if (!url || !anonKey) {
      throw new Error('Supabase configuration is required');
    }

    return createClient(url, anonKey, {
      global: {
        headers: { Authorization: `Bearer ${jwt}` },
      },
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  /**
   * Returns an unauthenticated Supabase client for public data access.
   * Uses the anon key and does not set an auth context, so RLS policies
   * enforce public access rules. Only use for reading public data.
   */
  getAnonClient(): SupabaseClient {
    const url = process.env.SUPABASE_URL;
    const anonKey = process.env.SUPABASE_ANON_KEY;

    if (!url || !anonKey) {
      this.logger.warn(
        'SUPABASE_ANON_KEY is not set; cannot create anonymous client for public data access. ' +
          'Falling back to service-role key. Ensure RLS is properly configured.',
      );
      return this.adminClient;
    }

    return createClient(url, anonKey, {
      auth: {
        persistSession: false,
        autoRefreshToken: false,
      },
    });
  }

  /**
   * Validates an access token using the admin client and returns the
   * authenticated user. Token validation is one of the few legitimate
   * uses of the service-role key because Supabase needs to verify the
   * signature before any RLS-scoped client can be created.
   */
  async getUserByAccessToken(token: string): Promise<User> {
    try {
      // Create a temporary client with the token to validate it
      const clientWithToken = createClient(process.env.SUPABASE_URL!, process.env.SUPABASE_ANON_KEY!, {
        global: {
          headers: { Authorization: `Bearer ${token}` },
        },
        auth: {
          persistSession: false,
          autoRefreshToken: false,
        },
      });

      const { data, error } = await clientWithToken.auth.getUser();
      if (error || !data?.user) {
        this.logger.warn('Invalid access token');
        throw new UnauthorizedException('Invalid authentication token');
      }
      return data.user;
    } catch (err) {
      this.logger.warn('Token validation error:', err);
      throw new UnauthorizedException('Invalid authentication token');
    }
  }
}
