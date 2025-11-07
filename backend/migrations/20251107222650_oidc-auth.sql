-- Add OIDC provider linkage to users table
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS oidc_provider TEXT,
ADD COLUMN IF NOT EXISTS oidc_subject TEXT,
ADD COLUMN IF NOT EXISTS oidc_linked_at TIMESTAMPTZ;

-- Create unique index on OIDC subject per provider
CREATE UNIQUE INDEX IF NOT EXISTS idx_users_oidc_provider_subject 
ON users(oidc_provider, oidc_subject) 
WHERE oidc_provider IS NOT NULL AND oidc_subject IS NOT NULL;