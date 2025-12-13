CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Convert plaintext keys to SHA-256 hashes
UPDATE api_keys 
SET key = encode(digest(key, 'sha256'), 'hex');