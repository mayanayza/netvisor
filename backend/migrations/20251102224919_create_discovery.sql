ALTER TABLE daemons ADD COLUMN capabilities JSONB DEFAULT '{}';

CREATE TABLE IF NOT EXISTS discovery (
    id UUID PRIMARY KEY,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    daemon_id UUID NOT NULL REFERENCES daemons(id) ON DELETE CASCADE,
    run_type JSONB NOT NULL,
    discovery_type JSONB NOT NULL,
    name TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_discovery_daemon ON discovery(daemon_id);
CREATE INDEX IF NOT EXISTS idx_discovery_network ON discovery(network_id);

-- Migration to update DiscoveryType format in all tables
DO $$
DECLARE
    table_name TEXT;
    affected_tables TEXT[] := ARRAY['services', 'hosts', 'subnets', 'groups'];
    rows_updated INT;
    total_updated INT := 0;
BEGIN
    FOREACH table_name IN ARRAY affected_tables
    LOOP
        RAISE NOTICE 'Updating table: %', table_name;
        
        EXECUTE format('
            UPDATE %I 
            SET source = jsonb_set(
                source,
                ''{metadata}'',
                (
                    SELECT jsonb_agg(
                        CASE 
                            WHEN elem->>''discovery_type'' = ''SelfReport'' THEN 
                                jsonb_build_object(
                                    ''type'', ''SelfReport'',
                                    ''host_id'', COALESCE(elem->>''host_id'', ''00000000-0000-0000-0000-000000000000''),
                                    ''daemon_id'', elem->>''daemon_id'',
                                    ''date'', elem->>''date''
                                )
                            WHEN elem->>''discovery_type'' = ''Network'' THEN 
                                jsonb_build_object(
                                    ''type'', ''Network'',
                                    ''subnet_ids'', NULL,
                                    ''daemon_id'', elem->>''daemon_id'',
                                    ''date'', elem->>''date''
                                )
                            WHEN elem->>''discovery_type'' = ''Docker'' THEN 
                                jsonb_build_object(
                                    ''type'', ''Docker'',
                                    ''host_id'', elem->>''host_id'',
                                    ''daemon_id'', elem->>''daemon_id'',
                                    ''date'', elem->>''date''
                                )
                            WHEN elem->>''type'' IS NOT NULL THEN
                                elem  -- Already in new format
                            ELSE elem
                        END
                    )
                    FROM jsonb_array_elements(source->''metadata'') AS elem
                )
            )
            WHERE source->''metadata'' IS NOT NULL
            AND EXISTS (
                SELECT 1 
                FROM jsonb_array_elements(source->''metadata'') AS elem
                WHERE elem->>''discovery_type'' IS NOT NULL
            )',
            table_name
        );
        
        GET DIAGNOSTICS rows_updated = ROW_COUNT;
        total_updated := total_updated + rows_updated;
        RAISE NOTICE 'Updated % rows in table %', rows_updated, table_name;
    END LOOP;
    
    RAISE NOTICE 'Migration complete. Total rows updated: %', total_updated;
END $$;