-- Migration: Set default Community plan for organizations and make plan NOT NULL

-- Step 1: Set the default plan to Community for any organization where it is NULL.
UPDATE organizations
SET plan = '{"type": "Community", "price": {"cents": 0, "rate": "Month"}, "trial_days": 0}'::jsonb
WHERE plan IS NULL;

-- Step 2: Make the plan column NOT NULL.
ALTER TABLE organizations
ALTER COLUMN plan SET NOT NULL;

-- Step 3: Add comment for clarity
COMMENT ON COLUMN organizations.plan IS 'The current billing plan for the organization (e.g., Community, Pro)';