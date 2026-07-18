import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { APP_FILTER } from '@nestjs/core';
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
import { AllExceptionsFilter } from './common/filters/http-exception.filter';
import { validate } from './config/validation';

@Module({
  imports: [
    ConfigModule.forRoot({ 
      isGlobal: true,
      validate,
    }),
    UsersModule,
    EntertainmentModule,
    LibraryModule,
    ReviewsModule,
    ListsModule,
    StatisticsModule,
    AuthModule,
    SupabaseModule,
  ],
  controllers: [AppController],
  providers: [AppService, { provide: APP_FILTER, useClass: AllExceptionsFilter }],
})
export class AppModule {}
