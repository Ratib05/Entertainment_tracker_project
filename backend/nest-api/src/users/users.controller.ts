import { Body, Controller, Get, Patch, UseGuards } from '@nestjs/common';
import { UsersService } from './users.service';
import { UpdateUserDto } from './dto/update-user.dto';
import { CurrentUser, CurrentAccessToken } from '../auth/current-user.decorator';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('users')
@UseGuards(SupabaseAuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  findOne(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string) {
    return this.usersService.findOne(user.id, accessToken);
  }

  @Patch('me')
  update(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string, @Body() updateUserDto: UpdateUserDto) {
    return this.usersService.update(user.id, accessToken, updateUserDto);
  }
}
