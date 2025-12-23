-- Phase 1: Subnet type cleanup
-- The subnet_type column is TEXT but stores JSON-encoded strings like "\"Lan\""
-- This migration strips the quotes to store plain text like "Lan"

UPDATE subnets SET subnet_type = TRIM(BOTH '"' FROM subnet_type);
