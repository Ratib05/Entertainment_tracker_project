import { Controller, Get } from '@nestjs/common';
import { StatisticsService } from './statistics.service';
import { CurrentUser } from '../auth/current-user.decorator';
import { UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('statistics')
@UseGuards(SupabaseAuthGuard)
export class StatisticsController {
  constructor(private readonly statisticsService: StatisticsService) {}

  @Get('library')
  getLibraryStats(@CurrentUser() user: { id: string }) {
    return this.statisticsService.getLibraryStats(user.id);
  }

  @Get('reviews')
  getReviewStats(@CurrentUser() user: { id: string }) {
    return this.statisticsService.getReviewStats(user.id);
  }
}
