import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { LibraryService } from './library.service';
import { CreateLibraryItemDto } from './dto/create-library-item.dto';
import { UpdateLibraryItemDto } from './dto/update-library-item.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('library')
@UseGuards(SupabaseAuthGuard)
export class LibraryController {
  constructor(private readonly libraryService: LibraryService) {}

  @Get()
  findAll(@CurrentUser() user: { id: string }) {
    return this.libraryService.findAll(user.id);
  }

  @Get(':id')
  findOne(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.libraryService.findOne(user.id, id);
  }

  @Post()
  create(@CurrentUser() user: { id: string }, @Body() createLibraryItemDto: CreateLibraryItemDto) {
    return this.libraryService.create(user.id, createLibraryItemDto);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() updateLibraryItemDto: UpdateLibraryItemDto,
  ) {
    return this.libraryService.update(user.id, id, updateLibraryItemDto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.libraryService.remove(user.id, id);
  }
}
