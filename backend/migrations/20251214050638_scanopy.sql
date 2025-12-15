-- Migration: Rename NetVisor to Scanopy
-- Affects: services table and topology snapshots

-- 1. Update services table - name field (no quotes)
UPDATE services 
SET name = 'Scanopy Daemon'
WHERE name = 'NetVisor Daemon API';

UPDATE services 
SET name = 'Scanopy Server'
WHERE name = 'NetVisor Server API';

-- 2. Update services table - service_definition field (stored with quotes in TEXT column)
UPDATE services
SET service_definition = '"Scanopy Daemon"'
WHERE service_definition = '"NetVisor Daemon API"';

UPDATE services
SET service_definition = '"Scanopy Server"'
WHERE service_definition = '"NetVisor Server API"';

-- 3. Update topology snapshots - services JSONB array (no extra quotes)
UPDATE topologies
SET services = (
    SELECT jsonb_agg(
        CASE 
            WHEN svc->>'service_definition' = 'NetVisor Daemon API'
            THEN jsonb_set(
                jsonb_set(svc, '{name}', '"Scanopy Daemon"'),
                '{service_definition}', '"Scanopy Daemon"'
            )
            WHEN svc->>'service_definition' = 'NetVisor Server API'
            THEN jsonb_set(
                jsonb_set(svc, '{name}', '"Scanopy Server"'),
                '{service_definition}', '"Scanopy Server"'
            )
            ELSE svc
        END
    )
    FROM jsonb_array_elements(services) AS svc
)
WHERE services::text LIKE '%NetVisor Daemon API%'
   OR services::text LIKE '%NetVisor Server API%';