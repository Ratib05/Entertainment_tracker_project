import { IsInt, IsNotEmpty, IsOptional, IsUUID, Min } from 'class-validator';

export class AddListItemDto {
  @IsUUID()
  @IsNotEmpty()
  entertainment_id!: string;

  @IsInt()
  @Min(0)
  @IsOptional()
  order_index?: number;
}
