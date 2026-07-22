import { IsEnum, IsOptional } from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class GenreListTmdbDto {
  @IsEnum(MediaType)
  @IsOptional()
  type?: MediaType;
}
