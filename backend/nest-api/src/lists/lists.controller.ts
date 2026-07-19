import { Body, Controller, Delete, Get, Param, Patch, Post, UseGuards } from '@nestjs/common';
import { ListsService } from './lists.service';
import { CreateListDto } from './dto/create-list.dto';
import { UpdateListDto } from './dto/update-list.dto';
import { AddListItemDto } from './dto/add-list-item.dto';
import { CurrentUser, CurrentAccessToken } from '../auth/current-user.decorator';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('lists')
@UseGuards(SupabaseAuthGuard)
export class ListsController {
  constructor(private readonly listsService: ListsService) {}

  @Get()
  findAll(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string) {
    return this.listsService.findAll(user.id, accessToken);
  }

  @Get(':id')
  findOne(
    @CurrentUser() user: { id: string },
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
  ) {
    return this.listsService.findOne(user.id, accessToken, id);
  }

  @Post()
  create(
    @CurrentUser() user: { id: string },
    @CurrentAccessToken() accessToken: string,
    @Body() createListDto: CreateListDto,
  ) {
    return this.listsService.create(user.id, accessToken, createListDto);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: { id: string },
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
    @Body() updateListDto: UpdateListDto,
  ) {
    return this.listsService.update(user.id, accessToken, id, updateListDto);
  }

  @Delete(':id')
  remove(
    @CurrentUser() user: { id: string },
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
  ) {
    return this.listsService.remove(user.id, accessToken, id);
  }

  @Post(':id/items')
  addItem(
    @CurrentUser() user: { id: string },
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
    @Body() addListItemDto: AddListItemDto,
  ) {
    return this.listsService.addItem(user.id, accessToken, id, addListItemDto);
  }

  @Delete(':id/items/:entertainmentId')
  removeItem(
    @CurrentUser() user: { id: string },
    @CurrentAccessToken() accessToken: string,
    @Param('id') id: string,
    @Param('entertainmentId') entertainmentId: string,
  ) {
    return this.listsService.removeItem(user.id, accessToken, id, entertainmentId);
  }
}
