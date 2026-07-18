import { IsInt, IsNotEmpty, IsOptional, IsUUID } from 'class-validator';

export class AddListItemDto {
  @IsUUID()
  @IsNotEmpty()
  entertainment_id: string;

  @IsInt()
  @IsOptional()
  order_index?: number;
}
