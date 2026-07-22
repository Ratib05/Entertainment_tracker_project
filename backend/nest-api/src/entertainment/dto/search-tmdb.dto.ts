import { IsString, IsNotEmpty, IsOptional, IsEnum } from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class SearchTmdbDto {
  @IsString()
  @IsNotEmpty()
  query!: string;

  @IsEnum(MediaType)
  @IsOptional()
  type?: MediaType;
}
