import { Type } from 'class-transformer';
import { IsString, IsOptional, IsEnum, IsInt, IsIn, Min } from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class DiscoverTmdbDto {
  @IsString()
  @IsOptional()
  genres?: string;

  @IsEnum(MediaType)
  @IsOptional()
  type?: MediaType;

  @Type(() => Number)
  @IsInt()
  @Min(1)
  @IsOptional()
  page?: number;

  @IsIn(['popularity', 'rating', 'newest'])
  @IsOptional()
  sort?: 'popularity' | 'rating' | 'newest';
}
