import { Injectable, UnauthorizedException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { SupabaseUser } from './supabase-user.interface';

@Injectable()
export class AuthService {
  constructor(private readonly supabaseService: SupabaseService) {}

  /**
   * Validates the access token using the admin client (the only safe
   * place to use the service-role key: Supabase must verify the JWT
   * signature before any RLS-scoped client can be created). Returns the
   * Supabase user.
   */
  async validateAccessToken(token: string): Promise<SupabaseUser> {
    const user = await this.supabaseService.getUserByAccessToken(token);

    // Profile bootstrap uses the admin client because we don't yet
    // have a confirmed user-scoped session for a brand-new account.
    // The insert is constrained by `id = user.id` so it can only ever
    // affect the calling user's own row.
    const adminClient = this.supabaseService.getAdminClient();
    const { data: existingUser, error: profileError } = await adminClient
      .from('users')
      .select('id, email, username, avatar_url')
      .eq('id', user.id)
      .single();

    if (profileError && profileError.code !== 'PGRST116') {
      throw new UnauthorizedException('Unable to load user profile');
    }

    if (!existingUser) {
      await adminClient.from('users').insert({
        id: user.id,
        email: user.email,
        username: user.user_metadata?.username,
        avatar_url: user.user_metadata?.avatar_url,
      });
    }

    return {
      id: user.id,
      email: user.email ?? undefined,
      user_metadata: {
        username: user.user_metadata?.username,
        avatar_url: user.user_metadata?.avatar_url,
      },
    };
  }

  /**
   * Reads the caller's own profile. Uses the user-scoped client so RLS
   * applies — the user can only ever read their own row.
   */
  async getProfile(userId: string, accessToken: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('users')
      .select('id, email, username, avatar_url, created_at')
      .eq('id', userId)
      .single();

    if (error) {
      throw new UnauthorizedException('Unable to load profile');
    }

    return data;
  }
}
