import { Injectable, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { WatchStatus } from '../common/enums/watch-status.enum';

@Injectable()
export class StatisticsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async getLibraryStats(userId: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('user_library')
      .select('status')
      .eq('user_id', userId);

    if (error) throw new InternalServerErrorException(`Failed to fetch library stats: ${error.message}`);

    const stats: Record<WatchStatus, number> = { watchlist: 0, watching: 0, watched: 0 };
    (data ?? []).forEach((item: { status: WatchStatus }) => {
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

    if (error) throw new InternalServerErrorException(`Failed to fetch review stats: ${error.message}`);

    const ratings = (data ?? [])
      .map((item: { rating: number | null }) => item.rating)
      .filter((rating: number | null): rating is number => typeof rating === 'number');
    const average = ratings.length ? ratings.reduce((sum: number, rating: number) => sum + rating, 0) / ratings.length : 0;

    return { average_rating: average, review_count: ratings.length };
  }
}
