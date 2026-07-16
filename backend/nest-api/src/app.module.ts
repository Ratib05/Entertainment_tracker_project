import { Module } from '@nestjs/common';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { EntertainmentModule } from './entertainment/entertainment.module';
import { LibraryModule } from './library/library.module';
import { ReviewsModule } from './reviews/reviews.module';
import { ListsModule } from './lists/lists.module';
import { StatisticsModule } from './statistics/statistics.module';

@Module({
  imports: [AuthModule, UsersModule, EntertainmentModule, LibraryModule, ReviewsModule, ListsModule, StatisticsModule],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
