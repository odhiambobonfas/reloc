const express = require("express");
const router = express.Router();
const {
  getCommentsByPost,
  addComment
} = require("../controllers/commentController");

// ✅ Get all comments (with replies) for a post
router.get("/:postId/comments", getCommentsByPost);

// ✅ Add a new comment or reply
router.post("/:postId/comments", addComment);

module.exports = router;
