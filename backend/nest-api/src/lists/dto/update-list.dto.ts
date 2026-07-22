import { IsOptional, IsString, MaxLength } from 'class-validator';

export class UpdateListDto {
  @IsString()
  @MaxLength(200)
  @IsOptional()
  title?: string;

  @IsString()
  @MaxLength(2000)
  @IsOptional()
  description?: string;
}
