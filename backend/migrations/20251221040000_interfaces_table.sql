-- Phase 4: Create interfaces table as a separate entity

CREATE TABLE interfaces (
    id UUID PRIMARY KEY,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    host_id UUID NOT NULL REFERENCES hosts(id) ON DELETE CASCADE,
    subnet_id UUID NOT NULL REFERENCES subnets(id) ON DELETE CASCADE,
    ip_address INET NOT NULL,
    mac_address MACADDR,
    name TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(host_id, subnet_id, ip_address)
);

-- Migrate existing data from hosts.interfaces JSONB
-- Interface uses #[serde(flatten)] so the base fields are at the top level
-- network_id is derived from the host's network_id
INSERT INTO interfaces (id, network_id, host_id, subnet_id, ip_address, mac_address, name, created_at, updated_at)
SELECT
    (i->>'id')::UUID,
    h.network_id,
    h.id,
    (i->>'subnet_id')::UUID,
    (i->>'ip_address')::INET,
    (i->>'mac_address')::MACADDR,
    i->>'name',
    h.created_at,
    h.updated_at
FROM hosts h, jsonb_array_elements(h.interfaces) AS i
WHERE h.interfaces IS NOT NULL AND jsonb_array_length(h.interfaces) > 0;

CREATE INDEX idx_interfaces_network ON interfaces(network_id);
CREATE INDEX idx_interfaces_host ON interfaces(host_id);
CREATE INDEX idx_interfaces_subnet ON interfaces(subnet_id);

-- Drop embedded interfaces from hosts (now queried via interfaces.host_id)
ALTER TABLE hosts DROP COLUMN interfaces;

-- Add interfaces column to topology snapshots
ALTER TABLE topologies ADD COLUMN interfaces JSONB NOT NULL DEFAULT '[]';
ALTER TABLE topologies ADD COLUMN removed_interfaces UUID[] DEFAULT '{}';
