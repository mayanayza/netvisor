-- Phase 3: Replace users.network_ids UUID[] with junction table

CREATE TABLE user_network_access (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(user_id, network_id)
);

-- Migrate existing data from network_ids array
INSERT INTO user_network_access (user_id, network_id)
SELECT u.id, unnest(u.network_ids)
FROM users u
WHERE array_length(u.network_ids, 1) > 0;

CREATE INDEX idx_user_network_access_user ON user_network_access(user_id);
CREATE INDEX idx_user_network_access_network ON user_network_access(network_id);

ALTER TABLE users DROP COLUMN network_ids;
