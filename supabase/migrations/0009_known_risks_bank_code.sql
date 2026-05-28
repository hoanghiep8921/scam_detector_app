-- Add bank_code column to known_risks for bank-specific account matching.
-- This allows the app to distinguish between account numbers at different banks
-- (e.g. MB Bank uses 10-digit phone numbers, while other banks use 13-20 digits).

ALTER TABLE public.known_risks
ADD COLUMN IF NOT EXISTS bank_code text;

-- Index for faster bank-specific lookups.
CREATE INDEX IF NOT EXISTS known_risks_bank_code_idx
ON public.known_risks (bank_code)
WHERE type = 'bankAccount';
