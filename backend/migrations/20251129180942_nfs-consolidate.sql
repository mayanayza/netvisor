-- Migration: Convert NasDevice service definitions to NFS
-- The NasDevice and NFSServer definitions are duplicates; consolidating to NFSServer

-- Step 1: Update services table
UPDATE services
SET service_definition = 'NFS'
WHERE service_definition = 'Nas Device';

-- Step 2: Update services embedded in topologies
UPDATE topologies
SET services = (
    SELECT jsonb_agg(
        CASE 
            WHEN service->>'service_definition' = 'Nas Device' THEN
                jsonb_set(service, '{service_definition}', '"NFS"')
            ELSE
                service
        END
    )
    FROM jsonb_array_elements(services) AS service
)
WHERE services @> '[{"service_definition": "Nas Device"}]';