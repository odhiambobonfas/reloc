-- Database Column Fix Script
-- This script fixes column name mismatches between the code and database

-- Fix posts table column names
DO $$ 
BEGIN
    -- Rename author to user_id if it exists and user_id doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'posts' AND column_name = 'author') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'posts' AND column_name = 'user_id') THEN
        ALTER TABLE posts RENAME COLUMN author TO user_id;
        RAISE NOTICE 'Renamed author column to user_id in posts table';
    END IF;

    -- Rename timestamp to created_at if it exists and created_at doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'posts' AND column_name = 'timestamp') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'posts' AND column_name = 'created_at') THEN
        ALTER TABLE posts RENAME COLUMN timestamp TO created_at;
        RAISE NOTICE 'Renamed timestamp column to created_at in posts table';
    END IF;

    -- Add user_id column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'posts' AND column_name = 'user_id') THEN
        ALTER TABLE posts ADD COLUMN user_id VARCHAR(255);
        RAISE NOTICE 'Added user_id column to posts table';
    END IF;

    -- Make user_id NOT NULL if it's not already
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'posts' AND column_name = 'user_id' AND is_nullable = 'YES') THEN
        ALTER TABLE posts ALTER COLUMN user_id SET NOT NULL;
        RAISE NOTICE 'Made user_id NOT NULL in posts table';
    END IF;

END $$;

-- Fix comments table column names
DO $$ 
BEGIN
    -- Rename author to user_id if it exists and user_id doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'comments' AND column_name = 'author') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'comments' AND column_name = 'user_id') THEN
        ALTER TABLE comments RENAME COLUMN author TO user_id;
        RAISE NOTICE 'Renamed author column to user_id in comments table';
    END IF;

    -- Rename text to content if it exists and content doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'comments' AND column_name = 'text') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'comments' AND column_name = 'content') THEN
        ALTER TABLE comments RENAME COLUMN text TO content;
        RAISE NOTICE 'Renamed text column to content in comments table';
    END IF;

    -- Rename timestamp to created_at if it exists and created_at doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'comments' AND column_name = 'timestamp') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'comments' AND column_name = 'created_at') THEN
        ALTER TABLE comments RENAME COLUMN timestamp TO created_at;
        RAISE NOTICE 'Renamed timestamp column to created_at in comments table';
    END IF;

    -- Make user_id NOT NULL if it's not already
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'comments' AND column_name = 'user_id' AND is_nullable = 'YES') THEN
        ALTER TABLE comments ALTER COLUMN user_id SET NOT NULL;
        RAISE NOTICE 'Made user_id NOT NULL in comments table';
    END IF;

    -- Make content NOT NULL if it's not already
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'comments' AND column_name = 'content' AND is_nullable = 'YES') THEN
        ALTER TABLE comments ALTER COLUMN content SET NOT NULL;
        RAISE NOTICE 'Made content NOT NULL in comments table';
    END IF;

END $$;

-- Fix messages table column names
DO $$ 
BEGIN
    -- Rename sender_uid to sender_id if it exists and sender_id doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'messages' AND column_name = 'sender_uid') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'messages' AND column_name = 'sender_id') THEN
        ALTER TABLE messages RENAME COLUMN sender_uid TO sender_id;
        RAISE NOTICE 'Renamed sender_uid column to sender_id in messages table';
    END IF;

    -- Rename receiver_uid to receiver_id if it exists and receiver_id doesn't
    IF EXISTS (SELECT 1 FROM information_schema.columns 
               WHERE table_name = 'messages' AND column_name = 'receiver_uid') 
       AND NOT EXISTS (SELECT 1 FROM information_schema.columns 
                       WHERE table_name = 'messages' AND column_name = 'receiver_id') THEN
        ALTER TABLE messages RENAME COLUMN receiver_uid TO receiver_id;
        RAISE NOTICE 'Renamed receiver_uid column to receiver_id in messages table';
    END IF;

    -- Add type column if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'type') THEN
        ALTER TABLE messages ADD COLUMN type VARCHAR(50) DEFAULT 'text';
        RAISE NOTICE 'Added type column to messages table';
    END IF;

END $$;

-- Create indexes with correct column names
DO $$ 
BEGIN
    -- Posts indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_user_id') THEN
        CREATE INDEX idx_posts_user_id ON posts(user_id);
        RAISE NOTICE 'Created idx_posts_user_id index';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_created_at') THEN
        CREATE INDEX idx_posts_created_at ON posts(created_at);
        RAISE NOTICE 'Created idx_posts_created_at index';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_posts_type') THEN
        CREATE INDEX idx_posts_type ON posts(type);
        RAISE NOTICE 'Created idx_posts_type index';
    END IF;

    -- Comments indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_comments_post_id') THEN
        CREATE INDEX idx_comments_post_id ON comments(post_id);
        RAISE NOTICE 'Created idx_comments_post_id index';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_comments_user_id') THEN
        CREATE INDEX idx_comments_user_id ON comments(user_id);
        RAISE NOTICE 'Created idx_comments_user_id index';
    END IF;

    -- Messages indexes
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_sender_id') THEN
        CREATE INDEX idx_messages_sender_id ON messages(sender_id);
        RAISE NOTICE 'Created idx_messages_sender_id index';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_messages_receiver_id') THEN
        CREATE INDEX idx_messages_receiver_id ON messages(receiver_id);
        RAISE NOTICE 'Created idx_messages_receiver_id index';
    END IF;

END $$;

-- Show final table structure
SELECT 
    table_name, 
    column_name, 
    data_type, 
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name IN ('posts', 'comments', 'messages')
ORDER BY table_name, ordinal_position;
