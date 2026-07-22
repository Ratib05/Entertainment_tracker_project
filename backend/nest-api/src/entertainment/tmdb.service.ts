import { Injectable, BadRequestException, InternalServerErrorException } from '@nestjs/common';
import { HttpService } from '@nestjs/axios';
import { firstValueFrom } from 'rxjs';
import { MediaType } from '../common/enums/media-type.enum';

interface TmdbSearchResponse {
  results: Array<{
    id: number;
    title?: string;
    name?: string;
    overview: string;
    poster_path: string | null;
    release_date?: string;
    first_air_date?: string;
    genre_ids: number[];
  }>;
}

interface TmdbMovieDetails {
  id: number;
  title: string;
  overview: string;
  poster_path: string | null;
  release_date: string;
  genres: Array<{ name: string }>;
  runtime: number | null;
}

interface TmdbShowDetails {
  id: number;
  name: string;
  overview: string;
  poster_path: string | null;
  first_air_date: string;
  genres: Array<{ name: string }>;
  episode_run_time: number[];
  number_of_episodes: number | null;
  number_of_seasons: number | null;
  seasons: Array<{ season_number: number; episode_count: number; name: string }>;
}

interface TmdbGenreListResponse {
  genres: Array<{ id: number; name: string }>;
}

interface TmdbWatchProvidersResponse {
  results: Record<
    string,
    {
      link: string;
      flatrate?: Array<{ provider_name: string; logo_path: string }>;
      rent?: Array<{ provider_name: string; logo_path: string }>;
      buy?: Array<{ provider_name: string; logo_path: string }>;
    }
  >;
}

@Injectable()
export class TmdbService {
  private readonly baseUrl = 'https://api.themoviedb.org/3';
  private readonly accessToken = process.env.TMDB_ACCESS_TOKEN;
  private readonly apiKey = process.env.TMDB_API_KEY;

  constructor(private readonly httpService: HttpService) {
    if (!this.accessToken && !this.apiKey) {
      throw new InternalServerErrorException(
        'Either TMDB_ACCESS_TOKEN or TMDB_API_KEY environment variable must be set',
      );
    }
  }

  private genreListCache = new Map<MediaType, Array<{ id: number; name: string }>>();

  private get requestConfig() {
    if (this.accessToken) {
      return { headers: { Authorization: `Bearer ${this.accessToken}` }, params: {} };
    }
    return { headers: {}, params: { api_key: this.apiKey } };
  }

  private async getGenreList(type: MediaType): Promise<Array<{ id: number; name: string }>> {
    const cached = this.genreListCache.get(type);
    if (cached) return cached;

    const { headers, params } = this.requestConfig;
    const path = type === MediaType.Show ? '/genre/tv/list' : '/genre/movie/list';

    const response = await firstValueFrom(
      this.httpService.get<TmdbGenreListResponse>(`${this.baseUrl}${path}`, {
        headers,
        params,
      }),
    );

    this.genreListCache.set(type, response.data.genres);
    return response.data.genres;
  }

  private async getGenreMap(type: MediaType): Promise<Map<string, number>> {
    const list = await this.getGenreList(type);
    const map = new Map<string, number>();
    for (const genre of list) {
      map.set(genre.name.toLowerCase(), genre.id);
    }
    return map;
  }

  // Used to populate a genre filter UI (e.g. selectable chips on Discover).
  async getGenreNames(type: MediaType): Promise<string[]> {
    const list = await this.getGenreList(type);
    return list.map((g) => g.name);
  }

  async searchMovies(query: string, page: number = 1): Promise<any[]> {
    if (!query || query.trim().length === 0) {
      throw new BadRequestException('Search query cannot be empty');
    }

    const { headers, params } = this.requestConfig;

    try {
      const response = await firstValueFrom(
        this.httpService.get<TmdbSearchResponse>(`${this.baseUrl}/search/movie`, {
          headers,
          params: { ...params, query: query.trim(), page, include_adult: false },
        }),
      );

      return response.data.results.map((movie) => ({
        external_id: movie.id.toString(),
        title: movie.title,
        type: MediaType.Film,
        description: movie.overview,
        poster: movie.poster_path ? `https://image.tmdb.org/t/p/w342${movie.poster_path}` : null,
        release_date: movie.release_date || undefined,
        genres: [],
      }));
    } catch (error: any) {
      const status_message = error.response?.data?.status_message;
      throw new InternalServerErrorException(
        `Failed to search TMDB movies: ${status_message ?? error.message}`,
      );
    }
  }

  async searchShows(query: string, page: number = 1): Promise<any[]> {
    if (!query || query.trim().length === 0) {
      throw new BadRequestException('Search query cannot be empty');
    }

    const { headers, params } = this.requestConfig;

    try {
      const response = await firstValueFrom(
        this.httpService.get<TmdbSearchResponse>(`${this.baseUrl}/search/tv`, {
          headers,
          params: { ...params, query: query.trim(), page, include_adult: false },
        }),
      );

      return response.data.results.map((show) => ({
        external_id: show.id.toString(),
        title: show.name,
        type: MediaType.Show,
        description: show.overview,
        poster: show.poster_path ? `https://image.tmdb.org/t/p/w342${show.poster_path}` : null,
        release_date: show.first_air_date || undefined,
        genres: [],
      }));
    } catch (error: any) {
      const status_message = error.response?.data?.status_message;
      throw new InternalServerErrorException(
        `Failed to search TMDB shows: ${status_message ?? error.message}`,
      );
    }
  }

  async search(query: string, mediaType?: MediaType): Promise<any[]> {
    if (mediaType === MediaType.Film) {
      return this.searchMovies(query);
    }
    if (mediaType === MediaType.Show) {
      return this.searchShows(query);
    }

    const results = await Promise.allSettled([this.searchMovies(query), this.searchShows(query)]);

    const successes = results.filter(
      (r): r is PromiseFulfilledResult<any[]> => r.status === 'fulfilled',
    );

    if (successes.length === 0) {
      const firstError = results.find(
        (r): r is PromiseRejectedResult => r.status === 'rejected',
      );
      throw firstError?.reason;
    }

    return successes.flatMap((s) => s.value);
  }

  async getMovieDetails(tmdbId: string): Promise<any> {
    const { headers, params } = this.requestConfig;

    try {
      const response = await firstValueFrom(
        this.httpService.get<TmdbMovieDetails>(`${this.baseUrl}/movie/${tmdbId}`, {
          headers,
          params,
        }),
      );

      const data = response.data;
      return {
        external_id: data.id.toString(),
        title: data.title,
        type: MediaType.Film,
        description: data.overview,
        poster: data.poster_path ? `https://image.tmdb.org/t/p/w342${data.poster_path}` : null,
        release_date: data.release_date || undefined,
        genres: data.genres.map((g) => g.name),
        runtime_minutes: data.runtime || undefined,
      };
    } catch (error: any) {
      const status_message = error.response?.data?.status_message;
      throw new InternalServerErrorException(
        `Failed to fetch movie details from TMDB: ${status_message ?? error.message}`,
      );
    }
  }

  async getShowDetails(tmdbId: string): Promise<any> {
    const { headers, params } = this.requestConfig;

    try {
      const response = await firstValueFrom(
        this.httpService.get<TmdbShowDetails>(`${this.baseUrl}/tv/${tmdbId}`, {
          headers,
          params,
        }),
      );

      const data = response.data;
      return {
        external_id: data.id.toString(),
        title: data.name,
        type: MediaType.Show,
        description: data.overview,
        poster: data.poster_path ? `https://image.tmdb.org/t/p/w342${data.poster_path}` : null,
        release_date: data.first_air_date || undefined,
        genres: data.genres.map((g) => g.name),
        episode_runtime_minutes: data.episode_run_time?.[0] || undefined,
        number_of_episodes: data.number_of_episodes || undefined,
        number_of_seasons: data.number_of_seasons || undefined,
        seasons: (data.seasons ?? [])
          .filter((s) => s.season_number > 0)
          .map((s) => ({
            season_number: s.season_number,
            episode_count: s.episode_count,
            name: s.name,
          })),
      };
    } catch (error: any) {
      const status_message = error.response?.data?.status_message;
      throw new InternalServerErrorException(
        `Failed to fetch show details from TMDB: ${status_message ?? error.message}`,
      );
    }
  }

  // Excludes R18+, X18+, and Refused Classification content under Australia's
  // classification scheme (movies only — TMDB's TV discover has no
  // certification filter). This only applies to Discover; explicit search
  // is never filtered.
  async discover(
    genreNames: string[],
    type: MediaType,
    page: number = 1,
    sort: 'popularity' | 'rating' | 'newest' = 'popularity',
  ): Promise<any[]> {
    const { headers, params } = this.requestConfig;
    const isShow = type === MediaType.Show;

    let genreIds: number[] = [];
    if (genreNames.length > 0) {
      const genreMap = await this.getGenreMap(type);
      genreIds = genreNames
        .map((name) => genreMap.get(name.toLowerCase()))
        .filter((id): id is number => id !== undefined);
    }

    const path = isShow ? '/discover/tv' : '/discover/movie';

    const sortByParam = {
      popularity: 'popularity.desc',
      rating: 'vote_average.desc',
      newest: isShow ? 'first_air_date.desc' : 'primary_release_date.desc',
    }[sort];

    const requestParams: Record<string, unknown> = {
      ...params,
      page,
      sort_by: sortByParam,
      include_adult: false,
      // A vote-count floor keeps obscure, low-sample titles from skewing
      // "Top Rated" (e.g. a single 10/10 vote) or cluttering the feed.
      'vote_count.gte': sort === 'rating' ? 100 : 20,
    };

    if (genreIds.length > 0) {
      // Pipe = match ANY selected genre (OR). A comma would require ALL of
      // them at once (AND), which is far too narrow for "genres you like".
      requestParams.with_genres = genreIds.join('|');
    }

    if (!isShow) {
      requestParams.certification_country = 'AU';
      requestParams['certification.lte'] = 'MA15+';
    }

    try {
      const response = await firstValueFrom(
        this.httpService.get<TmdbSearchResponse>(`${this.baseUrl}${path}`, {
          headers,
          params: requestParams,
        }),
      );

      return response.data.results.map((item) => ({
        external_id: item.id.toString(),
        title: isShow ? item.name : item.title,
        type,
        description: item.overview,
        poster: item.poster_path ? `https://image.tmdb.org/t/p/w342${item.poster_path}` : null,
        release_date: (isShow ? item.first_air_date : item.release_date) || undefined,
        genres: [],
      }));
    } catch (error: any) {
      const status_message = error.response?.data?.status_message;
      throw new InternalServerErrorException(
        `Failed to fetch TMDB recommendations: ${status_message ?? error.message}`,
      );
    }
  }
}
