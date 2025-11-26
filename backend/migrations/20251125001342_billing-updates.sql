-- Migration: Restructure BillingPlan to use PlanConfig tuple variant
-- Transforms existing plan JSONB from:
--   {"type": "Team", "price": {"cents": 14900, "rate": "Month"}, "trial_days": 14}
-- To:
--   {"type": "Team", "config": {"base_cents": 14900, "rate": "Month", ...}}

UPDATE organizations
SET plan = jsonb_build_object(
    'type', plan->>'type',
    'config', jsonb_build_object(
        'base_cents', (plan->'price'->>'cents')::integer,
        'rate', plan->'price'->>'rate',
        'trial_days', (plan->>'trial_days')::integer,
        'seat_cents', CASE 
            WHEN plan->>'type' IN ('Team', 'Enterprise') THEN 1000
            ELSE NULL 
        END,
        'network_cents', CASE 
            WHEN plan->>'type' IN ('Pro', 'Team') THEN 500
            ELSE NULL 
        END,
        'included_seats', CASE plan->>'type'
            WHEN 'Community' THEN NULL
            WHEN 'Starter' THEN 1
            WHEN 'Pro' THEN 1
            WHEN 'Team' THEN 5
            WHEN 'Enterprise' THEN 25
            ELSE 1
        END,
        'included_networks', CASE plan->>'type'
            WHEN 'Community' THEN NULL
            WHEN 'Starter' THEN 1
            WHEN 'Pro' THEN 3
            WHEN 'Team' THEN 10
            WHEN 'Enterprise' THEN NULL
            ELSE 1
        END
    )
)
WHERE plan IS NOT NULL;