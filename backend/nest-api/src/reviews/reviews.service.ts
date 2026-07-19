import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { UpdateReviewDto } from './dto/update-review.dto';

@Injectable()
export class ReviewsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findAll(userId: string, accessToken: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('reviews')
      .select('id, user_id, entertainment_id, rating, review_text, created_at, updated_at, entertainment(id, title, media_type, cover_url)')
      .eq('user_id', userId);
    if (error) throw new InternalServerErrorException(`Failed to fetch reviews: ${error.message}`);
    return data;
  }

  async findOne(userId: string, accessToken: string, id: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('reviews')
      .select('id, user_id, entertainment_id, rating, review_text, created_at, updated_at, entertainment(id, title, media_type, cover_url)')
      .eq('user_id', userId)
      .eq('id', id)
      .single();
    if (error || !data) {
      throw new NotFoundException('Review not found');
    }
    return data;
  }

  async create(userId: string, accessToken: string, createReviewDto: CreateReviewDto) {
    const client = this.supabaseService.getUserClient(accessToken);
    const insertBody = {
      ...createReviewDto,
      user_id: userId,
    };
    const { data, error } = await client
      .from('reviews')
      .insert(insertBody)
      .select('id, user_id, entertainment_id, rating, review_text, created_at, updated_at')
      .single();
    if (error) throw new InternalServerErrorException(`Failed to create review: ${error.message}`);
    return data;
  }

  async update(userId: string, accessToken: string, id: string, updateReviewDto: UpdateReviewDto) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('reviews')
      .update(updateReviewDto)
      .eq('id', id)
      .eq('user_id', userId)
      .select('id, user_id, entertainment_id, rating, review_text, created_at, updated_at')
      .single();
    if (error || !data) {
      throw new NotFoundException('Review not found');
    }
    return data;
  }

  async remove(userId: string, accessToken: string, id: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { error } = await client
      .from('reviews')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);
    if (error) throw new NotFoundException('Review not found');
    return { deleted: true };
  }
}
