import { IsArray, IsDateString, IsEnum, IsNumber, IsOptional, IsString } from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class UpdateEntertainmentDto {
  @IsString()
  @IsOptional()
  title?: string;

  @IsEnum(MediaType)
  @IsOptional()
  type?: MediaType;

  @IsString()
  @IsOptional()
  description?: string;

  @IsString()
  @IsOptional()
  poster?: string;

  @IsDateString()
  @IsOptional()
  release_date?: string;

  @IsArray()
  @IsString({ each: true })
  @IsOptional()
  genres?: string[];

  @IsString()
  @IsOptional()
  developer?: string;

  @IsString()
  @IsOptional()
  studio?: string;

  @IsNumber()
  @IsOptional()
  rating?: number;
}
