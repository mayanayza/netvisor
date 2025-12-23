-- Phase 2: Remove host target feature
-- The target field is being dropped entirely as it was a premature feature

ALTER TABLE hosts DROP COLUMN target;
