-- Migration: Rename NetVisor to Scanopy
-- Affects: services table and topology snapshots

-- 1. Update services table - name field
UPDATE services 
SET name = 'Scanopy Daemon'
WHERE name = 'NetVisor Daemon API';

UPDATE services 
SET name = 'Scanopy Server'
WHERE name = 'NetVisor Server API';

-- 2. Update services table - service_definition field (TEXT)
UPDATE services
SET service_definition = 'ScanopyDaemon'
WHERE service_definition = 'NetvisorDaemon';

UPDATE services
SET service_definition = 'ScanopyServer'
WHERE service_definition = 'NetvisorServer';

-- 3. Update topology snapshots - services JSONB array
UPDATE topologies
SET services = (
    SELECT jsonb_agg(
        CASE 
            WHEN svc->>'name' = 'NetVisor Daemon API' 
            THEN jsonb_set(
                jsonb_set(svc, '{name}', '"Scanopy Daemon"'),
                '{service_definition}', '"ScanopyDaemon"'
            )
            WHEN svc->>'name' = 'NetVisor Server API' 
            THEN jsonb_set(
                jsonb_set(svc, '{name}', '"Scanopy Server"'),
                '{service_definition}', '"ScanopyServer"'
            )
            ELSE svc
        END
    )
    FROM jsonb_array_elements(services) AS svc
)
WHERE services::text LIKE '%NetVisor Daemon API%'
   OR services::text LIKE '%NetVisor Server API%';