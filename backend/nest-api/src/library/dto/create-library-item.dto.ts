import { IsEnum, IsNotEmpty, IsNumber, IsOptional, IsUUID, Max, Min } from 'class-validator';
import { WatchStatus } from '../../common/enums/watch-status.enum';

export class CreateLibraryItemDto {
  @IsUUID()
  @IsNotEmpty()
  entertainment_id!: string;

  @IsEnum(WatchStatus)
  @IsOptional()
  status?: WatchStatus;

  @IsNumber()
  @Min(0)
  @Max(100)
  @IsOptional()
  progress?: number;

  @IsNumber()
  @Min(0)
  @Max(99999)
  @IsOptional()
  hours_played?: number;
}
