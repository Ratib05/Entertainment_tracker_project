import { IsEmail, IsNotEmpty, IsString, IsOptional } from 'class-validator';

export class CreateUserDto {
  @IsEmail()
  email: string;

  @IsString()
  @IsOptional()
  username?: string;

  @IsString()
  @IsOptional()
  avatar_url?: string;
}
