ALTER TABLE daemons ADD COLUMN api_key TEXT DEFAULT null;
CREATE INDEX idx_daemons_api_key_hash ON daemons(api_key);