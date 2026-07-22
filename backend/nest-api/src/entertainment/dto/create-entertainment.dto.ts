import {
  IsArray,
  IsDateString,
  IsEnum,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class CreateEntertainmentDto {
  @IsString()
  @MaxLength(200)
  @IsOptional()
  external_id?: string;

  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  title!: string;

  @IsEnum(MediaType)
  type!: MediaType;

  @IsString()
  @MaxLength(5000)
  @IsOptional()
  description?: string;

  @IsString()
  @MaxLength(2000)
  @IsOptional()
  poster?: string;

  @IsDateString()
  @IsOptional()
  release_date?: string;

  @IsArray()
  @IsString({ each: true })
  @MaxLength(100, { each: true })
  @IsOptional()
  genres?: string[];

  @IsString()
  @MaxLength(200)
  @IsOptional()
  developer?: string;

  @IsString()
  @MaxLength(200)
  @IsOptional()
  studio?: string;

  @IsNumber()
  @Min(0)
  @Max(10)
  @IsOptional()
  rating?: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  runtime_minutes?: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  episode_runtime_minutes?: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  number_of_episodes?: number;

  @IsNumber()
  @Min(0)
  @IsOptional()
  number_of_seasons?: number;

  @IsArray()
  @IsOptional()
  seasons?: Array<{ season_number: number; episode_count: number; name: string }>;
}
