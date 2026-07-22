import {
  CanActivate,
  ExecutionContext,
  ForbiddenException,
  Injectable,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class AdminGuard implements CanActivate {
  private readonly adminUserIds: Set<string>;

  constructor(private readonly configService: ConfigService) {
    const raw = this.configService.get<string>('ADMIN_USER_IDS') ?? '';
    this.adminUserIds = new Set(
      raw
        .split(',')
        .map((id) => id.trim())
        .filter(Boolean),
    );
  }

  canActivate(context: ExecutionContext): boolean {
    const request = context.switchToHttp().getRequest();
    const userId = request.user?.id as string | undefined;

    if (!userId || !this.adminUserIds.has(userId)) {
      throw new ForbiddenException('Admin access required');
    }

    return true;
  }
}
