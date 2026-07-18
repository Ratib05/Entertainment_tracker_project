import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { EntertainmentService } from './entertainment.service';
import { CreateEntertainmentDto } from './dto/create-entertainment.dto';
import { UpdateEntertainmentDto } from './dto/update-entertainment.dto';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('entertainment')
export class EntertainmentController {
  constructor(private readonly entertainmentService: EntertainmentService) {}

  @Get()
  findAll() {
    return this.entertainmentService.findAll();
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.entertainmentService.findOne(id);
  }

  @Post()
  @UseGuards(SupabaseAuthGuard)
  create(@Body() createEntertainmentDto: CreateEntertainmentDto) {
    return this.entertainmentService.create(createEntertainmentDto);
  }

  @Patch(':id')
  @UseGuards(SupabaseAuthGuard)
  update(@Param('id') id: string, @Body() updateEntertainmentDto: UpdateEntertainmentDto) {
    return this.entertainmentService.update(id, updateEntertainmentDto);
  }

  @Delete(':id')
  @UseGuards(SupabaseAuthGuard)
  remove(@Param('id') id: string) {
    return this.entertainmentService.remove(id);
  }
}
