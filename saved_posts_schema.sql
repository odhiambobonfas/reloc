-- Saved Posts table
DROP TABLE IF EXISTS saved_posts CASCADE;

CREATE TABLE saved_posts (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    post_id INT NOT NULL REFERENCES posts(id) ON DELETE CASCADE,
    created_at TIMESTAMP DEFAULT NOW(),
    UNIQUE(user_id, post_id)
);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_saved_posts_user_id ON saved_posts(user_id);
CREATE INDEX IF NOT EXISTS idx_saved_posts_post_id ON saved_posts(post_id);
