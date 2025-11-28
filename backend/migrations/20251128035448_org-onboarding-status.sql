-- Add migration script here
ALTER TABLE organizations ADD COLUMN onboarding JSONB DEFAULT '[]';

-- Set onboarding for existing organizations where is_onboarded is true
UPDATE organizations 
SET onboarding = '["org_created", "onboarding_modal_completed"]'::JSONB
WHERE is_onboarded = true;

-- Drop the old is_onboarded column
ALTER TABLE organizations DROP COLUMN is_onboarded;