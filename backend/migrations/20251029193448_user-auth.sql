-- Add authentication support
-- This migration adds password_hash to users table and merges legacy users

-- Step 1: Add password_hash column (NULL = legacy user without password)
ALTER TABLE users ADD COLUMN IF NOT EXISTS password_hash TEXT;
ALTER TABLE users ADD COLUMN IF NOT EXISTS username TEXT;

-- Step 2: Merge multiple legacy users FIRST (before creating unique index)
-- This only affects existing users created before this migration
DO $$
DECLARE
    legacy_user_count INT;
    seed_user_id UUID;
    seed_user_name TEXT;
BEGIN
    -- Count users without passwords (legacy users)
    SELECT COUNT(*) INTO legacy_user_count 
    FROM users 
    WHERE password_hash IS NULL;
    
    -- Only merge if there are multiple legacy users
    IF legacy_user_count > 1 THEN
        RAISE NOTICE 'Found % legacy users without passwords. Merging into seed user...', legacy_user_count;
        
        -- Select the oldest user as the seed user
        SELECT id, name INTO seed_user_id, seed_user_name
        FROM users 
        WHERE password_hash IS NULL
        ORDER BY created_at ASC 
        LIMIT 1;
        
        RAISE NOTICE 'Seed user selected: % (name: %)', seed_user_id, seed_user_name;
        
        -- Update all networks to belong to seed user
        UPDATE networks 
        SET user_id = seed_user_id 
        WHERE user_id IN (
            SELECT id FROM users WHERE password_hash IS NULL AND id != seed_user_id
        );
        
        -- Log what we're about to delete
        RAISE NOTICE 'Transferring networks to seed user and deleting % other legacy users', legacy_user_count - 1;
        
        -- Delete other legacy users (CASCADE will handle related data)
        DELETE FROM users 
        WHERE password_hash IS NULL 
        AND id != seed_user_id;
        
        -- Update seed user name to indicate migration
        UPDATE users 
        SET name = COALESCE(NULLIF(seed_user_name, 'Name'), 'Name'),
            username = COALESCE(NULLIF(seed_user_name, 'default'), 'default'),
            updated_at = NOW()
        WHERE id = seed_user_id;
        
        RAISE NOTICE 'Migration complete. All data now belongs to seed user.';
    ELSIF legacy_user_count = 1 THEN
        RAISE NOTICE 'Found 1 legacy user. This is the seed user - no merge needed.';

        UPDATE users 
        SET username = COALESCE(NULLIF(name, 'default'), 'default'),
            updated_at = NOW()
        WHERE password_hash IS NULL;
    ELSE
        RAISE NOTICE 'No legacy users found. All users already have passwords.';
    END IF;

END $$;

-- Step 3: Create the unique index (after duplicates are merged)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_name_lower ON users(LOWER(name));