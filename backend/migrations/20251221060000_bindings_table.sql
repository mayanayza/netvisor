-- Phase 6: Create bindings table (normalized storage, embedded in Service API)

CREATE TABLE bindings (
    id UUID PRIMARY KEY,
    network_id UUID NOT NULL REFERENCES networks(id) ON DELETE CASCADE,
    service_id UUID NOT NULL REFERENCES services(id) ON DELETE CASCADE,
    binding_type TEXT NOT NULL CHECK (binding_type IN ('Interface', 'Port')),
    interface_id UUID REFERENCES interfaces(id) ON DELETE CASCADE,
    port_id UUID REFERENCES ports(id) ON DELETE CASCADE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    -- Interface binding requires interface_id, Port binding requires port_id
    CONSTRAINT valid_binding CHECK (
        (binding_type = 'Interface' AND interface_id IS NOT NULL AND port_id IS NULL) OR
        (binding_type = 'Port' AND port_id IS NOT NULL)
    )
);

-- Migrate existing data from services.bindings JSONB
-- Binding serializes with serde tag as: { type: "Interface"|"Port", id, interface_id, port_id? }
-- network_id is derived from the service's network_id

-- Interface bindings
INSERT INTO bindings (id, network_id, service_id, binding_type, interface_id, created_at, updated_at)
SELECT
    (b->>'id')::UUID,
    s.network_id,
    s.id,
    'Interface',
    (b->>'interface_id')::UUID,
    s.created_at,
    s.updated_at
FROM services s, jsonb_array_elements(s.bindings) AS b
WHERE s.bindings IS NOT NULL
  AND jsonb_array_length(s.bindings) > 0
  AND b->>'type' = 'Interface';

-- Port bindings
INSERT INTO bindings (id, network_id, service_id, binding_type, interface_id, port_id, created_at, updated_at)
SELECT
    (b->>'id')::UUID,
    s.network_id,
    s.id,
    'Port',
    (b->>'interface_id')::UUID,  -- Can be null for "all interfaces"
    (b->>'port_id')::UUID,
    s.created_at,
    s.updated_at
FROM services s, jsonb_array_elements(s.bindings) AS b
WHERE s.bindings IS NOT NULL
  AND jsonb_array_length(s.bindings) > 0
  AND b->>'type' = 'Port';

CREATE INDEX idx_bindings_network ON bindings(network_id);
CREATE INDEX idx_bindings_service ON bindings(service_id);
CREATE INDEX idx_bindings_interface ON bindings(interface_id);
CREATE INDEX idx_bindings_port ON bindings(port_id);

-- Drop bindings JSONB column from services
ALTER TABLE services DROP COLUMN bindings;

-- Drop services column from hosts (services are queried via services.host_id)
-- The save-topology migration converted this to UUID[], but it's not used
ALTER TABLE hosts DROP COLUMN IF EXISTS services;
