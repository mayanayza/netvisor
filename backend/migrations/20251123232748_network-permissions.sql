-- Add network-level permissions to users
-- This migration adds a network_ids column to track which networks a user can access

-- Step 1: Add network_ids column (UUID array)
ALTER TABLE users ADD COLUMN network_ids UUID[] DEFAULT '{}';

-- Step 2: Populate network_ids with all networks from user's organization
UPDATE users
SET network_ids = (
    SELECT ARRAY_AGG(n.id)
    FROM networks n
    WHERE n.organization_id = users.organization_id
);

-- Step 3: Handle users without networks (set to empty array)
UPDATE users
SET network_ids = '{}'
WHERE network_ids IS NULL;

-- Step 4: Make network_ids NOT NULL
ALTER TABLE users ALTER COLUMN network_ids SET NOT NULL;

-- Create index for array operations
CREATE INDEX idx_users_network_ids ON users USING GIN(network_ids);