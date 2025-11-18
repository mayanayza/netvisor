-- sqlx-transaction: false
-- Migration: Add organizations and migrate to organization-based ownership

-- Step 1: Create organizations table
CREATE TABLE organizations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    stripe_customer_id TEXT,
    plan JSONB,
    plan_status TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    is_onboarded BOOLEAN
);

CREATE INDEX idx_organizations_stripe_customer ON organizations(stripe_customer_id);

-- Step 2: Add organization_id and permissions to users table
ALTER TABLE users ADD COLUMN organization_id UUID;
ALTER TABLE users ADD COLUMN permissions TEXT NOT NULL DEFAULT 'Member';

-- Step 3: Create a single organization and assign users
DO $$
DECLARE
    new_org_id UUID;
    oldest_user_id UUID;
BEGIN
    -- Check if there are any users
    IF EXISTS (SELECT 1 FROM users LIMIT 1) THEN
        -- Create a single organization
        INSERT INTO organizations (name, created_at, updated_at, is_onboarded)
        VALUES ('My Organization', NOW(), NOW() true)
        RETURNING id INTO new_org_id;

        -- Find the oldest user (by created_at)
        SELECT id INTO oldest_user_id
        FROM users
        ORDER BY created_at ASC
        LIMIT 1;

        -- Update all users to belong to this organization
        UPDATE users
        SET organization_id = new_org_id;

        -- Set the oldest user as Owner
        UPDATE users
        SET permissions = 'Owner'
        WHERE id = oldest_user_id;

        -- All other users default to Member (already set by column default)
        
        RAISE NOTICE 'Created organization % with oldest user % as Owner', new_org_id, oldest_user_id;
    END IF;
END $$;

-- Step 4: Make organization_id NOT NULL and add foreign key
ALTER TABLE users ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE users ADD CONSTRAINT users_organization_id_fkey 
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

CREATE INDEX idx_users_organization ON users(organization_id);

-- Step 5: Add organization_id to networks table
ALTER TABLE networks ADD COLUMN organization_id UUID;

-- Step 6: Migrate networks to be owned by user's organization
UPDATE networks n
SET organization_id = u.organization_id
FROM users u
WHERE n.user_id = u.id;

-- Step 7: Make organization_id NOT NULL and add foreign key
ALTER TABLE networks ALTER COLUMN organization_id SET NOT NULL;
ALTER TABLE networks ADD CONSTRAINT organization_id_fkey
    FOREIGN KEY (organization_id) REFERENCES organizations(id) ON DELETE CASCADE;

CREATE INDEX idx_networks_owner_organization ON networks(organization_id);

-- Step 8: Drop the old user_id column from networks
ALTER TABLE networks DROP CONSTRAINT networks_user_id_fkey;
ALTER TABLE networks DROP COLUMN user_id;

-- Step 9: Add helpful comments
COMMENT ON TABLE organizations IS 'Organizations that own networks and have Stripe subscriptions';
COMMENT ON COLUMN users.organization_id IS 'The single organization this user belongs to';
COMMENT ON COLUMN users.permissions IS 'User role within their organization: Owner, Member, Viewer';
COMMENT ON COLUMN networks.organization_id IS 'The organization that owns and pays for this network';