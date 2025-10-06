-- Clean up comments table by migrating data from old columns to new columns

-- First, let's see what data we have
SELECT 'Current comments data:' as info;
SELECT id, post_id, author, text, timestamp, user_id, content, created_at, parent_id FROM comments;

-- Update user_id from author where user_id is NULL
UPDATE comments 
SET user_id = author 
WHERE user_id IS NULL AND author IS NOT NULL;

-- Update content from text where content is NULL
UPDATE comments 
SET content = text 
WHERE content IS NULL AND text IS NOT NULL;

-- Update created_at from timestamp where created_at is NULL
UPDATE comments 
SET created_at = timestamp 
WHERE created_at IS NULL AND timestamp IS NOT NULL;

-- Now let's see the updated data
SELECT 'Updated comments data:' as info;
SELECT id, post_id, author, text, timestamp, user_id, content, created_at, parent_id FROM comments;

-- Now we can safely drop the old columns
ALTER TABLE comments DROP COLUMN IF EXISTS author;
ALTER TABLE comments DROP COLUMN IF EXISTS text;
ALTER TABLE comments DROP COLUMN IF EXISTS timestamp;

-- Make user_id and content NOT NULL
ALTER TABLE comments ALTER COLUMN user_id SET NOT NULL;
ALTER TABLE comments ALTER COLUMN content SET NOT NULL;

-- Show final structure
SELECT 'Final comments table structure:' as info;
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'comments'
ORDER BY ordinal_position;
