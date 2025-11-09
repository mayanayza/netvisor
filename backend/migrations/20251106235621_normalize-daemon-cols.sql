-- Rename registered_at to created_at and add updated_at column
-- Migration for daemons table timestamp standardization

-- Step 1: Rename registered_at to created_at
ALTER TABLE daemons RENAME COLUMN registered_at TO created_at;

-- Step 2: Add updated_at column, copying values from last_seen
ALTER TABLE daemons ADD COLUMN updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW();

-- Step 3: Populate updated_at with last_seen values for existing rows
UPDATE daemons SET updated_at = last_seen;