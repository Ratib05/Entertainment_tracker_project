import { Injectable, NotFoundException, InternalServerErrorException } from '@nestjs/common';
import { SupabaseService } from '../supabase/supabase.service';
import { CreateEntertainmentDto } from './dto/create-entertainment.dto';
import { UpdateEntertainmentDto } from './dto/update-entertainment.dto';

@Injectable()
export class EntertainmentService {
  constructor(private readonly supabaseService: SupabaseService) {}

  async findAll() {
    const client = this.supabaseService.getClient();
    const { data, error } = await client.from('entertainment').select('*');
    if (error) throw new InternalServerErrorException(`Failed to fetch entertainment: ${error.message}`);
    return data;
  }

  async findOne(id: string) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client.from('entertainment').select('*').eq('id', id).single();
    if (error || !data) {
      throw new NotFoundException('Entertainment item not found');
    }
    return data;
  }

  async findByExternalId(externalId: string, type: string) {
    const client = this.supabaseService.getClient();
    const { data } = await client
      .from('entertainment')
      .select('*')
      .eq('external_id', externalId)
      .eq('type', type)
      .maybeSingle();
    return data;
  }

  async create(createEntertainmentDto: CreateEntertainmentDto) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client.from('entertainment').insert(createEntertainmentDto).select().single();
    if (error) throw new InternalServerErrorException(`Failed to create entertainment: ${error.message}`);
    return data;
  }

  async update(id: string, updateEntertainmentDto: UpdateEntertainmentDto) {
    const client = this.supabaseService.getClient();
    const { data, error } = await client
      .from('entertainment')
      .update(updateEntertainmentDto)
      .eq('id', id)
      .select()
      .single();
    if (error) throw new NotFoundException('Entertainment item not found');
    return data;
  }

  async remove(id: string) {
    const client = this.supabaseService.getClient();
    const { error } = await client.from('entertainment').delete().eq('id', id);
    if (error) throw new NotFoundException('Entertainment item not found');
    return { deleted: true };
  }
}
