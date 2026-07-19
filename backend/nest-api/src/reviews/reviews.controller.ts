import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { UpdateReviewDto } from './dto/update-review.dto';
import { CurrentUser, CurrentAccessToken } from '../auth/current-user.decorator';
import { UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('reviews')
@UseGuards(SupabaseAuthGuard)
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Get()
  findAll(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string) {
    return this.reviewsService.findAll(user.id, accessToken);
  }

  @Get(':id')
  findOne(@CurrentUser() user: { id: string }, @Param('id') id: string, @CurrentAccessToken() accessToken: string) {
    return this.reviewsService.findOne(user.id, accessToken, id);
  }

  @Post()
  create(@CurrentUser() user: { id: string }, @CurrentAccessToken() accessToken: string, @Body() createReviewDto: CreateReviewDto) {
    return this.reviewsService.create(user.id, accessToken, createReviewDto);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @CurrentAccessToken() accessToken: string,
    @Body() updateReviewDto: UpdateReviewDto,
  ) {
    return this.reviewsService.update(user.id, accessToken, id, updateReviewDto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: { id: string }, @Param('id') id: string, @CurrentAccessToken() accessToken: string) {
    return this.reviewsService.remove(user.id, accessToken, id);
  }
}
