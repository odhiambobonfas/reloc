-- Database Migration Script
-- Run this to add missing columns to existing tables

-- Check if posts table exists and add missing columns
DO $$ 
BEGIN
    -- Add created_at column to posts if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'posts' AND column_name = 'created_at') THEN
        ALTER TABLE posts ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added created_at column to posts table';
    ELSE
        RAISE NOTICE 'created_at column already exists in posts table';
    END IF;

    -- Add updated_at column to posts if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'posts' AND column_name = 'updated_at') THEN
        ALTER TABLE posts ADD COLUMN updated_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added updated_at column to posts table';
    ELSE
        RAISE NOTICE 'updated_at column already exists in posts table';
    END IF;

    -- Add type column to posts if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'posts' AND column_name = 'type') THEN
        ALTER TABLE posts ADD COLUMN type VARCHAR(50) DEFAULT 'general';
        RAISE NOTICE 'Added type column to posts table';
    ELSE
        RAISE NOTICE 'type column already exists in posts table';
    END IF;

    -- Add media_url column to posts if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'posts' AND column_name = 'media_url') THEN
        ALTER TABLE posts ADD COLUMN media_url TEXT;
        RAISE NOTICE 'Added media_url column to posts table';
    ELSE
        RAISE NOTICE 'media_url column already exists in posts table';
    END IF;

    -- Add likes column to posts if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'posts' AND column_name = 'likes') THEN
        ALTER TABLE posts ADD COLUMN likes INT DEFAULT 0;
        RAISE NOTICE 'Added likes column to posts table';
    ELSE
        RAISE NOTICE 'likes column already exists in posts table';
    END IF;

END $$;

-- Check if comments table exists and add missing columns
DO $$ 
BEGIN
    -- Add created_at column to comments if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'comments' AND column_name = 'created_at') THEN
        ALTER TABLE comments ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added created_at column to comments table';
    ELSE
        RAISE NOTICE 'created_at column already exists in comments table';
    END IF;

    -- Add user_id column to comments if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'comments' AND column_name = 'user_id') THEN
        ALTER TABLE comments ADD COLUMN user_id VARCHAR(255);
        RAISE NOTICE 'Added user_id column to comments table';
    ELSE
        RAISE NOTICE 'user_id column already exists in comments table';
    END IF;

    -- Add content column to comments if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'comments' AND column_name = 'content') THEN
        ALTER TABLE comments ADD COLUMN content TEXT;
        RAISE NOTICE 'Added content column to comments table';
    ELSE
        RAISE NOTICE 'content column already exists in comments table';
    END IF;

    -- Add parent_id column to comments if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'comments' AND column_name = 'parent_id') THEN
        ALTER TABLE comments ADD COLUMN parent_id INT REFERENCES comments(id) ON DELETE CASCADE;
        RAISE NOTICE 'Added parent_id column to comments table';
    ELSE
        RAISE NOTICE 'parent_id column already exists in comments table';
    END IF;

END $$;

-- Check if messages table exists and add missing columns
DO $$ 
BEGIN
    -- Add created_at column to messages if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'created_at') THEN
        ALTER TABLE messages ADD COLUMN created_at TIMESTAMP DEFAULT NOW();
        RAISE NOTICE 'Added created_at column to messages table';
    ELSE
        RAISE NOTICE 'created_at column already exists in messages table';
    END IF;

    -- Add is_seen column to messages if it doesn't exist
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns 
                   WHERE table_name = 'messages' AND column_name = 'is_seen') THEN
        ALTER TABLE messages ADD COLUMN is_seen BOOLEAN DEFAULT FALSE;
        RAISE NOTICE 'Added is_seen column to messages table';
    ELSE
        RAISE NOTICE 'is_seen column already exists in messages table';
    END IF;

END $$;

-- Create indexes if they don't exist
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

-- Create likes table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'likes') THEN
        CREATE TABLE likes (
            id SERIAL PRIMARY KEY,
            post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
            user_id VARCHAR(255) NOT NULL,
            created_at TIMESTAMP DEFAULT NOW(),
            UNIQUE(post_id, user_id)
        );
        RAISE NOTICE 'Created likes table';
    ELSE
        RAISE NOTICE 'likes table already exists';
    END IF;
END $$;

-- Create saved_posts table if it doesn't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.tables WHERE table_name = 'saved_posts') THEN
        CREATE TABLE saved_posts (
            id SERIAL PRIMARY KEY,
            user_id VARCHAR(255) NOT NULL,
            post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
            created_at TIMESTAMP DEFAULT NOW(),
            UNIQUE(user_id, post_id)
        );
        RAISE NOTICE 'Created saved_posts table';
    ELSE
        RAISE NOTICE 'saved_posts table already exists';
    END IF;
END $$;

-- Create indexes for likes table if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_likes_post_id') THEN
        CREATE INDEX idx_likes_post_id ON likes(post_id);
        RAISE NOTICE 'Created idx_likes_post_id index';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_likes_user_id') THEN
        CREATE INDEX idx_likes_user_id ON likes(user_id);
        RAISE NOTICE 'Created idx_likes_user_id index';
    END IF;
END $$;

-- Create indexes for saved_posts table if they don't exist
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_saved_posts_user_id') THEN
        CREATE INDEX idx_saved_posts_user_id ON saved_posts(user_id);
        RAISE NOTICE 'Created idx_saved_posts_user_id index';
    END IF;

    IF NOT EXISTS (SELECT 1 FROM pg_indexes WHERE indexname = 'idx_saved_posts_post_id') THEN
        CREATE INDEX idx_saved_posts_post_id ON saved_posts(post_id);
        RAISE NOTICE 'Created idx_saved_posts_post_id index';
    END IF;
END $$;

-- Show current table structure
SELECT
    table_name,
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns
WHERE table_name IN ('posts', 'comments', 'messages', 'likes', 'saved_posts')
ORDER BY table_name, ordinal_position;
