import { Controller, Get } from '@nestjs/common';

@Controller('supabase')
export class SupabaseController {
  @Get('health')
  async health() {
    return { status: 'ok' };
  }
}
