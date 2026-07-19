-- Create reviews table
CREATE TABLE public.reviews (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  entertainment_id UUID NOT NULL REFERENCES public.entertainment(id) ON DELETE CASCADE,
  rating DECIMAL(3,1) NOT NULL CHECK (rating >= 0 AND rating <= 10),
  review_text TEXT,
  spoiler_warning BOOLEAN DEFAULT false,
  helpful_count INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create lists table
CREATE TABLE public.lists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  is_public BOOLEAN DEFAULT false,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create list items table
CREATE TABLE public.list_items (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  list_id UUID NOT NULL REFERENCES public.lists(id) ON DELETE CASCADE,
  entertainment_id UUID NOT NULL REFERENCES public.entertainment(id) ON DELETE CASCADE,
  order_index INT DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create statistics table (cached data for performance)
CREATE TABLE public.statistics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES public.users(id) ON DELETE CASCADE,
  total_games INT DEFAULT 0,
  total_movies INT DEFAULT 0,
  total_shows INT DEFAULT 0,
  total_hours_played INT DEFAULT 0,
  average_game_rating DECIMAL(3,1),
  average_movie_rating DECIMAL(3,1),
  average_show_rating DECIMAL(3,1),
  favorite_genre VARCHAR(100),
  last_updated TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Create indexes
CREATE INDEX idx_reviews_user_id ON public.reviews(user_id);
CREATE INDEX idx_reviews_entertainment_id ON public.reviews(entertainment_id);
CREATE INDEX idx_lists_user_id ON public.lists(user_id);
CREATE INDEX idx_list_items_list_id ON public.list_items(list_id);
CREATE INDEX idx_list_items_entertainment_id ON public.list_items(entertainment_id);
CREATE INDEX idx_statistics_user_id ON public.statistics(user_id);

-- Enable RLS
ALTER TABLE public.reviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.lists ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.list_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.statistics ENABLE ROW LEVEL SECURITY;

-- RLS Policies for reviews
CREATE POLICY "Users can view all reviews" ON public.reviews
  FOR SELECT USING (true);

CREATE POLICY "Users can create reviews" ON public.reviews
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own reviews" ON public.reviews
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own reviews" ON public.reviews
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for lists
CREATE POLICY "Users can view own lists" ON public.lists
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can view public lists" ON public.lists
  FOR SELECT USING (is_public = true);

CREATE POLICY "Users can create lists" ON public.lists
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own lists" ON public.lists
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can delete own lists" ON public.lists
  FOR DELETE USING (auth.uid() = user_id);

-- RLS Policies for list_items (inherit from lists)
CREATE POLICY "Users can view list items from accessible lists" ON public.list_items
  FOR SELECT USING (
    list_id IN (
      SELECT id FROM public.lists WHERE user_id = auth.uid() OR is_public = true
    )
  );

CREATE POLICY "Users can add items to own lists" ON public.list_items
  FOR INSERT WITH CHECK (
    list_id IN (SELECT id FROM public.lists WHERE user_id = auth.uid())
  );

CREATE POLICY "Users can remove items from own lists" ON public.list_items
  FOR DELETE USING (
    list_id IN (SELECT id FROM public.lists WHERE user_id = auth.uid())
  );

-- RLS Policies for statistics
CREATE POLICY "Users can view own statistics" ON public.statistics
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own statistics" ON public.statistics
  FOR UPDATE USING (auth.uid() = user_id);

-- Trigger for updated_at
CREATE TRIGGER update_reviews_timestamp
BEFORE UPDATE ON public.reviews
FOR EACH ROW
EXECUTE FUNCTION update_entertainment_updated_at();

CREATE TRIGGER update_lists_timestamp
BEFORE UPDATE ON public.lists
FOR EACH ROW
EXECUTE FUNCTION update_entertainment_updated_at();
