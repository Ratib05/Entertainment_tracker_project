# Supabase Database Setup

This guide will help you set up the database schema for the Entertainment Tracker application.

## Option 1: Using Supabase Web Dashboard (Easiest)

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `gauoglgismrwxtwsdaci`
3. Click on **SQL Editor** (left sidebar)
4. Click **New Query**
5. Copy and paste the SQL from each migration file below
6. Click **Run** after each file

### Migration Files (in order):

#### 1. Users Table
Copy all SQL from: `supabase/migrations/20260719000001_create_users_table.sql`

#### 2. Entertainment Tables (Games, Movies, Shows)
Copy all SQL from: `supabase/migrations/20260719000002_create_entertainment_tables.sql`

#### 3. Reviews & Lists
Copy all SQL from: `supabase/migrations/20260719000003_create_reviews_and_lists.sql`

---

## Option 2: Using Supabase CLI

### Prerequisites
- Supabase CLI installed: `npm install -g supabase`
- PostgreSQL client (`psql`) installed

### Steps

1. **Authenticate with Supabase**
   ```bash
   supabase login
   ```

2. **Link your project**
   ```bash
   cd supabase
   supabase link --project-ref gauoglgismrwxtwsdaci
   ```

3. **Run migrations**
   ```bash
   supabase migration up
   ```

---

## Option 3: Direct PostgreSQL Connection

### Get Connection String

1. Go to Supabase Dashboard → Settings → Database
2. Copy the **Connection string** (URI format)
3. It should look like:
   ```
   postgresql://[user]:[password]@[host]:[port]/postgres
   ```

### Run Migrations

```bash
psql [CONNECTION_STRING] < supabase/migrations/20260719000001_create_users_table.sql
psql [CONNECTION_STRING] < supabase/migrations/20260719000002_create_entertainment_tables.sql
psql [CONNECTION_STRING] < supabase/migrations/20260719000003_create_reviews_and_lists.sql
```

---

## Verify Setup

After running migrations, check in Supabase Dashboard → Database → Tables:

You should see these tables:
- ✅ `users`
- ✅ `entertainment`
- ✅ `games`
- ✅ `movies`
- ✅ `shows`
- ✅ `reviews`
- ✅ `lists`
- ✅ `list_items`
- ✅ `statistics`

---

## Authentication Setup

### Email/Password with Username

The migrations already set up the database structure. Supabase Auth handles email/password automatically. The `username` field in the `users` table links Supabase Auth to your user profile.

### Auth Flow

1. **Registration**: User provides email, password, and desired username
2. **Supabase**: Creates auth user with email/password
3. **Backend**: Creates user profile record with username
4. **Login**: User enters email and password (standard Supabase Auth)

### Password Policies in Flutter UI

The Flutter app will show these password requirements:

```
Requirements:
✓ At least 8 characters
✓ At least 1 uppercase letter
✓ At least 1 number
✓ At least 1 special character (!@#$%^&*)
```

### Enable Policies in Supabase

Go to Supabase Dashboard → Authentication → Policies

Recommended settings:
```
- Email confirmations: Required
- Minimum password length: 8 characters
- Password hashing: bcrypt (default)
- 2FA: Optional (users can enable)
```

---

## Database Schema Overview

### Users Table
- Links to Supabase Auth users
- Stores username and public profile info
- RLS: Users can only access own profile

### Entertainment Table
- Base table for games, movies, and shows
- Tracks `type` (film, show, game)
- Stores rating, status, genres
- RLS: Users can only access own entries

### Games Table
- Extends entertainment with game-specific fields
- Tracks playtime, completion percentage
- Platforms and developer info

### Movies Table
- Extends entertainment with movie-specific fields
- Tracks director, runtime, watch date
- Studio and runtime information

### Shows Table
- Extends entertainment with show-specific fields
- Tracks seasons, episodes watched
- Series status (watching, completed, etc.)

### Reviews & Lists
- Reviews: User ratings and text reviews
- Lists: Custom watchlists and playlists
- List Items: Items in each list with ordering

### Statistics Table
- Cached aggregate data for performance
- Total counts by type
- Average ratings
- Favorite genres
- Updated periodically by backend

---

## RLS (Row Level Security) Policies

All tables have Row Level Security enabled:

- **SELECT**: Users can only see their own data
- **INSERT**: Users can only create records for themselves
- **UPDATE**: Users can only modify their own records
- **DELETE**: Users can only delete their own records

This means:
- Users cannot access other users' data
- The `user_id` is automatically set from the authenticated user's ID
- No server-side validation needed for data isolation

---

## Next Steps

1. Run the migrations (choose any option above)
2. Test the API endpoints with the backend running
3. Update Flutter frontend to use the new tables
4. Create UI screens for games, movies, and shows

---

## Troubleshooting

### "Role does not exist" error
- Ensure you're logged in to Supabase
- Check project ID is correct

### "Table already exists" error
- Tables already created from previous run
- Drop the tables and re-run migrations, or skip this migration

### Connection refused
- Check PostgreSQL is running
- Verify connection string is correct
- Check firewall settings

### RLS Policy errors
- Ensure user is authenticated
- Check `user_id` matches `auth.uid()`
- Verify policies are enabled on table
