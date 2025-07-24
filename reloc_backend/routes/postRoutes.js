const express = require('express');
const router = express.Router();
const multer = require('multer');
const path = require('path');
const { Pool } = require('pg');

// ✅ PostgreSQL Connection
const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
});

// ✅ Multer for media uploads
const storage = multer.diskStorage({
  destination: (req, file, cb) => {
    cb(null, 'uploads/');
  },
  filename: (req, file, cb) => {
    cb(null, Date.now() + path.extname(file.originalname));
  },
});
const upload = multer({ storage });

// ✅ 1. Get all posts
router.get('/', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM posts ORDER BY timestamp DESC');
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ 2. Create new post
router.post('/', upload.single('media'), async (req, res) => {
  try {
    const { author, content, is_video } = req.body;
    const mediaUrl = req.file
      ? `http://${process.env.SERVER_IP}:${process.env.PORT}/uploads/${req.file.filename}`
      : null;

    const result = await pool.query(
      'INSERT INTO posts (author, content, media_url, is_video) VALUES ($1, $2, $3, $4) RETURNING *',
      [author, content, mediaUrl, is_video === 'true']
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ 3. Like a post
router.post('/:id/like', async (req, res) => {
  try {
    const { id } = req.params;
    await pool.query('UPDATE posts SET likes = likes + 1 WHERE id = $1', [id]);
    res.json({ success: true });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ 4. Get comments for a post
router.get('/:id/comments', async (req, res) => {
  try {
    const { id } = req.params;
    const result = await pool.query(
      'SELECT * FROM comments WHERE post_id = $1 ORDER BY timestamp DESC',
      [id]
    );
    res.json(result.rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// ✅ 5. Add comment to a post
router.post('/:id/comments', async (req, res) => {
  try {
    const { id } = req.params;
    const { author, text } = req.body;

    const result = await pool.query(
      'INSERT INTO comments (post_id, author, text) VALUES ($1, $2, $3) RETURNING *',
      [id, author, text]
    );

    res.json(result.rows[0]);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
