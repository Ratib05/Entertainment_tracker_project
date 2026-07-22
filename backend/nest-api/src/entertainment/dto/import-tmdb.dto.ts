import { IsString, IsNotEmpty, IsEnum } from 'class-validator';
import { MediaType } from '../../common/enums/media-type.enum';

export class ImportTmdbDto {
  @IsString()
  @IsNotEmpty()
  tmdbId!: string;

  @IsEnum(MediaType)
  type!: MediaType;
}
