import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateListDto } from './dto/create-list.dto';
import { UpdateListDto } from './dto/update-list.dto';
import { AddListItemDto } from './dto/add-list-item.dto';

@Injectable()
export class ListsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  // All per-user data access uses the user-scoped Supabase client so
  // RLS policies on the database enforce who can read/write which
  // rows. The `eq('user_id', userId)` filters are belt-and-braces;
  // they MUST be kept in sync with the policy definitions in supabase/.

  async findAll(userId: string, accessToken: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('lists')
      .select('id, user_id, name, description, is_public, created_at, updated_at, list_items(id, list_id, entertainment_id, order_index, created_at, entertainment(id, title, media_type, cover_url))')
      .eq('user_id', userId);
    if (error) throw new InternalServerErrorException('Failed to fetch lists');
    return data;
  }

  async findOne(userId: string, accessToken: string, id: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('lists')
      .select('id, user_id, name, description, is_public, created_at, updated_at, list_items(id, list_id, entertainment_id, order_index, created_at, entertainment(id, title, media_type, cover_url))')
      .eq('user_id', userId)
      .eq('id', id)
      .single();
    if (error || !data) {
      throw new NotFoundException('List not found');
    }
    return data;
  }

  async create(userId: string, accessToken: string, createListDto: CreateListDto) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('lists')
      .insert({ ...createListDto, user_id: userId })
      .select('id, user_id, name, description, is_public, created_at, updated_at')
      .single();
    if (error) throw new InternalServerErrorException('Failed to create list');
    return data;
  }

  async update(userId: string, accessToken: string, id: string, updateListDto: UpdateListDto) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('lists')
      .update(updateListDto)
      .eq('id', id)
      .eq('user_id', userId)
      .select('id, user_id, name, description, is_public, created_at, updated_at')
      .single();
    if (error || !data) {
      throw new NotFoundException('List not found');
    }
    return data;
  }

  async remove(userId: string, accessToken: string, id: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { error } = await client
      .from('lists')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);
    if (error) throw new NotFoundException('List not found');
    return { deleted: true };
  }

  private async ensureListOwnedByUser(userId: string, accessToken: string, listId: string) {
    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('lists')
      .select('id')
      .eq('id', listId)
      .eq('user_id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundException('List not found or does not belong to user');
    }

    return data;
  }

  async addItem(userId: string, accessToken: string, listId: string, addListItemDto: AddListItemDto) {
    await this.ensureListOwnedByUser(userId, accessToken, listId);

    const client = this.supabaseService.getUserClient(accessToken);
    const { data, error } = await client
      .from('list_items')
      .insert({
        list_id: listId,
        entertainment_id: addListItemDto.entertainment_id,
        order_index: addListItemDto.order_index ?? 0,
      })
      .select('id, list_id, entertainment_id, order_index, created_at');
    if (error) throw new InternalServerErrorException('Failed to add list item');
    return data;
  }

  async removeItem(userId: string, accessToken: string, listId: string, entertainmentId: string) {
    await this.ensureListOwnedByUser(userId, accessToken, listId);

    const client = this.supabaseService.getUserClient(accessToken);
    const { error } = await client
      .from('list_items')
      .delete()
      .eq('list_id', listId)
      .eq('entertainment_id', entertainmentId);
    if (error) throw new NotFoundException('List item not found');
    return { deleted: true };
  }
}
