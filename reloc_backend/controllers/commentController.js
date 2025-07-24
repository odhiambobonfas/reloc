const pool = require("../db");

// ✅ Get comments (with nested replies)
exports.getCommentsByPost = async (req, res) => {
  const { postId } = req.params;

  try {
    const { rows } = await pool.query(
      `WITH RECURSIVE comment_tree AS (
        SELECT id, post_id, author, text, parent_comment_id, timestamp
        FROM comments
        WHERE post_id = $1 AND parent_comment_id IS NULL
        UNION ALL
        SELECT c.id, c.post_id, c.author, c.text, c.parent_comment_id, c.timestamp
        FROM comments c
        INNER JOIN comment_tree ct ON c.parent_comment_id = ct.id
      )
      SELECT * FROM comment_tree ORDER BY timestamp ASC`,
      [postId]
    );

    // ✅ Group replies into a nested structure
    const commentMap = {};
    const nestedComments = [];

    rows.forEach((comment) => {
      comment.replies = [];
      commentMap[comment.id] = comment;
      if (comment.parent_comment_id) {
        commentMap[comment.parent_comment_id].replies.push(comment);
      } else {
        nestedComments.push(comment);
      }
    });

    res.json(nestedComments);
  } catch (err) {
    console.error("❌ Error fetching comments:", err);
    res.status(500).json({ error: "Server error" });
  }
};

// ✅ Add new comment or reply
exports.addComment = async (req, res) => {
  const { postId } = req.params;
  const { author, text, parent_comment_id } = req.body;

  if (!text || !author) {
    return res.status(400).json({ error: "Text and author are required" });
  }

  try {
    await pool.query(
      "INSERT INTO comments (post_id, author, text, parent_comment_id) VALUES ($1, $2, $3, $4)",
      [postId, author, text, parent_comment_id || null]
    );
    res.json({ message: "✅ Comment added successfully" });
  } catch (err) {
    console.error("❌ Error adding comment:", err);
    res.status(500).json({ error: "Server error" });
  }
};
