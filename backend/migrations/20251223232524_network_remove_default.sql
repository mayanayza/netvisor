-- Add migration script here
ALTER TABLE networks DROP COLUMN IF EXISTS is_default;