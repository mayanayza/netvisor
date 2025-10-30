ALTER TABLE daemons ADD COLUMN api_key_hash TEXT NOT NULL DEFAULT '';
CREATE INDEX idx_daemons_api_key_hash ON daemons(api_key_hash);