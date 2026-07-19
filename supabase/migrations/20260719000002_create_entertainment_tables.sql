-- Create entertainment base table
CREATE TABLE public.entertainment (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  type VARCHAR(50) NOT NULL CHECK (type IN ('film', 'show', 'game')),
  description TEXT,
  poster VARCHAR(2000),
  release_date DATE,
  genres TEXT[] DEFAULT '{}',
  developer VARCHAR(200),
  studio VARCHAR(200),
  rating DECIMAL(3,1) CHECK (rating >= 0 AND rating <= 10),
  status VARCHAR(50) DEFAULT 'to_watch' CHECK (status IN ('to_watch', 'watching', 'watched', 'completed', 'abandoned')),
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create games table
CREATE TABLE public.games (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entertainment_id UUID NOT NULL REFERENCES public.entertainment(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  developer VARCHAR(200),
  release_date DATE,
  genres TEXT[] DEFAULT '{}',
  platforms TEXT[] DEFAULT '{}',
  rating DECIMAL(3,1),
  playtime_hours INT DEFAULT 0,
  completion_percentage INT DEFAULT 0 CHECK (completion_percentage >= 0 AND completion_percentage <= 100),
  status VARCHAR(50) DEFAULT 'to_play' CHECK (status IN ('to_play', 'playing', 'completed', 'abandoned', 'platinum')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create movies table
CREATE TABLE public.movies (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entertainment_id UUID NOT NULL REFERENCES public.entertainment(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  studio VARCHAR(200),
  director VARCHAR(200),
  release_date DATE,
  genres TEXT[] DEFAULT '{}',
  rating DECIMAL(3,1),
  runtime_minutes INT,
  watched_date DATE,
  status VARCHAR(50) DEFAULT 'to_watch' CHECK (status IN ('to_watch', 'watching', 'watched')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create shows table
CREATE TABLE public.shows (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entertainment_id UUID NOT NULL REFERENCES public.entertainment(id) ON DELETE CASCADE,
  title VARCHAR(500) NOT NULL,
  studio VARCHAR(200),
  creator VARCHAR(200),
  release_date DATE,
  genres TEXT[] DEFAULT '{}',
  rating DECIMAL(3,1),
  total_episodes INT,
  watched_episodes INT DEFAULT 0,
  total_seasons INT,
  watched_seasons INT DEFAULT 0,
  status VARCHAR(50) DEFAULT 'to_watch' CHECK (status IN ('to_watch', 'watching', 'on_hold', 'completed', 'abandoned')),
  notes TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes for faster queries
CREATE INDEX idx_entertainment_user_id ON public.entertainment(user_id);
CREATE INDEX idx_entertainment_type ON public.entertainment(type);
CREATE INDEX idx_entertainment_status ON public.entertainment(status);
CREATE INDEX idx_games_user_id ON public.games(user_id);
CREATE INDEX idx_games_status ON public.games(status);
CREATE INDEX idx_movies_user_id ON public.movies(user_id);
CREATE INDEX idx_movies_status ON public.movies(status);
CREATE INDEX idx_shows_user_id ON public.shows(user_id);
CREATE INDEX idx_shows_status ON public.shows(status);

-- Enable RLS on all entertainment tables
ALTER TABLE public.entertainment ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.games ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.movies ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.shows ENABLE ROW LEVEL SECURITY;

-- RLS Policies for entertainment table
CREATE POLICY "Users can view own entertainment" ON public.entertainment
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create entertainment" ON public.entertainment
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own entertainment" ON public.entertainment
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own entertainment" ON public.entertainment
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for games table
CREATE POLICY "Users can view own games" ON public.games
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create games" ON public.games
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own games" ON public.games
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own games" ON public.games
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for movies table
CREATE POLICY "Users can view own movies" ON public.movies
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create movies" ON public.movies
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own movies" ON public.movies
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own movies" ON public.movies
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for shows table
CREATE POLICY "Users can view own shows" ON public.shows
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can create shows" ON public.shows
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own shows" ON public.shows
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own shows" ON public.shows
  FOR DELETE USING (auth.uid() = user_id);

-- Trigger to update entertainment updated_at
CREATE OR REPLACE FUNCTION update_entertainment_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_entertainment_timestamp
BEFORE UPDATE ON public.entertainment
FOR EACH ROW
EXECUTE FUNCTION update_entertainment_updated_at();

CREATE TRIGGER update_games_timestamp
BEFORE UPDATE ON public.games
FOR EACH ROW
EXECUTE FUNCTION update_entertainment_updated_at();

CREATE TRIGGER update_movies_timestamp
BEFORE UPDATE ON public.movies
FOR EACH ROW
EXECUTE FUNCTION update_entertainment_updated_at();

CREATE TRIGGER update_shows_timestamp
BEFORE UPDATE ON public.shows
FOR EACH ROW
EXECUTE FUNCTION update_entertainment_updated_at();
