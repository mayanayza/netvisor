-- backend/migrations/20251215000000_netvisor-to-scanopy-topology-options.sql

-- Migration: Replace 'Netvisor' service category with 'Scanopy' in saved topology options
-- Users who saved topology settings with 'Netvisor' in v0.11.x get deserialization errors
-- after upgrading to v0.12.0 where the enum variant was renamed to 'Scanopy'

UPDATE topologies
SET options = replace(options::text, 'Netvisor', 'Scanopy')::jsonb
WHERE options::text LIKE '%Netvisor%';