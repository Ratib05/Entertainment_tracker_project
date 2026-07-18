import { Injectable, Logger } from '@nestjs/common';
import { createClient, SupabaseClient, User } from '@supabase/supabase-js';

@Injectable()
export class SupabaseService {
  private readonly client: SupabaseClient;
  private readonly logger = new Logger(SupabaseService.name);

  constructor() {
    const url = process.env.SUPABASE_URL;
    const key = process.env.SUPABASE_ANON_KEY;

    if (!url || !key) {
      this.logger.error('Missing SUPABASE_URL or SUPABASE_ANON_KEY');
      throw new Error('Supabase configuration is required');
    }

    this.client = createClient(url, key, {
      auth: {
        persistSession: false,
      },
    });
  }

  getClient(): SupabaseClient {
    return this.client;
  }

  async getUserByAccessToken(token: string): Promise<User> {
    const { data, error } = await this.client.auth.getUser(token);
    if (error || !data?.user) {
      const message = error?.message ?? 'Invalid access token';
      this.logger.warn('Invalid access token', message);
      throw new Error(message);
    }
    return data.user;
  }
}

