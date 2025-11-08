--- Add OIDC

-- Add OIDC provider linkage to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS oidc_provider TEXT,
ADD COLUMN IF NOT EXISTS oidc_subject TEXT,
ADD COLUMN IF NOT EXISTS oidc_linked_at TIMESTAMPTZ;

-- Create unique index on OIDC subject per provider
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_oidc_provider_subject 
ON users(oidc_provider, oidc_subject) 
WHERE oidc_provider IS NOT NULL AND oidc_subject IS NOT NULL;

--- Change from username to email

-- Add email column
ALTER TABLE users ADD COLUMN IF NOT EXISTS email TEXT;

-- Migrate existing usernames/names to email format
-- If it has @, assume it's already an email; otherwise append @example.com
UPDATE users 
SET email = CASE 
    WHEN username IS NOT NULL AND username != '' AND username LIKE '%@%' THEN username
    WHEN username IS NOT NULL AND username != '' THEN username || '@example.com'
    WHEN name IS NOT NULL AND name != '' AND name LIKE '%@%' THEN name
    WHEN name IS NOT NULL AND name != '' THEN name || '@example.com'
    ELSE 'user@example.com'
END
WHERE email IS NULL;

-- Make email NOT NULL after migration
ALTER TABLE users ALTER COLUMN email SET NOT NULL;

-- Create unique index on email (case-insensitive)
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_email_lower 
ON users(LOWER(email));

-- Drop the old username column (use DO block to check existence)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'users' AND column_name = 'username') THEN
        ALTER TABLE users DROP COLUMN username;
    END IF;
END $$;

-- Drop the old name column (use DO block to check existence)
DO $$ 
BEGIN
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'users' AND column_name = 'name') THEN
        ALTER TABLE users DROP COLUMN name;
    END IF;
END $$;

-- Drop the existing username unique index (if it exists)
DROP INDEX IF EXISTS idx_users_name_lower;