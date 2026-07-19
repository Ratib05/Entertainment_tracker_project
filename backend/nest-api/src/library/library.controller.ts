import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { LibraryService } from './library.service';
import { CreateLibraryItemDto } from './dto/create-library-item.dto';
import { UpdateLibraryItemDto } from './dto/update-library-item.dto';
import { CurrentUser, CurrentAccessToken } from '../auth/current-user.decorator';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';
import type { SupabaseUser } from '../auth/supabase-user.interface';

@Controller('library')
@UseGuards(SupabaseAuthGuard)
export class LibraryController {
  constructor(private readonly libraryService: LibraryService) {}

  @Get()
  findAll(@CurrentUser() user: SupabaseUser, @CurrentAccessToken() accessToken: string) {
    return this.libraryService.findAll(user.id, accessToken);
  }

  @Get(':id')
  findOne(
    @CurrentUser() user: SupabaseUser,
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
  ) {
    return this.libraryService.findOne(user.id, accessToken, id);
  }

  @Post()
  create(
    @CurrentUser() user: SupabaseUser,
    @CurrentAccessToken() accessToken: string,
    @Body() createLibraryItemDto: CreateLibraryItemDto,
  ) {
    return this.libraryService.create(user.id, accessToken, createLibraryItemDto);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: SupabaseUser,
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
    @Body() updateLibraryItemDto: UpdateLibraryItemDto,
  ) {
    return this.libraryService.update(user.id, accessToken, id, updateLibraryItemDto);
  }

  @Delete(':id')
  remove(
    @CurrentUser() user: SupabaseUser,
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
  ) {
    return this.libraryService.remove(user.id, accessToken, id);
  }
}
