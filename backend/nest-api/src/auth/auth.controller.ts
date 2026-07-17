import { Controller, Get, UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from './supabase-auth.guard';
import { CurrentUser } from './current-user.decorator';

@Controller('auth')
export class AuthController {
  @Get('me')
  @UseGuards(SupabaseAuthGuard)
  me(@CurrentUser() user: unknown) {
    return { user };
  }
}

