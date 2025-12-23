-- Phase 5: Create ports table (normalized storage, embedded in Host API)

CREATE TABLE ports (
    id UUID PRIMARY KEY,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    host_id UUID NOT NULL REFERENCES hosts(id) ON DELETE CASCADE,
    port_number INTEGER NOT NULL CHECK (port_number BETWEEN 0 AND 65535),
    protocol TEXT NOT NULL CHECK (protocol IN ('Tcp', 'Udp')),
    port_type TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(host_id, port_number, protocol)
);

-- Migrate existing data from hosts.ports JSONB
-- Port serializes as: { id, number, protocol, type }
-- network_id is derived from the host's network_id
INSERT INTO ports (id, network_id, host_id, port_number, protocol, port_type, created_at, updated_at)
SELECT
    (p->>'id')::UUID,
    h.network_id,
    h.id,
    (p->>'number')::INTEGER,
    p->>'protocol',
    p->>'type',
    h.created_at,
    h.updated_at
FROM hosts h, jsonb_array_elements(h.ports) AS p
WHERE h.ports IS NOT NULL AND jsonb_array_length(h.ports) > 0;

CREATE INDEX idx_ports_network ON ports(network_id);
CREATE INDEX idx_ports_host ON ports(host_id);
CREATE INDEX idx_ports_number ON ports(port_number);

-- Drop ports JSONB column from hosts
ALTER TABLE hosts DROP COLUMN ports;
