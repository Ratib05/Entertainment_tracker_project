import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateListDto } from './dto/create-list.dto';
import { UpdateListDto } from './dto/update-list.dto';
import { AddListItemDto } from './dto/add-list-item.dto';

@Injectable()
export class ListsService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findAll(userId: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('lists')
      .select('*, list_items(*, entertainment(*))')
      .eq('user_id', userId);
    if (error) throw new InternalServerErrorException(`Failed to fetch lists: ${error.message}`);
    return data;
  }

  async findOne(userId: string, id: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('lists')
      .select('*, list_items(*, entertainment(*))')
      .eq('user_id', userId)
      .eq('id', id)
      .single();
    if (error || !data) {
      throw new NotFoundException('List not found');
    }
    return data;
  }

  async create(userId: string, createListDto: CreateListDto) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('lists')
      .insert({ ...createListDto, user_id: userId })
      .select()
      .single();
    if (error) throw new InternalServerErrorException(`Failed to create list: ${error.message}`);
    return data;
  }

  async update(userId: string, id: string, updateListDto: UpdateListDto) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('lists')
      .update(updateListDto)
      .eq('id', id)
      .eq('user_id', userId)
      .select()
      .single();
    if (error || !data) {
      throw new NotFoundException('List not found');
    }
    return data;
  }

  async remove(userId: string, id: string) {
    const client = this.supabaseService.getClient();
    const { error } = await client
      .from('lists')
      .delete()
      .eq('id', id)
      .eq('user_id', userId);
    if (error) throw new NotFoundException('List not found');
    return { deleted: true };
  }

  private async ensureListOwnedByUser(userId: string, listId: string) {
    const client = this.supabaseService.getClient();
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

  async addItem(userId: string, listId: string, addListItemDto: AddListItemDto) {
    await this.ensureListOwnedByUser(userId, listId);

    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('list_items')
      .insert({
        list_id: listId,
        entertainment_id: addListItemDto.entertainment_id,
        order_index: addListItemDto.order_index ?? 0,
      })
      .select();
    if (error) throw new InternalServerErrorException(`Failed to add list item: ${error.message}`);
    return data;
  }

  async removeItem(userId: string, listId: string, entertainmentId: string) {
    await this.ensureListOwnedByUser(userId, listId);

    const client = this.supabaseService.getClient();
    const { error } = await client
      .from('list_items')
      .delete()
      .eq('list_id', listId)
      .eq('entertainment_id', entertainmentId);
    if (error) throw new NotFoundException('List item not found');
    return { deleted: true };
  }
}
