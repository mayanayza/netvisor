-- Normalize existing color values to title case (e.g., "Blue")
-- This ensures compatibility with the new Color enum

UPDATE groups SET color = INITCAP(color) WHERE color != INITCAP(color);
UPDATE tags SET color = INITCAP(color) WHERE color != INITCAP(color);