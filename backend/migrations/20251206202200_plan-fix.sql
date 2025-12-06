-- Migration: Fix NULL plans for self-hosted instances with updated BillingPlan schema

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
WHERE plan IS NULL;