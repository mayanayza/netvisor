-- Migration: Convert processed/total_to_process to progress percentage
UPDATE discovery
SET run_type = jsonb_set(
    run_type #- '{results,processed}' #- '{results,total_to_process}',
    '{results,progress}',
    to_jsonb(
        CASE 
            WHEN (run_type->'results'->>'total_to_process')::int > 0 
            THEN LEAST(100, ((run_type->'results'->>'processed')::int * 100) / (run_type->'results'->>'total_to_process')::int)
            ELSE 0
        END
    )
)
WHERE run_type->>'type' = 'Historical'
  AND run_type->'results'->>'processed' IS NOT NULL;