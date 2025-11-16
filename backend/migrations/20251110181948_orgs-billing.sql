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
ALTER TABLE users ADD COLUMN permissions TEXT NOT NULL DEFAULT 'Owner';

-- Step 3: Create an organization for each existing user
DO $$
DECLARE
    user_record RECORD;
    new_org_id UUID;
BEGIN
    CREATE TEMP TABLE user_org_mapping (
        user_id UUID,
        org_id UUID
    );

    FOR user_record IN SELECT id FROM users LOOP
        INSERT INTO organizations (name, created_at, updated_at)
        VALUES ('My Organization', NOW(), NOW())
        RETURNING id INTO new_org_id;

        INSERT INTO user_org_mapping (user_id, org_id)
        VALUES (user_record.id, new_org_id);
    END LOOP;

    UPDATE users u
    SET organization_id = m.org_id
    FROM user_org_mapping m
    WHERE u.id = m.user_id;

    DROP TABLE user_org_mapping;
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

-- Step 10: Add helpful comments
COMMENT ON TABLE organizations IS 'Organizations that own networks and have Stripe subscriptions';
COMMENT ON COLUMN users.organization_id IS 'The single organization this user belongs to';
COMMENT ON COLUMN users.permissions IS 'User role within their organization: owner, admin, member, viewer';
COMMENT ON COLUMN networks.organization_id IS 'The organization that owns and pays for this network';