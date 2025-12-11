-- Add migration script here
ALTER TABLE users ADD COLUMN terms_accepted_at TIMESTAMPTZ;