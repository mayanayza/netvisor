CREATE TABLE api_keys (
    id UUID PRIMARY KEY,
    key TEXT NOT NULL UNIQUE,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    last_used TIMESTAMPTZ,
    expires_at TIMESTAMPTZ,
    is_enabled BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE INDEX idx_api_keys_key ON api_keys(key);
CREATE INDEX idx_api_keys_network ON api_keys(network_id);

-- Migrate existing daemon api_keys to the new table
DO $$
DECLARE
    daemon_record RECORD;
BEGIN
    -- Loop through all daemons that have an api_key set
    FOR daemon_record IN 
        SELECT id, network_id, api_key, created_at, last_seen
        FROM daemons 
        WHERE api_key IS NOT NULL
    LOOP
        -- Insert into api_keys table
        INSERT INTO api_keys (
            id,
            key,
            network_id,
            name,
            created_at,
            updated_at,
            last_used,
            is_enabled
        ) VALUES (
            gen_random_uuid(),
            daemon_record.api_key,
            daemon_record.network_id,
            'Api Key',
            daemon_record.created_at,
            daemon_record.created_at,
            daemon_record.last_seen,
            true
        );

        RAISE NOTICE 'Migrated daemon % api_key to api_keys table', daemon_record.id;
    END LOOP;
END $$;

-- Drop the old api_key column and its index
DROP INDEX IF EXISTS idx_daemons_api_key_hash;
ALTER TABLE daemons DROP COLUMN IF EXISTS api_key;