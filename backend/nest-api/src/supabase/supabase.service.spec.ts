const mockGetUser = jest.fn();
const createClientMock = jest.fn(() => ({ auth: { getUser: mockGetUser } }));

jest.mock('@supabase/supabase-js', () => ({
  createClient: createClientMock,
}));

describe('SupabaseService', () => {
  let SupabaseService: any;
  let service: any;

  beforeEach(() => {
    jest.resetModules();
    process.env.SUPABASE_URL = 'http://localhost';
    process.env.SUPABASE_SERVICE_ROLE_KEY = 'test-service-role-key';

    mockGetUser.mockReset();
    createClientMock.mockReset();
    createClientMock.mockReturnValue({ auth: { getUser: mockGetUser } });

    const module = require('./supabase.service');
    SupabaseService = module.SupabaseService;
    service = new SupabaseService();
  });

  afterEach(() => {
    delete process.env.SUPABASE_URL;
    delete process.env.SUPABASE_SERVICE_ROLE_KEY;
  });

  it('should create a Supabase client and return it', () => {
    const client = service.getClient();
    expect(createClientMock).toHaveBeenCalledWith('http://localhost', 'test-service-role-key', {
      auth: {
        persistSession: false,
      },
    });
    expect(client).toEqual({ auth: { getUser: mockGetUser } });
  });

  it('should return a user when access token is valid', async () => {
    const expectedUser = { id: 'user-id', email: 'user@example.com' };
    mockGetUser.mockResolvedValue({ data: { user: expectedUser }, error: null });

    const user = await service.getUserByAccessToken('valid-token');

    expect(mockGetUser).toHaveBeenCalledWith('valid-token');
    expect(user).toEqual(expectedUser);
  });

  it('should throw when access token is invalid', async () => {
    mockGetUser.mockResolvedValue({ data: null, error: { message: 'Invalid token' } });

    await expect(service.getUserByAccessToken('invalid-token')).rejects.toThrow('Invalid token');
    expect(mockGetUser).toHaveBeenCalledWith('invalid-token');
  });
});
