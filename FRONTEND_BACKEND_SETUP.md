# Frontend-Backend Connection Setup

## Overview
The Flutter frontend now connects to the NestJS backend API using:
- **Authentication**: Supabase Auth (JWT tokens)
- **HTTP Client**: Dio package for API calls
- **State Management**: Provider package for data flow

## Architecture

### Backend (NestJS)
- **Port**: 3000 (default)
- **Base URL**: `http://localhost:3000`
- **Auth**: Supabase JWT tokens via Bearer token in Authorization header

### Frontend (Flutter)
- **Providers**:
  - `AuthProvider`: Handles Supabase authentication and token management
  - `EntertainmentProvider`: Manages entertainment data from the backend
  - `ApiService`: HTTP client for backend API calls

## Setup Steps

### 1. Configure Supabase
Edit `lib/main.dart` and add your Supabase credentials:

```dart
await Supabase.initialize(
  url: 'https://your-project.supabase.co',
  anonKey: 'your-anon-key',
);
```

### 2. Set Backend URL
The API service uses `http://localhost:3000` by default. Update in `lib/services/api_service.dart` if needed:

```dart
static const String baseUrl = 'http://localhost:3000';
```

### 3. Run Backend
```bash
cd backend/nest-api
npm install
npm run start:dev
```

### 4. Configure CORS (Backend)
The backend needs to allow requests from your Flutter app. Set environment variable:

```bash
CORS_ORIGIN=http://localhost:3000
```

For development with Flutter mobile, use your machine's IP or ngrok tunnel.

### 5. Run Frontend
```bash
cd frontend
flutter pub get
flutter run
```

## API Flow

### Authentication
1. User enters email/password in LoginScreen
2. AuthProvider calls `signIn()` → Supabase authenticates user
3. Supabase returns JWT token and user info
4. AuthProvider sets token in ApiService headers
5. ApiService verifies token with backend `/auth/me` endpoint

### Data Fetching
1. Screen calls EntertainmentProvider method (e.g., `fetchAll()`)
2. Provider calls ApiService method
3. ApiService sends authenticated HTTP request to backend
4. Response parsed into Entertainment model objects
5. Provider notifies listeners of state changes
6. UI rebuilds with new data

## Available Endpoints

### Authentication
- `GET /auth/me` - Get current user profile (requires auth)

### Entertainment
- `GET /entertainment` - List all entertainment items
- `GET /entertainment/:id` - Get specific item
- `POST /entertainment` - Create new item (requires auth)
- `PATCH /entertainment/:id` - Update item (requires auth)
- `DELETE /entertainment/:id` - Delete item (requires auth)

### Other Endpoints
- `GET/POST /lists` - Manage entertainment lists
- `GET/POST /reviews` - Manage reviews
- `GET /statistics` - Get user statistics
- `GET /users/profile` - Get user profile

## Creating New Features

### To add a new endpoint to the frontend:

1. **Add method to ApiService** (`lib/services/api_service.dart`):
```dart
Future<List<dynamic>> getNewFeature() async {
  try {
    final response = await _dio.get('/new-feature');
    return response.data;
  } catch (e) {
    rethrow;
  }
}
```

2. **Create a Provider** for state management (if needed):
```dart
class NewFeatureProvider extends ChangeNotifier {
  final ApiService _apiService;
  
  Future<void> fetchData() async {
    final response = await _apiService.getNewFeature();
    // Handle response
    notifyListeners();
  }
}
```

3. **Add Provider to main.dart** MultiProvider setup

4. **Use in UI** with Consumer or context.read()

## Troubleshooting

### CORS Errors
- Ensure backend CORS_ORIGIN is set correctly
- Check backend is running on correct port
- For Flutter mobile, use your machine IP instead of localhost

### 401 Unauthorized
- Token might be expired, call `AuthProvider.refreshToken()`
- Ensure user is logged in before making authenticated requests

### Backend Not Reachable
- Check backend is running: `http://localhost:3000`
- Check firewall settings
- Use ngrok for mobile testing: `ngrok http 3000`

### Models Not Parsing
- Verify API response matches model factory constructors
- Check field names match exactly (camelCase vs snake_case)
- Add debugging: print response before parsing

## Files Created

- `lib/services/api_service.dart` - HTTP client
- `lib/models/entertainment.dart` - Entertainment data model
- `lib/models/media_type.dart` - Media type enum
- `lib/providers/auth_provider.dart` - Authentication state
- `lib/providers/entertainment_provider.dart` - Entertainment data state
