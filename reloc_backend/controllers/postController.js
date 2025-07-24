const pool = require('../db/index');

exports.createPost = async (req, res) => {
  const { content, type, user_id, is_video } = req.body;
  const mediaUrl = req.file ? `/uploads/${req.file.filename}` : null;

  try {
    const newPost = await pool.query(
      `INSERT INTO community_posts (content, type, user_id, media_url, is_video)
       VALUES ($1, $2, $3, $4, $5) RETURNING *`,
      [content, type, user_id, mediaUrl, is_video === 'true']
    );
    res.status(200).json(newPost.rows[0]);
  } catch (err) {
    console.error("Error creating post:", err.message);
    res.status(500).json({ error: err.message });
  }
};

exports.getPosts = async (req, res) => {
  try {
    const posts = await pool.query(
      'SELECT * FROM community_posts ORDER BY timestamp DESC'
    );
    res.status(200).json(posts.rows);
  } catch (err) {
    console.error("Error fetching posts:", err.message);
    res.status(500).json({ error: err.message });
  }
};
