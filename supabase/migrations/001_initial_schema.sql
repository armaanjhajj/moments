-- Moments v2 — Full Database Schema (Phone Auth)
-- Run this in your Supabase SQL Editor
-- Old Supabase: https://pbknjttdonksujqfqano.supabase.co
-- Auth: Phone/OTP via Twilio (already configured)

-- ============================================
-- DROP EVERYTHING FIRST (clean slate)
-- ============================================

-- Drop OLD v1 tables (from original database)
DROP TABLE IF EXISTS saved_room_messages CASCADE;
DROP TABLE IF EXISTS room_messages CASCADE;
DROP TABLE IF EXISTS room_members CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS user_user_edges CASCADE;
DROP TABLE IF EXISTS user_moment_edges CASCADE;
DROP TABLE IF EXISTS user_presence CASCADE;
DROP TABLE IF EXISTS spot_tips CASCADE;
DROP TABLE IF EXISTS spot_busyness_reports CASCADE;
DROP TABLE IF EXISTS sotd_history CASCADE;
DROP TABLE IF EXISTS site_config CASCADE;
DROP TABLE IF EXISTS reports CASCADE;
DROP TABLE IF EXISTS profile_views CASCADE;
DROP TABLE IF EXISTS profile_artifacts CASCADE;
DROP TABLE IF EXISTS pin_reactions CASCADE;
DROP TABLE IF EXISTS pin_comments CASCADE;
DROP TABLE IF EXISTS pins CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS notifications CASCADE;
DROP TABLE IF EXISTS moment_views CASCADE;
DROP TABLE IF EXISTS moment_likes CASCADE;
DROP TABLE IF EXISTS moment_comments CASCADE;
DROP TABLE IF EXISTS moment_comment_likes CASCADE;
DROP TABLE IF EXISTS messages CASCADE;
DROP TABLE IF EXISTS moments CASCADE;
DROP TABLE IF EXISTS friendships CASCADE;
DROP TABLE IF EXISTS conversations CASCADE;
DROP TABLE IF EXISTS contacts CASCADE;
DROP TABLE IF EXISTS campus_spots CASCADE;
DROP TABLE IF EXISTS blocked_users CASCADE;
DROP TABLE IF EXISTS profiles CASCADE;
DROP TABLE IF EXISTS schools CASCADE;

-- Drop OLD v1 custom types/enums
DROP TYPE IF EXISTS friendship_status CASCADE;
DROP TYPE IF EXISTS moment_type CASCADE;
DROP TYPE IF EXISTS presence_status CASCADE;
DROP TYPE IF EXISTS room_visibility CASCADE;
DROP TYPE IF EXISTS report_status CASCADE;
DROP TYPE IF EXISTS notification_type CASCADE;

-- Drop NEW v2 tables (in case of re-run)
DROP TABLE IF EXISTS reactions CASCADE;
DROP TABLE IF EXISTS oracle_nodes CASCADE;
DROP TABLE IF EXISTS oracle_edges CASCADE;
DROP TABLE IF EXISTS room_members CASCADE;
DROP TABLE IF EXISTS rooms CASCADE;
DROP TABLE IF EXISTS sparks CASCADE;
DROP TABLE IF EXISTS overlap_scores CASCADE;
DROP TABLE IF EXISTS copresence_events CASCADE;
DROP TABLE IF EXISTS location_pings CASCADE;
DROP TABLE IF EXISTS connections CASCADE;
DROP TABLE IF EXISTS place_logs CASCADE;
DROP TABLE IF EXISTS drop_finds CASCADE;
DROP TABLE IF EXISTS drops CASCADE;
DROP TABLE IF EXISTS moments CASCADE;
DROP TABLE IF EXISTS places CASCADE;
DROP TABLE IF EXISTS users CASCADE;

-- ============================================
-- SCHOOLS
-- ============================================
CREATE TABLE schools (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  email_domain TEXT,
  lat_center FLOAT NOT NULL,
  lng_center FLOAT NOT NULL,
  lat_min FLOAT,
  lat_max FLOAT,
  lng_min FLOAT,
  lng_max FLOAT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Seed Rutgers
INSERT INTO schools (name, email_domain, lat_center, lng_center, lat_min, lat_max, lng_min, lng_max)
VALUES ('Rutgers University', 'rutgers.edu', 40.5008, -74.4474, 40.48, 40.52, -74.47, -74.42);

-- ============================================
-- USERS (extends Supabase Auth — phone auth)
-- ============================================
CREATE TABLE users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  handle TEXT NOT NULL UNIQUE,
  display_name TEXT NOT NULL,
  phone TEXT,
  avatar_url TEXT,
  bio TEXT,
  grad_year INT,
  interests TEXT[],
  ghost_mode_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_users_school ON users(school_id);
CREATE INDEX idx_users_handle ON users(handle);

-- ============================================
-- PLACES (campus locations)
-- ============================================
CREATE TABLE places (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID NOT NULL REFERENCES schools(id),
  name TEXT NOT NULL,
  type TEXT NOT NULL CHECK (type IN ('library', 'dining', 'gym', 'outdoor', 'building', 'dorm')),
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  address TEXT,
  hours JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_places_school ON places(school_id);

-- Seed Rutgers places
INSERT INTO places (school_id, name, type, latitude, longitude) VALUES
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Alexander Library', 'library', 40.4986, -74.4451),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Brower Commons', 'dining', 40.5234, -74.4369),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Werblin Recreation Center', 'gym', 40.5235, -74.4368),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Voorhees Mall', 'outdoor', 40.4989, -74.4468),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Scott Hall', 'building', 40.4998, -74.4472),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Busch Student Center', 'building', 40.5230, -74.4580),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'Livingston Student Center', 'building', 40.5236, -74.4367),
  ((SELECT id FROM schools WHERE name = 'Rutgers University'), 'College Ave Student Center', 'building', 40.5020, -74.4512);

-- ============================================
-- MOMENTS (posts — every post has a place)
-- ============================================
CREATE TABLE moments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  place_id UUID NOT NULL REFERENCES places(id),
  content_type TEXT NOT NULL CHECK (content_type IN ('photo', 'video', 'text', 'song', 'voice')),
  content_url TEXT,
  text_content TEXT,
  song_title TEXT,
  song_artist TEXT,
  song_art_url TEXT,
  is_drop BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_moments_school ON moments(school_id);
CREATE INDEX idx_moments_place ON moments(place_id);
CREATE INDEX idx_moments_user ON moments(user_id);
CREATE INDEX idx_moments_created ON moments(created_at DESC);

-- ============================================
-- DROPS (geolocked content)
-- ============================================
CREATE TABLE drops (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  moment_id UUID NOT NULL REFERENCES moments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  place_id UUID NOT NULL REFERENCES places(id),
  latitude FLOAT NOT NULL,
  longitude FLOAT NOT NULL,
  visibility TEXT NOT NULL CHECK (visibility IN ('public', 'connections', 'specific')),
  specific_user_ids UUID[],
  hint TEXT,
  expires_at TIMESTAMPTZ,
  room_id UUID,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_drops_place ON drops(place_id);
CREATE INDEX idx_drops_school ON drops(school_id);
CREATE INDEX idx_drops_expires ON drops(expires_at);
CREATE INDEX idx_drops_user ON drops(user_id);

-- ============================================
-- DROP FINDS
-- ============================================
CREATE TABLE drop_finds (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  drop_id UUID NOT NULL REFERENCES drops(id) ON DELETE CASCADE,
  finder_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  found_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(drop_id, finder_id)
);

-- ============================================
-- PLACE LOGS
-- ============================================
CREATE TABLE place_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  place_id UUID NOT NULL REFERENCES places(id),
  rating FLOAT NOT NULL CHECK (rating >= 1.0 AND rating <= 5.0),
  mood TEXT NOT NULL CHECK (mood IN ('buzzing', 'chill', 'productive', 'party', 'reflective', 'good_vibes')),
  note TEXT,
  logged_at DATE NOT NULL DEFAULT CURRENT_DATE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, place_id, logged_at)
);

CREATE INDEX idx_place_logs_place ON place_logs(place_id);
CREATE INDEX idx_place_logs_user ON place_logs(user_id);

-- ============================================
-- CONNECTIONS (mutual — canonical ordering)
-- ============================================
CREATE TABLE connections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  connected_at TIMESTAMPTZ DEFAULT NOW(),
  spark_id UUID,
  UNIQUE(user_a, user_b),
  CHECK (user_a < user_b)
);

CREATE INDEX idx_connections_school ON connections(school_id);

-- ============================================
-- LOCATION PINGS (place_id only — NEVER lat/lng)
-- ============================================
CREATE TABLE location_pings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  place_id UUID NOT NULL REFERENCES places(id),
  pinged_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_pings_user_place ON location_pings(user_id, place_id, pinged_at);

-- ============================================
-- CO-PRESENCE EVENTS
-- ============================================
CREATE TABLE copresence_events (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  place_id UUID NOT NULL REFERENCES places(id),
  school_id UUID NOT NULL REFERENCES schools(id),
  occurred_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (user_a < user_b)
);

CREATE INDEX idx_copresence_users ON copresence_events(user_a, user_b);
CREATE INDEX idx_copresence_school ON copresence_events(school_id);

-- ============================================
-- OVERLAP SCORES
-- ============================================
CREATE TABLE overlap_scores (
  user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  score FLOAT NOT NULL DEFAULT 0,
  last_computed_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_a, user_b),
  CHECK (user_a < user_b)
);

-- ============================================
-- SPARKS
-- ============================================
CREATE TABLE sparks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  overlap_score FLOAT NOT NULL,
  overlap_context JSONB NOT NULL DEFAULT '{}',
  dismissed_by_a_at TIMESTAMPTZ,
  dismissed_by_b_at TIMESTAMPTZ,
  perm_dismissed_by_a BOOLEAN DEFAULT FALSE,
  perm_dismissed_by_b BOOLEAN DEFAULT FALSE,
  converted_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (user_a < user_b)
);

CREATE INDEX idx_sparks_school ON sparks(school_id);

ALTER TABLE connections ADD CONSTRAINT fk_connections_spark FOREIGN KEY (spark_id) REFERENCES sparks(id);

-- ============================================
-- ROOMS
-- ============================================
CREATE TABLE rooms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID NOT NULL REFERENCES schools(id),
  home_place_id UUID NOT NULL REFERENCES places(id),
  name TEXT NOT NULL,
  description TEXT,
  visibility TEXT NOT NULL CHECK (visibility IN ('public', 'invite_only')),
  tags TEXT[],
  created_by UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_rooms_school ON rooms(school_id);
CREATE INDEX idx_rooms_place ON rooms(home_place_id);

ALTER TABLE drops ADD CONSTRAINT fk_drops_room FOREIGN KEY (room_id) REFERENCES rooms(id);

-- ============================================
-- ROOM MEMBERS
-- ============================================
CREATE TABLE room_members (
  room_id UUID NOT NULL REFERENCES rooms(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  role TEXT NOT NULL DEFAULT 'member' CHECK (role IN ('admin', 'member')),
  joined_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (room_id, user_id)
);

-- ============================================
-- CONVERSATIONS (DMs)
-- ============================================
CREATE TABLE conversations (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_a UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_b UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  spark_context JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CHECK (user_a < user_b)
);

CREATE INDEX idx_conversations_users ON conversations(user_a, user_b);

-- ============================================
-- MESSAGES (DM + Room)
-- ============================================
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  conversation_id UUID NOT NULL,
  sender_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  content TEXT NOT NULL,
  content_type TEXT DEFAULT 'text' CHECK (content_type IN ('text', 'moment_card', 'place_card')),
  referenced_id UUID,
  disappears_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation ON messages(conversation_id, created_at DESC);
CREATE INDEX idx_messages_sender ON messages(sender_id);

-- ============================================
-- ORACLE GRAPH
-- ============================================
CREATE TABLE oracle_edges (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_from UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  user_to UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  interaction_type TEXT NOT NULL CHECK (interaction_type IN ('view_profile', 'like', 'comment', 'dm', 'connect', 'overlap', 'room')),
  weight FLOAT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX idx_oracle_user_from ON oracle_edges(user_from, created_at DESC);
CREATE INDEX idx_oracle_user_to ON oracle_edges(user_to, created_at DESC);

CREATE TABLE oracle_nodes (
  user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
  school_id UUID NOT NULL REFERENCES schools(id),
  total_outgoing_weight FLOAT DEFAULT 0,
  top_connections JSONB,
  last_computed_at TIMESTAMPTZ DEFAULT NOW()
);

-- ============================================
-- REACTIONS
-- ============================================
CREATE TABLE reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  moment_id UUID NOT NULL REFERENCES moments(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  emoji TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(moment_id, user_id, emoji)
);

-- ============================================
-- STORAGE BUCKETS (ignore if they already exist)
-- ============================================
INSERT INTO storage.buckets (id, name, public)
VALUES ('moments-media', 'moments-media', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('user-avatars', 'user-avatars', false)
ON CONFLICT (id) DO NOTHING;

INSERT INTO storage.buckets (id, name, public)
VALUES ('place-photos', 'place-photos', false)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- ROW LEVEL SECURITY
-- ============================================
ALTER TABLE schools ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE places ENABLE ROW LEVEL SECURITY;
ALTER TABLE moments ENABLE ROW LEVEL SECURITY;
ALTER TABLE drops ENABLE ROW LEVEL SECURITY;
ALTER TABLE drop_finds ENABLE ROW LEVEL SECURITY;
ALTER TABLE place_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE connections ENABLE ROW LEVEL SECURITY;
ALTER TABLE location_pings ENABLE ROW LEVEL SECURITY;
ALTER TABLE copresence_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE overlap_scores ENABLE ROW LEVEL SECURITY;
ALTER TABLE sparks ENABLE ROW LEVEL SECURITY;
ALTER TABLE rooms ENABLE ROW LEVEL SECURITY;
ALTER TABLE room_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
ALTER TABLE oracle_edges ENABLE ROW LEVEL SECURITY;
ALTER TABLE oracle_nodes ENABLE ROW LEVEL SECURITY;
ALTER TABLE reactions ENABLE ROW LEVEL SECURITY;

-- Schools: anyone can read
CREATE POLICY "schools_read" ON schools FOR SELECT USING (true);

-- Users: read own school, write own
CREATE POLICY "users_read_school" ON users FOR SELECT
  USING (school_id = (SELECT school_id FROM users WHERE id = auth.uid()));
CREATE POLICY "users_insert_own" ON users FOR INSERT
  WITH CHECK (id = auth.uid());
CREATE POLICY "users_update_own" ON users FOR UPDATE
  USING (id = auth.uid());

-- Places: read own school
CREATE POLICY "places_read_school" ON places FOR SELECT
  USING (school_id = (SELECT school_id FROM users WHERE id = auth.uid()));

-- Moments
CREATE POLICY "moments_read_school" ON moments FOR SELECT
  USING (school_id = (SELECT school_id FROM users WHERE id = auth.uid()));
CREATE POLICY "moments_insert_own" ON moments FOR INSERT
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "moments_delete_own" ON moments FOR DELETE
  USING (user_id = auth.uid());

-- Drops: complex visibility
CREATE POLICY "drops_read" ON drops FOR SELECT
  USING (
    school_id = (SELECT school_id FROM users WHERE id = auth.uid())
    AND (
      user_id = auth.uid()
      OR visibility = 'public'
      OR (visibility = 'connections' AND EXISTS (
        SELECT 1 FROM connections
        WHERE (user_a = LEAST(auth.uid(), drops.user_id) AND user_b = GREATEST(auth.uid(), drops.user_id))
      ))
      OR (visibility = 'specific' AND auth.uid() = ANY(specific_user_ids))
    )
    AND (expires_at IS NULL OR expires_at > NOW())
  );
CREATE POLICY "drops_insert_own" ON drops FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Drop finds
CREATE POLICY "drop_finds_read" ON drop_finds FOR SELECT
  USING (finder_id = auth.uid() OR drop_id IN (SELECT id FROM drops WHERE user_id = auth.uid()));
CREATE POLICY "drop_finds_insert" ON drop_finds FOR INSERT
  WITH CHECK (finder_id = auth.uid());

-- Place logs
CREATE POLICY "place_logs_read_school" ON place_logs FOR SELECT
  USING (school_id = (SELECT school_id FROM users WHERE id = auth.uid()));
CREATE POLICY "place_logs_insert_own" ON place_logs FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Connections
CREATE POLICY "connections_read" ON connections FOR SELECT
  USING (user_a = auth.uid() OR user_b = auth.uid());
CREATE POLICY "connections_insert" ON connections FOR INSERT
  WITH CHECK (user_a = auth.uid() OR user_b = auth.uid());
CREATE POLICY "connections_delete" ON connections FOR DELETE
  USING (user_a = auth.uid() OR user_b = auth.uid());

-- Location pings: own only
CREATE POLICY "pings_read_own" ON location_pings FOR SELECT
  USING (user_id = auth.uid());
CREATE POLICY "pings_insert_own" ON location_pings FOR INSERT
  WITH CHECK (user_id = auth.uid());

-- Copresence events
CREATE POLICY "copresence_read" ON copresence_events FOR SELECT
  USING (user_a = auth.uid() OR user_b = auth.uid());

-- Overlap scores
CREATE POLICY "overlap_read" ON overlap_scores FOR SELECT
  USING (user_a = auth.uid() OR user_b = auth.uid());

-- Sparks
CREATE POLICY "sparks_read" ON sparks FOR SELECT
  USING (user_a = auth.uid() OR user_b = auth.uid());
CREATE POLICY "sparks_update" ON sparks FOR UPDATE
  USING (user_a = auth.uid() OR user_b = auth.uid());

-- Rooms
CREATE POLICY "rooms_read_school" ON rooms FOR SELECT
  USING (school_id = (SELECT school_id FROM users WHERE id = auth.uid()));
CREATE POLICY "rooms_insert" ON rooms FOR INSERT
  WITH CHECK (created_by = auth.uid());

-- Room members
CREATE POLICY "room_members_read" ON room_members FOR SELECT
  USING (
    user_id = auth.uid()
    OR room_id IN (SELECT id FROM rooms WHERE visibility = 'public')
    OR room_id IN (SELECT room_id FROM room_members WHERE user_id = auth.uid())
  );
CREATE POLICY "room_members_insert" ON room_members FOR INSERT
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "room_members_delete" ON room_members FOR DELETE
  USING (user_id = auth.uid());

-- Conversations
CREATE POLICY "conversations_read" ON conversations FOR SELECT
  USING (user_a = auth.uid() OR user_b = auth.uid());
CREATE POLICY "conversations_insert" ON conversations FOR INSERT
  WITH CHECK (user_a = auth.uid() OR user_b = auth.uid());

-- Messages
CREATE POLICY "messages_read" ON messages FOR SELECT
  USING (
    conversation_id IN (
      SELECT id FROM conversations WHERE user_a = auth.uid() OR user_b = auth.uid()
      UNION
      SELECT room_id FROM room_members WHERE user_id = auth.uid()
    )
  );
CREATE POLICY "messages_insert" ON messages FOR INSERT
  WITH CHECK (sender_id = auth.uid());

-- Oracle
CREATE POLICY "oracle_edges_read" ON oracle_edges FOR SELECT
  USING (user_from = auth.uid() OR user_to = auth.uid());
CREATE POLICY "oracle_nodes_read" ON oracle_nodes FOR SELECT
  USING (user_id = auth.uid());

-- Reactions
CREATE POLICY "reactions_read" ON reactions FOR SELECT
  USING (moment_id IN (SELECT id FROM moments WHERE school_id = (SELECT school_id FROM users WHERE id = auth.uid())));
CREATE POLICY "reactions_insert" ON reactions FOR INSERT
  WITH CHECK (user_id = auth.uid());
CREATE POLICY "reactions_delete" ON reactions FOR DELETE
  USING (user_id = auth.uid());

-- Storage policies (drop and recreate to avoid conflicts)
DROP POLICY IF EXISTS "avatar_read" ON storage.objects;
DROP POLICY IF EXISTS "avatar_upload" ON storage.objects;
DROP POLICY IF EXISTS "media_read" ON storage.objects;
DROP POLICY IF EXISTS "media_upload" ON storage.objects;

CREATE POLICY "avatar_read" ON storage.objects FOR SELECT
  USING (bucket_id = 'user-avatars');
CREATE POLICY "avatar_upload" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'user-avatars' AND (storage.foldername(name))[1] = auth.uid()::text);
CREATE POLICY "media_read" ON storage.objects FOR SELECT
  USING (bucket_id = 'moments-media');
CREATE POLICY "media_upload" ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'moments-media');

-- ============================================
-- REALTIME
-- ============================================
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE location_pings;
