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

  it('should create an admin client with service role key', () => {
    const client = service.getAdminClient();
    expect(createClientMock).toHaveBeenCalledWith('http://localhost', 'test-service-role-key', expect.any(Object));
    expect(client).toEqual({ auth: { getUser: mockGetUser } });
  });

  it('should create a user client with JWT auth header', () => {
    const client = service.getUserClient('test-jwt-token');
    expect(createClientMock).toHaveBeenCalledWith('http://localhost', 'test-service-role-key', expect.objectContaining({
      global: {
        headers: { Authorization: 'Bearer test-jwt-token' },
      },
    }));
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
