-- This migration is now a no-op
-- The column removals were moved to earlier migrations:
-- - services: dropped in 20251118225043_save-topology.sql
-- - interfaces: dropped in 20251221040000_interfaces_table.sql
-- - ports: dropped in 20251221050000_ports_table.sql
-- All child tables have ON DELETE CASCADE on host_id
SELECT 1;
