import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateLibraryItemDto } from './dto/create-library-item.dto';
import { UpdateLibraryItemDto } from './dto/update-library-item.dto';

@Injectable()
export class LibraryService {
  constructor(private readonly supabaseService: SupabaseService) {}

  // All per-user data access goes through the user-scoped Supabase
  // client so that RLS policies on the database are the source of truth
  // for who can read/write which rows. The `eq('user_id', userId)`
  // filters below are belt-and-braces in case RLS is not yet enabled
  // for a given table — they MUST be reviewed and kept in sync with
  // the policy definitions in supabase/.

  async findAll(userId: string, accessToken: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('user_library')
      .select('id, user_id, entertainment_id, status, progress, rating, created_at, updated_at, entertainment(id, title, media_type, cover_url, release_date)')
      .eq('user_id', userId);
    if (error) throw new InternalServerErrorException('Failed to fetch library items');
    return data;
  }

  async findOne(userId: string, accessToken: string, id: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('user_library')
      .select('id, user_id, entertainment_id, status, progress, rating, created_at, updated_at, entertainment(id, title, media_type, cover_url, release_date)')
      .eq('user_id', userId)
      .eq('id', id)
      .single();
    if (error || !data) {
      throw new NotFoundException('Library item not found');
    }
    return data;
  }

  async create(userId: string, accessToken: string, createLibraryItemDto: CreateLibraryItemDto) {
    const client = this.supabaseService.getUserClient(accessToken);
    const insertBody = {
      ...createLibraryItemDto,
      user_id: userId,
    };
    const { data, error } = await client
      .from('user_library')
      .insert(insertBody)
      .select('id, user_id, entertainment_id, status, progress, rating, created_at, updated_at')
      .single();
    if (error) throw new InternalServerErrorException('Failed to add library item');
    return data;
  }

  async update(userId: string, accessToken: string, id: string, updateLibraryItemDto: UpdateLibraryItemDto) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('user_library')
      .update(updateLibraryItemDto)
      .eq('id', id)
      .eq('user_id', userId)
      .select('id, user_id, entertainment_id, status, progress, rating, created_at, updated_at')
      .single();
    if (error || !data) {
      throw new NotFoundException('Library item not found');
    }
    return data;
  }

  async remove(userId: string, accessToken: string, id: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { error } = await client
      .from('user_library')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);
    if (error) throw new NotFoundException('Library item not found');
    return { deleted: true };
  }
}
