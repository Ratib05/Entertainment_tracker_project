import { Module } from '@nestjs/common';
import { HttpModule } from '@nestjs/axios';
import { EntertainmentController } from './entertainment.controller';
import { EntertainmentService } from './entertainment.service';
import { TmdbService } from './tmdb.service';

@Module({
  imports: [HttpModule],
  controllers: [EntertainmentController],
  providers: [EntertainmentService, TmdbService],
})
export class EntertainmentModule {}
