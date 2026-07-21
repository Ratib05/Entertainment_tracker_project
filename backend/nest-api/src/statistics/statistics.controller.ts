import { Controller, Get, UseGuards } from '@nestjs/common';
import { StatisticsService } from './statistics.service';
import { CurrentUser, CurrentAccessToken } from '../auth/current-user.decorator';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('statistics')
@UseGuards(SupabaseAuthGuard)
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @Get('library')
  getLibraryStats(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string) {
    return this.statisticsService.getLibraryStats(user.id, accessToken);
  }

  @Get('reviews')
  getReviewStats(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string) {
    return this.statisticsService.getReviewStats(user.id, accessToken);
  }
}
