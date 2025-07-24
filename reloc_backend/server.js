const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();
const path = require('path');
const { Pool } = require('pg'); // ✅ PostgreSQL

const app = express();

// ✅ PostgreSQL Connection
const pool = new Pool({
  user: process.env.DB_USER || 'postgres',
  host: process.env.DB_HOST || '192.168.100.76',
  database: process.env.DB_NAME || 'reloc',
  password: process.env.DB_PASSWORD || 'your_password_here',
  port: process.env.DB_PORT || 5432,
});

// ✅ Test Database Connection
pool.connect()
  .then(() => console.log('✅ PostgreSQL connected successfully!'))
  .catch((err) => console.error('❌ PostgreSQL connection error:', err));

// ✅ Make Pool Global (accessible in routes)
global.db = pool;

// ✅ Middlewares
app.use(cors());
app.use(bodyParser.json());
app.use('/uploads', express.static(path.join(__dirname, 'uploads'))); // Serve uploaded files

// ✅ Routes
const postRoutes = require('./routes/postRoutes');
const commentRoutes = require('./routes/commentRoutes'); // ✅ NEW

app.use('/api/posts', postRoutes);
app.use('/api/posts', commentRoutes); // ✅ Handles /api/posts/:postId/comments

// ✅ Default Route (optional)
app.get('/', (req, res) => {
  res.send('✅ Reloc Community API is running...');
});

// ✅ Start Server
const PORT = process.env.PORT || 5000;
const SERVER_IP = process.env.SERVER_IP || '192.168.100.76';

app.listen(PORT, SERVER_IP, () =>
  console.log(`✅ Server running at http://${SERVER_IP}:${PORT}`)
);
