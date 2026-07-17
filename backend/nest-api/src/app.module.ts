import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { UsersModule } from './users/users.module';
import { EntertainmentModule } from './entertainment/entertainment.module';
import { LibraryModule } from './library/library.module';
import { ReviewsModule } from './reviews/reviews.module';
import { ListsModule } from './lists/lists.module';
import { StatisticsModule } from './statistics/statistics.module';
import { AuthModule } from './auth/auth.module';
import { SupabaseModule } from './supabase/supabase.module';

@Module({
  imports: [UsersModule, EntertainmentModule, LibraryModule, ReviewsModule, ListsModule, StatisticsModule, AuthModule, SupabaseModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
