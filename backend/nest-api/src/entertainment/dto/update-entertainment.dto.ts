import {
  IsArray,
  IsDateString,
  IsEnum,
  IsNumber,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class UpdateEntertainmentDto {
  @IsString()
  @MaxLength(500)
  @IsOptional()
  title?: string;

  @IsEnum(MediaType)
  @IsOptional()
  type?: MediaType;

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
}
