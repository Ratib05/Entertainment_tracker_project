import { Injectable, UnauthorizedException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { SupabaseUser } from './supabase-user.interface';

@Injectable()
export class AuthService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async validateAccessToken(token: string): Promise<SupabaseUser> {
    const user = await this.supabaseService.getUserByAccessToken(token);
    const client = this.supabaseService.getClient();

    const { data: existingUser, error: profileError } = await client
      .from('users')
      .select('id, email, username, avatar_url')
      .eq('id', user.id)
      .single();

    if (profileError && profileError.code !== 'PGRST116') {
      throw new UnauthorizedException('Unable to load user profile');
    }

    if (!existingUser) {
      await client.from('users').insert({
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

  async getProfile(userId: string) {
    const client = this.supabaseService.getClient();
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

