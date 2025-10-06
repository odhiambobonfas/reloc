# Reloc App Setup Guide

This guide will help you set up the Reloc app with the new database schema and ensure the backend and frontend work together properly.

## 🗄️ Database Setup

### 1. Run Database Setup Script

```bash
# Make the script executable
chmod +x setup_database.sh

# Run the database setup
./setup_database.sh
```

This script will:
- Create the `posts` table with `media_url` support
- Create the `comments` table with nested replies support
- Create the `messages` table for chat functionality
- Add performance indexes
- Insert sample data for testing

### 2. Manual Database Setup (Alternative)

If you prefer to run the SQL manually:

```bash
# Connect to PostgreSQL
psql -h 192.168.9.64 -p 5432 -U postgres -d reloc

# Run the setup script
\i database_setup.sql
```

## 🚀 Backend Setup

### 1. Install Dependencies

```bash
cd reloc_backend
npm install
```

### 2. Environment Configuration

Create a `.env` file in the `reloc_backend` directory:

```env
DB_USER=postgres
DB_HOST=192.168.9.64
DB_NAME=reloc
DB_PASSWORD=Othina78
DB_PORT=5432
NODE_ENV=development
PORT=5000
SERVER_IP=192.168.9.64
```

### 3. Start the Backend Server

```bash
cd reloc_backend
npm start
```

The server will start on `http://192.168.9.64:5000`

## 📱 Frontend Setup

### 1. Install Flutter Dependencies

```bash
flutter pub get
```

### 2. Run the Flutter App

```bash
flutter run
```

## 🔧 Key Changes Made

### Database Schema Updates

1. **Posts Table**:
   - Changed from `image_url`/`video_url` to unified `media_url`
   - Added `updated_at` timestamp
   - Made `type` field required
   - Removed `liked_by` JSONB field (simplified to just `likes` count)

2. **Comments Table**:
   - Changed from `uid`/`author` to `user_id`
   - Changed from `text` to `content`
   - Added proper foreign key constraints

3. **Messages Table**:
   - Updated timestamp format to use `NOW()`

### Backend API Updates

1. **Post Controller**:
   - Updated to use `media_url` instead of separate image/video URLs
   - Simplified like functionality

2. **Comment Controller**:
   - Updated field names to match new schema
   - Changed from `author`/`text` to `user_id`/`content`

3. **Post Extras Controller**:
   - Removed `liked_by` references
   - Updated field mappings

### Frontend Updates

1. **Community Screen**:
   - Updated comment API calls to use new field names
   - Fixed comment display to use `user_id` and `created_at`

2. **Comment Sheet**:
   - Updated API payload structure
   - Fixed field name mappings

## 🧪 Testing the Application

### 1. Test Posts

- Create a new post with text content
- Add media to posts (images/videos)
- Like posts
- View posts in the community feed

### 2. Test Comments

- Add comments to posts
- Reply to comments (nested comments)
- View comment threads

### 3. Test Messages

- Send messages between users
- View conversation history
- Check message status

## 🔍 API Endpoints

### Posts
- `GET /api/posts` - Get all posts
- `POST /api/posts` - Create a new post
- `POST /api/posts/:id/like` - Like a post
- `GET /api/posts/saved` - Get saved posts

### Comments
- `GET /api/posts/:postId/comments` - Get comments for a post
- `POST /api/posts/:postId/comments` - Add a comment
- `DELETE /api/comments/:id` - Delete a comment

### Messages
- `GET /api/messages` - Get messages between users
- `POST /api/messages` - Send a message
- `GET /api/messages/conversations` - Get user conversations

## 🐛 Troubleshooting

### Database Connection Issues

1. Check if PostgreSQL is running:
   ```bash
   sudo systemctl status postgresql
   ```

2. Verify connection details in `.env` file

3. Test connection manually:
   ```bash
psql -h 192.168.9.64 -p 5432 -U postgres -d reloc
   ```

### Backend Issues

1. Check server logs for errors
2. Verify all dependencies are installed
3. Ensure environment variables are set correctly

### Frontend Issues

1. Check if backend is running and accessible
2. Verify API base URL in Flutter app
3. Check network connectivity

## 📝 Notes

- The app now uses a unified `media_url` field for both images and videos
- Comments support nested replies through the `parent_id` field
- Like functionality is simplified to just increment the count
- All timestamps use PostgreSQL's `NOW()` function
- The database includes sample data for testing

## 🎉 Success!

Once you've completed these steps, your Reloc app should be fully functional with:
- ✅ Working posts with media support
- ✅ Nested comments system
- ✅ Like functionality
- ✅ Chat/messaging system
- ✅ Proper database schema
- ✅ Backend-frontend integration