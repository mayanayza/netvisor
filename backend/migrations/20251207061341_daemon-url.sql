-- Add url column to daemons table
ALTER TABLE daemons ADD COLUMN url TEXT;
ALTER TABLE daemons ADD COLUMN name TEXT;

-- Populate url from existing ip and port
UPDATE daemons SET url = 'http://' || ip || ':' || port;

-- Set name to same value as url
UPDATE daemons SET name = url;

-- Make url NOT NULL after populating
ALTER TABLE daemons ALTER COLUMN url SET NOT NULL;

-- Drop ip and port columns
ALTER TABLE daemons DROP COLUMN ip;
ALTER TABLE daemons DROP COLUMN port;