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

-- Migrate existing usernames/names to email format with uniqueness handling
WITH numbered_users AS (
    SELECT 
        id,
        CASE 
            WHEN username IS NOT NULL AND username != '' AND username LIKE '%@%' THEN username
            WHEN username IS NOT NULL AND username != '' THEN 
                TRIM(BOTH '_' FROM REGEXP_REPLACE(username, '^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$', '', 'g')) || '@example.com'
            WHEN name IS NOT NULL AND name != '' AND name LIKE '%@%' THEN name
            WHEN name IS NOT NULL AND name != '' THEN 
                TRIM(BOTH '_' FROM REGEXP_REPLACE(name, '^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$', '', 'g')) || '@example.com'
            ELSE 'user@example.com'
        END as base_email,
        ROW_NUMBER() OVER (
            PARTITION BY 
                LOWER(CASE 
                    WHEN username IS NOT NULL AND username != '' AND username LIKE '%@%' THEN username
                    WHEN username IS NOT NULL AND username != '' THEN 
                        TRIM(BOTH '_' FROM REGEXP_REPLACE(username, '^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$', '', 'g')) || '@example.com'
                    WHEN name IS NOT NULL AND name != '' AND name LIKE '%@%' THEN name
                    WHEN name IS NOT NULL AND name != '' THEN 
                        TRIM(BOTH '_' FROM REGEXP_REPLACE(name, '^[^a-zA-Z0-9]+|[^a-zA-Z0-9]+$', '', 'g')) || '@example.com'
                    ELSE 'user@example.com'
                END)
            ORDER BY created_at
        ) as row_num
    FROM users
    WHERE email IS NULL
)
UPDATE users
SET email = CASE 
    WHEN numbered_users.row_num = 1 THEN numbered_users.base_email
    ELSE REGEXP_REPLACE(numbered_users.base_email, '@', numbered_users.row_num::text || '@')
END
FROM numbered_users
WHERE users.id = numbered_users.id;

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