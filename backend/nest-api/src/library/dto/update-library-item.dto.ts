import { IsEnum, IsNumber, IsOptional, IsUUID } from 'class-validator';
import { WatchStatus } from '../../common/enums/watch-status.enum';

export class UpdateLibraryItemDto {
  @IsUUID()
  @IsOptional()
  entertainment_id?: string;

  @IsEnum(WatchStatus)
  @IsOptional()
  status?: WatchStatus;

  @IsNumber()
  @IsOptional()
  progress?: number;

  @IsNumber()
  @IsOptional()
  hours_played?: number;
}
