-- Migration: Fix JSONB null plans for self-hosted instances

UPDATE organizations
SET plan = '{
  "type": "Community",
  "base_cents": 0,
  "rate": "Month",
  "trial_days": 0,
  "seat_cents": null,
  "network_cents": null,
  "included_seats": null,
  "included_networks": null
}'::jsonb
WHERE (plan IS NULL OR plan = 'null'::jsonb)
  AND onboarding @> '["OnboardingModalCompleted"]'::jsonb;