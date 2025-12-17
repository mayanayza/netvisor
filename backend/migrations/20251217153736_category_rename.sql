-- Migration: Replace removed service categories with new ones in saved topology options
-- Categories were restructured to be more mutually exclusive:
--   - Collaboration split into ProjectManagement, Messaging, Office
--   - Communication split into Telephony, Conferencing, Email
--   - FileSharing merged into Office
--   - Web split into Publishing, Office, Messaging, etc.
--
-- Only targeting the specific category array fields to avoid mangling user strings like left_zone_title

-- FileSharing -> Office in left_zone_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,left_zone_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'FileSharing' THEN 'Office' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'left_zone_service_categories') AS elem
  )
)
WHERE options->'request'->'left_zone_service_categories' ? 'FileSharing';

-- FileSharing -> Office in hide_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,hide_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'FileSharing' THEN 'Office' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'hide_service_categories') AS elem
  )
)
WHERE options->'request'->'hide_service_categories' ? 'FileSharing';

-- Collaboration -> ProjectManagement in left_zone_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,left_zone_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'Collaboration' THEN 'ProjectManagement' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'left_zone_service_categories') AS elem
  )
)
WHERE options->'request'->'left_zone_service_categories' ? 'Collaboration';

-- Collaboration -> ProjectManagement in hide_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,hide_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'Collaboration' THEN 'ProjectManagement' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'hide_service_categories') AS elem
  )
)
WHERE options->'request'->'hide_service_categories' ? 'Collaboration';

-- Communication -> Telephony in left_zone_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,left_zone_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'Communication' THEN 'Telephony' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'left_zone_service_categories') AS elem
  )
)
WHERE options->'request'->'left_zone_service_categories' ? 'Communication';

-- Communication -> Telephony in hide_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,hide_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'Communication' THEN 'Telephony' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'hide_service_categories') AS elem
  )
)
WHERE options->'request'->'hide_service_categories' ? 'Communication';

-- Web -> Publishing in left_zone_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,left_zone_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'Web' THEN 'Publishing' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'left_zone_service_categories') AS elem
  )
)
WHERE options->'request'->'left_zone_service_categories' ? 'Web';

-- Web -> Publishing in hide_service_categories
UPDATE topologies
SET options = jsonb_set(
  options,
  '{request,hide_service_categories}',
  (
    SELECT COALESCE(jsonb_agg(
      CASE WHEN elem = 'Web' THEN 'Publishing' ELSE elem END
    ), '[]'::jsonb)
    FROM jsonb_array_elements_text(options->'request'->'hide_service_categories') AS elem
  )
)
WHERE options->'request'->'hide_service_categories' ? 'Web';
