import { Injectable, NotFoundException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { UpdateUserDto } from './dto/update-user.dto';

@Injectable()
export class UsersService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findOne(userId: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('users')
      .select('id, email, username, avatar_url, created_at')
      .eq('id', userId)
      .single();
    if (error || !data) {
      throw new NotFoundException('User not found');
    }
    return data;
  }

  async update(userId: string, updateUserDto: UpdateUserDto) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('users')
      .update(updateUserDto)
      .eq('id', userId)
      .select()
      .single();
    if (error || !data) {
      throw new NotFoundException('User not found');
    }
    return data;
  }
}
