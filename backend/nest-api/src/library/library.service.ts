import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateLibraryItemDto } from './dto/create-library-item.dto';
import { UpdateLibraryItemDto } from './dto/update-library-item.dto';

@Injectable()
export class LibraryService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findAll(userId: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('user_library')
      .select('*, entertainment(*)')
      .eq('user_id', userId);
    if (error) throw new InternalServerErrorException(`Failed to fetch library items: ${error.message}`);
    return data;
  }

  async findOne(userId: string, id: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('user_library')
      .select('*, entertainment(*)')
      .eq('user_id', userId)
      .eq('id', id)
      .single();
    if (error || !data) {
      throw new NotFoundException('Library item not found');
    }
    return data;
  }

  async create(userId: string, createLibraryItemDto: CreateLibraryItemDto) {
    const client = this.supabaseService.getClient();
    const insertBody = {
      ...createLibraryItemDto,
      user_id: userId,
    };
    const { data, error } = await client.from('user_library').insert(insertBody).select().single();
    if (error) throw new InternalServerErrorException(`Failed to add library item: ${error.message}`);
    return data;
  }

  async update(userId: string, id: string, updateLibraryItemDto: UpdateLibraryItemDto) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('user_library')
      .update(updateLibraryItemDto)
      .eq('id', id)
      .eq('user_id', userId)
      .select()
      .single();
    if (error || !data) {
      throw new NotFoundException('Library item not found');
    }
    return data;
  }

  async remove(userId: string, id: string) {
    const client = this.supabaseService.getClient();
    const { error } = await client
      .from('user_library')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);
    if (error) throw new NotFoundException('Library item not found');
    return { deleted: true };
  }
}
