import { Controller, Get, UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from './supabase-auth.guard';
import { CurrentUser, CurrentAccessToken } from './current-user.decorator';
import { AuthService } from './auth.service';
import type { SupabaseUser } from './supabase-user.interface';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  @UseGuards(SupabaseAuthGuard)
  async me(
    @CurrentUser() user: SupabaseUser,
    @CurrentAccessToken() accessToken: string,
  ) {
    const profile = await this.authService.getProfile(user.id, accessToken);
    return { user: profile };
  }
}
