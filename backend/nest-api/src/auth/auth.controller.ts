import { Controller, Get, UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from './supabase-auth.guard';
import { CurrentUser } from './current-user.decorator';
import { AuthService } from './auth.service';

@Controller('auth')
export class AuthController {
  constructor(private readonly authService: AuthService) {}

  @Get('me')
  @UseGuards(SupabaseAuthGuard)
  async me(@CurrentUser() user: { id: string }) {
    const profile = await this.authService.getProfile(user.id);
    return { user: profile };
  }
}

