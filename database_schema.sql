-- Supabase Database Schema for User Location Feature
-- This script creates the necessary tables and indexes for the user location functionality

-- Create user_locations table
CREATE TABLE IF NOT EXISTS user_locations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    latitude DOUBLE PRECISION NOT NULL,
    longitude DOUBLE PRECISION NOT NULL,
    accuracy DOUBLE PRECISION,
    country TEXT,
    administrative_area TEXT, -- State/Province
    locality TEXT, -- City
    sub_locality TEXT, -- District/Neighborhood
    thoroughfare TEXT, -- Street name
    sub_thoroughfare TEXT, -- Street number
    postal_code TEXT,
    iso_country_code TEXT,
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_current_location BOOLEAN DEFAULT FALSE,
    location_name TEXT, -- Custom name for the location
    privacy_level TEXT NOT NULL DEFAULT 'city' CHECK (privacy_level IN ('exact', 'street', 'city', 'region', 'country', 'hidden')),
    source TEXT NOT NULL DEFAULT 'gps' CHECK (source IN ('gps', 'network', 'manual', 'imported')),
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Add PostGIS extension for geographic queries (if not already enabled)
CREATE EXTENSION IF NOT EXISTS postgis;

-- Add geography column for efficient spatial queries
ALTER TABLE user_locations ADD COLUMN IF NOT EXISTS location_point GEOGRAPHY(POINT, 4326);

-- Create function to update location_point from latitude/longitude
CREATE OR REPLACE FUNCTION update_location_point()
RETURNS TRIGGER AS $$
BEGIN
    NEW.location_point = ST_SetSRID(ST_MakePoint(NEW.longitude, NEW.latitude), 4326)::geography;
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create trigger to automatically update location_point
DROP TRIGGER IF EXISTS trigger_update_location_point ON user_locations;
CREATE TRIGGER trigger_update_location_point
    BEFORE INSERT OR UPDATE ON user_locations
    FOR EACH ROW
    EXECUTE FUNCTION update_location_point();

-- Update existing users table to include location fields
ALTER TABLE users ADD COLUMN IF NOT EXISTS location_updated_at TIMESTAMPTZ;
ALTER TABLE users ADD COLUMN IF NOT EXISTS location_privacy_level TEXT DEFAULT 'city' CHECK (location_privacy_level IN ('exact', 'street', 'city', 'region', 'country', 'hidden'));

-- Create indexes for performance
CREATE INDEX IF NOT EXISTS idx_user_locations_user_id ON user_locations(user_id);
CREATE INDEX IF NOT EXISTS idx_user_locations_timestamp ON user_locations(timestamp DESC);
CREATE INDEX IF NOT EXISTS idx_user_locations_current ON user_locations(user_id, is_current_location) WHERE is_current_location = true;
CREATE INDEX IF NOT EXISTS idx_user_locations_privacy ON user_locations(privacy_level);
CREATE INDEX IF NOT EXISTS idx_user_locations_location ON user_locations(locality, country);

-- Create spatial index for geographic queries
CREATE INDEX IF NOT EXISTS idx_user_locations_geography ON user_locations USING GIST(location_point);

-- Create composite index for common queries
CREATE INDEX IF NOT EXISTS idx_user_locations_composite ON user_locations(user_id, timestamp DESC, is_current_location);

-- Create view for users with location data (for easier querying)
CREATE OR REPLACE VIEW users_with_location AS
SELECT
    u.*,
    ul.latitude,
    ul.longitude,
    ul.country as location_country,
    ul.locality as location_city,
    ul.privacy_level as location_privacy,
    ul.timestamp as location_timestamp,
    ul.location_point
FROM users u
LEFT JOIN user_locations ul ON u.id = ul.user_id AND ul.is_current_location = true;

-- Row Level Security (RLS) policies
ALTER TABLE user_locations ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own location data
CREATE POLICY "Users can view own locations" ON user_locations
    FOR SELECT USING (auth.uid() = user_id);

-- Policy: Users can only insert their own location data
CREATE POLICY "Users can insert own locations" ON user_locations
    FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Policy: Users can only update their own location data
CREATE POLICY "Users can update own locations" ON user_locations
    FOR UPDATE USING (auth.uid() = user_id);

-- Policy: Users can only delete their own location data
CREATE POLICY "Users can delete own locations" ON user_locations
    FOR DELETE USING (auth.uid() = user_id);

-- Policy: Allow users to see other users' locations based on privacy settings
CREATE POLICY "Users can view others' public locations" ON user_locations
    FOR SELECT USING (
        auth.uid() != user_id AND
        privacy_level != 'hidden' AND
        is_current_location = true
    );

-- Function to get users within radius (using PostGIS)
CREATE OR REPLACE FUNCTION get_users_within_radius(
    center_lat DOUBLE PRECISION,
    center_lng DOUBLE PRECISION,
    radius_km DOUBLE PRECISION,
    exclude_user_id UUID DEFAULT NULL,
    min_privacy_level TEXT DEFAULT 'city'
)
RETURNS TABLE (
    user_id UUID,
    latitude DOUBLE PRECISION,
    longitude DOUBLE PRECISION,
    distance_km DOUBLE PRECISION,
    privacy_level TEXT,
    locality TEXT,
    country TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        ul.user_id,
        ul.latitude,
        ul.longitude,
        ST_Distance(
            ul.location_point,
            ST_SetSRID(ST_MakePoint(center_lng, center_lat), 4326)::geography
        ) / 1000 as distance_km,
        ul.privacy_level,
        ul.locality,
        ul.country
    FROM user_locations ul
    WHERE
        ul.is_current_location = true
        AND (exclude_user_id IS NULL OR ul.user_id != exclude_user_id)
        AND ul.privacy_level != 'hidden'
        AND ST_DWithin(
            ul.location_point,
            ST_SetSRID(ST_MakePoint(center_lng, center_lat), 4326)::geography,
            radius_km * 1000
        )
        AND CASE min_privacy_level
            WHEN 'exact' THEN ul.privacy_level IN ('exact', 'street', 'city', 'region', 'country')
            WHEN 'street' THEN ul.privacy_level IN ('street', 'city', 'region', 'country')
            WHEN 'city' THEN ul.privacy_level IN ('city', 'region', 'country')
            WHEN 'region' THEN ul.privacy_level IN ('region', 'country')
            WHEN 'country' THEN ul.privacy_level IN ('country')
            ELSE true
        END
    ORDER BY distance_km;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Function to clean up old location data (for privacy and storage management)
CREATE OR REPLACE FUNCTION cleanup_old_locations()
RETURNS INTEGER AS $$
DECLARE
    deleted_count INTEGER;
BEGIN
    -- Delete location history older than 1 year, keeping current locations
    DELETE FROM user_locations
    WHERE
        is_current_location = false
        AND timestamp < NOW() - INTERVAL '1 year';

    GET DIAGNOSTICS deleted_count = ROW_COUNT;
    RETURN deleted_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Create a scheduled job to run cleanup (requires pg_cron extension)
-- This is optional and should be configured based on your Supabase setup
-- SELECT cron.schedule('cleanup-old-locations', '0 2 * * 0', 'SELECT cleanup_old_locations();');

-- Grant necessary permissions
GRANT SELECT, INSERT, UPDATE, DELETE ON user_locations TO authenticated;
GRANT SELECT ON users_with_location TO authenticated;
GRANT EXECUTE ON FUNCTION get_users_within_radius TO authenticated;

-- Create sample data for testing (optional - remove in production)
-- INSERT INTO user_locations (user_id, latitude, longitude, locality, country, privacy_level, is_current_location)
-- VALUES
--     ('00000000-0000-0000-0000-000000000001', 37.7749, -122.4194, 'San Francisco', 'United States', 'city', true),
--     ('00000000-0000-0000-0000-000000000002', 34.0522, -118.2437, 'Los Angeles', 'United States', 'city', true),
--     ('00000000-0000-0000-0000-000000000003', 40.7128, -74.0060, 'New York', 'United States', 'street', true);

-- Comments for documentation
COMMENT ON TABLE user_locations IS 'Stores user location data with privacy controls';
COMMENT ON COLUMN user_locations.privacy_level IS 'Controls how much location information is shared: exact, street, city, region, country, hidden';
COMMENT ON COLUMN user_locations.source IS 'Source of location data: gps, network, manual, imported';
COMMENT ON COLUMN user_locations.location_point IS 'PostGIS geography point for efficient spatial queries';
COMMENT ON FUNCTION get_users_within_radius IS 'Returns users within specified radius with privacy filtering';
COMMENT ON FUNCTION cleanup_old_locations IS 'Removes old location history data for privacy and storage management';
