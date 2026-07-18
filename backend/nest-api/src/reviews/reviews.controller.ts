import { Body, Controller, Delete, Get, Param, Patch, Post } from '@nestjs/common';
import { ReviewsService } from './reviews.service';
import { CreateReviewDto } from './dto/create-review.dto';
import { UpdateReviewDto } from './dto/update-review.dto';
import { CurrentUser } from '../auth/current-user.decorator';
import { UseGuards } from '@nestjs/common';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';

@Controller('reviews')
@UseGuards(SupabaseAuthGuard)
export class ReviewsController {
  constructor(private readonly reviewsService: ReviewsService) {}

  @Get()
  findAll(@CurrentUser() user: { id: string }) {
    return this.reviewsService.findAll(user.id);
  }

  @Get(':id')
  findOne(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.reviewsService.findOne(user.id, id);
  }

  @Post()
  create(@CurrentUser() user: { id: string }, @Body() createReviewDto: CreateReviewDto) {
    return this.reviewsService.create(user.id, createReviewDto);
  }

  @Patch(':id')
  update(
    @CurrentUser() user: { id: string },
    @Param('id') id: string,
    @Body() updateReviewDto: UpdateReviewDto,
  ) {
    return this.reviewsService.update(user.id, id, updateReviewDto);
  }

  @Delete(':id')
  remove(@CurrentUser() user: { id: string }, @Param('id') id: string) {
    return this.reviewsService.remove(user.id, id);
  }
}
