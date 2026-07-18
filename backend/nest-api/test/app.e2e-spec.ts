import { Test, TestingModule } from '@nestjs/testing';
import { ExecutionContext, INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { SupabaseService } from '../src/supabase/supabase.service';
import { SupabaseAuthGuard } from '../src/auth/supabase-auth.guard';
import { AuthService } from '../src/auth/auth.service';
import { UsersService } from '../src/users/users.service';

const mockUser = {
  id: '00000000-0000-0000-0000-000000000001',
  email: 'test@example.com',
  username: 'test-user',
  avatar_url: 'https://example.com/avatar.png',
};

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(SupabaseService)
      .useValue({})
      .overrideProvider(SupabaseAuthGuard)
      .useValue({
        canActivate: (context: ExecutionContext) => {
          const req = context.switchToHttp().getRequest();
          req.user = mockUser;
          return true;
        },
      })
      .overrideProvider(AuthService)
      .useValue({
        getProfile: async () => ({
          id: mockUser.id,
          email: mockUser.email,
          username: mockUser.username,
          avatar_url: mockUser.avatar_url,
        }),
      })
      .overrideProvider(UsersService)
      .useValue({
        findOne: async () => ({
          id: mockUser.id,
          email: mockUser.email,
          username: mockUser.username,
          avatar_url: mockUser.avatar_url,
          created_at: new Date().toISOString(),
        }),
        update: async (id: string, dto: any) => ({
          id,
          ...dto,
        }),
      })
      .compile();

    app = moduleFixture.createNestApplication();
    await app.init();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect('Hello World!');
  });

  it('/supabase/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/supabase/health')
      .expect(200)
      .expect({ status: 'ok' });
  });

  it('/auth/me (GET)', () => {
    return request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', 'Bearer mocked-token')
      .expect(200)
      .expect({ user: { id: mockUser.id, email: mockUser.email, username: mockUser.username, avatar_url: mockUser.avatar_url } });
  });

  it('/users/me (GET)', () => {
    return request(app.getHttpServer())
      .get('/users/me')
      .set('Authorization', 'Bearer mocked-token')
      .expect(200)
      .expect({ id: mockUser.id, email: mockUser.email, username: mockUser.username, avatar_url: mockUser.avatar_url, created_at: expect.any(String) });
  });

  afterEach(async () => {
    await app.close();
  });
});
