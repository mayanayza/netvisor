-- Migration: Convert CommercialSelfHosted plans to Community
-- This fixes a bug where server:latest incorrectly pointed to the commercial build,
-- causing fresh installs to get CommercialSelfHosted instead of Community.

UPDATE organizations
SET plan = jsonb_set(plan, '{type}', '"Community"')
WHERE plan->>'type' = 'CommercialSelfHosted';
