-- Phase 7: Create group_bindings junction table

-- Create junction table with position for ordered bindings
CREATE TABLE group_bindings (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    group_id UUID NOT NULL REFERENCES groups(id) ON DELETE CASCADE,
    binding_id UUID NOT NULL REFERENCES bindings(id) ON DELETE CASCADE,
    position INTEGER NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE(group_id, binding_id)
);

-- Migrate from JSONB group_type->service_bindings
-- service_bindings is stored inside the group_type JSONB field
INSERT INTO group_bindings (group_id, binding_id, position)
SELECT g.id, (binding.value)::UUID, binding.ordinality - 1
FROM groups g, jsonb_array_elements_text(g.group_type->'service_bindings') WITH ORDINALITY AS binding
WHERE g.group_type->'service_bindings' IS NOT NULL
  AND jsonb_array_length(g.group_type->'service_bindings') > 0;

CREATE INDEX idx_group_bindings_group ON group_bindings(group_id);
CREATE INDEX idx_group_bindings_binding ON group_bindings(binding_id);

-- Simplify group_type to just store the discriminant (no embedded service_bindings)
ALTER TABLE groups ADD COLUMN group_type_discriminant TEXT;
UPDATE groups SET group_type_discriminant = group_type->>'group_type';
ALTER TABLE groups ALTER COLUMN group_type_discriminant SET NOT NULL;
ALTER TABLE groups DROP COLUMN group_type;
ALTER TABLE groups RENAME COLUMN group_type_discriminant TO group_type;
