import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { ListsService } from './lists.service';
import { CreateListDto } from './dto/create-list.dto';
import { UpdateListDto } from './dto/update-list.dto';
import { AddListItemDto } from './dto/add-list-item.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('lists')
@UseGuards(SupabaseAuthGuard)
export class ListsController {
  constructor(private readonly listsService: ListsService) {}

  @Get()
  findAll(@CurrentUser() user: { id: string }) {
    return this.listsService.findAll(user.id);
  }

  @Get(':id')
  findOne(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.listsService.findOne(user.id, id);
  }

  @Post()
  create(@CurrentUser() user: { id: string }, @Body() createListDto: CreateListDto) {
    return this.listsService.create(user.id, createListDto);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() updateListDto: UpdateListDto,
  ) {
    return this.listsService.update(user.id, id, updateListDto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.listsService.remove(user.id, id);
  }

  @Post(':id/items')
  addItem(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() addListItemDto: AddListItemDto,
  ) {
    return this.listsService.addItem(user.id, id, addListItemDto);
  }

  @Delete(':id/items/:entertainmentId')
  removeItem(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Param('entertainmentId') entertainmentId: string,
  ) {
    return this.listsService.removeItem(user.id, id, entertainmentId);
  }
}
