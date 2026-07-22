import { IsString, IsNotEmpty, IsEnum, IsOptional } from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class WatchProvidersTmdbDto {
  @IsString()
  @IsNotEmpty()
  tmdbId!: string;

  @IsEnum(MediaType)
  type!: MediaType;

  @IsString()
  @IsOptional()
  region?: string;
}
