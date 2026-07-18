import { Injectable } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class StatisticsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getLibraryStats(userId: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('user_library')
      .select('status')
      .eq('user_id', userId);

    if (error) throw new Error(error.message);

    const stats = { watchlist: 0, watching: 0, watched: 0 };
    (data ?? []).forEach((item: any) => {
      if (item?.status && stats[item.status] !== undefined) {
        stats[item.status] += 1;
      }
    });

    return stats;
  }

  async getReviewStats(userId: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('reviews')
      .select('rating')
      .eq('user_id', userId);

    if (error) throw new Error(error.message);

    const ratings = (data ?? []).map((item: any) => item.rating).filter((rating: number) => typeof rating === 'number');
    const average = ratings.length ? ratings.reduce((sum: number, rating: number) => sum + rating, 0) / ratings.length : 0;

    return { average_rating: average, review_count: ratings.length };
  }
}
