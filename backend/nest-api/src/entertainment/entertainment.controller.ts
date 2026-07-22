import { Body, Controller, Delete, Get, Param, Patch, Post, Query, UseGuards } from '@nestjs/common';
import { EntertainmentService } from './entertainment.service';
import { TmdbService } from './tmdb.service';
import { CreateEntertainmentDto } from './dto/create-entertainment.dto';
import { UpdateEntertainmentDto } from './dto/update-entertainment.dto';
import { SearchTmdbDto } from './dto/search-tmdb.dto';
import { ImportTmdbDto } from './dto/import-tmdb.dto';
import { DiscoverTmdbDto } from './dto/discover-tmdb.dto';
import { GenreListTmdbDto } from './dto/genre-list-tmdb.dto';
import { WatchProvidersTmdbDto } from './dto/watch-providers-tmdb.dto';
import { SupabaseAuthGuard } from '../auth/supabase-auth.guard';
import { MediaType } from '../common/enums/media-type.enum';

@Controller('entertainment')
export class EntertainmentController {
  constructor(
    private readonly entertainmentService: EntertainmentService,
    private readonly tmdbService: TmdbService,
  ) {}

  @Get()
  findAll() {
    return this.entertainmentService.findAll();
  }

  @Get('search/tmdb')
  async searchTmdb(@Query() searchTmdbDto: SearchTmdbDto) {
    return this.tmdbService.search(searchTmdbDto.query, searchTmdbDto.type);
  }

  @Get('discover/tmdb')
  async discoverTmdb(@Query() discoverTmdbDto: DiscoverTmdbDto) {
    const genres = discoverTmdbDto.genres
      ? discoverTmdbDto.genres.split(',').map((g) => g.trim()).filter(Boolean)
      : [];
    return this.tmdbService.discover(
      genres,
      discoverTmdbDto.type ?? MediaType.Film,
      discoverTmdbDto.page ?? 1,
      discoverTmdbDto.sort ?? 'popularity',
    );
  }

  @Get('genres/tmdb')
  async genresTmdb(@Query() genreListTmdbDto: GenreListTmdbDto) {
    return this.tmdbService.getGenreNames(genreListTmdbDto.type ?? MediaType.Film);
  }

  @Get('watch-providers/tmdb')
  async watchProvidersTmdb(@Query() watchProvidersTmdbDto: WatchProvidersTmdbDto) {
    return this.tmdbService.getWatchProviders(
      watchProvidersTmdbDto.tmdbId,
      watchProvidersTmdbDto.type,
      watchProvidersTmdbDto.region ?? 'US',
    );
  }

  @Post('import/tmdb')
  async importTmdb(@Body() importTmdbDto: ImportTmdbDto) {
    const existing = await this.entertainmentService.findByExternalId(
      importTmdbDto.tmdbId,
      importTmdbDto.type,
    );

    // Older rows (imported before a field like `seasons` or `runtime_minutes`
    // existed) are missing data the app now depends on — refresh from TMDB
    // and backfill instead of returning the stale cached row forever.
    const isStale =
      existing &&
      (importTmdbDto.type === MediaType.Show
        ? !existing.seasons
        : existing.runtime_minutes == null);

    if (existing && !isStale) {
      return existing;
    }

    const details =
      importTmdbDto.type === MediaType.Film
        ? await this.tmdbService.getMovieDetails(importTmdbDto.tmdbId)
        : await this.tmdbService.getShowDetails(importTmdbDto.tmdbId);

    if (existing) {
      return this.entertainmentService.update(existing.id, details as UpdateEntertainmentDto);
    }

    return this.entertainmentService.create(details as CreateEntertainmentDto);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.entertainmentService.findOne(id);
  }

  @Post()
  @UseGuards(SupabaseAuthGuard)
  create(@Body() createEntertainmentDto: CreateEntertainmentDto) {
    return this.entertainmentService.create(createEntertainmentDto);
  }

  @Patch(':id')
  @UseGuards(SupabaseAuthGuard)
  update(@Param('id') id: string, @Body() updateEntertainmentDto: UpdateEntertainmentDto) {
    return this.entertainmentService.update(id, updateEntertainmentDto);
  }

  @Delete(':id')
  @UseGuards(SupabaseAuthGuard)
  remove(@Param('id') id: string) {
    return this.entertainmentService.remove(id);
  }
}
