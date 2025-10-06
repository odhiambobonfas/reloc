# Post Creation Troubleshooting Guide

## 🔧 **Issues Fixed**

### **1. Enhanced Error Handling**
- ✅ **Backend Validation**: Added proper field validation
- ✅ **Detailed Logging**: Comprehensive logging for debugging
- ✅ **Better Error Messages**: User-friendly error messages
- ✅ **Database Error Handling**: Proper database error handling

### **2. Database Connection Issues**
- ✅ **Connection Testing**: Added database connection test on startup
- ✅ **Enhanced Pool Configuration**: Better connection pool settings
- ✅ **Error Logging**: Detailed database error logging
- ✅ **Graceful Fallbacks**: Proper error handling without crashes

### **3. File Upload Issues**
- ✅ **Uploads Directory**: Automatic creation of uploads directory
- ✅ **File Permissions**: Proper file permission handling
- ✅ **Media Validation**: Better media file handling
- ✅ **Error Recovery**: Graceful handling of upload errors

### **4. Frontend Improvements**
- ✅ **Better Error Messages**: User-friendly error messages
- ✅ **Network Error Handling**: Proper network error handling
- ✅ **Loading States**: Better loading indicators
- ✅ **Debug Logging**: Comprehensive client-side logging

## 🚀 **How to Test**

### **1. Start the Backend**
```bash
cd reloc_backend
npm start
```

**Expected Output:**
```
✅ Created uploads directory
✅ Uploads directory already exists
🔧 Database Configuration: { user: 'postgres', host: '192.168.9.64', ... }
✅ PostgreSQL connected successfully!
✅ Database query test successful: { now: '2024-01-01T12:00:00.000Z' }
✅ Server running at http://192.168.9.64:5000
```

### **2. Test Post Creation**

#### **Text Only Post:**
1. Open the app
2. Go to Community tab
3. Tap the "Post As" button
4. Select post type (e.g., "Experience")
5. Add some text content
6. Tap "Post"

#### **Media Post:**
1. Follow steps 1-5 above
2. Tap "Add Photo/Video"
3. Select a photo or video
4. Tap "Post"

## 🔍 **Debugging Steps**

### **1. Check Backend Logs**
Look for these log messages when creating a post:

```
📝 Creating post with data: { body: {...}, file: 'filename.jpg', headers: {...} }
💾 Saving post to database: { user_id: '...', content: '...', type: '...', media_url: '...' }
✅ Post created successfully: { id: 1, user_id: '...', ... }
```

### **2. Check Frontend Logs**
Look for these log messages in Flutter:

```
🚀 Submitting post with data:
  - Content: Your post content
  - User ID: firebase_user_id
  - Type: Experience
  - Media: /path/to/media/file
📤 Request fields: {content: '...', user_id: '...', type: '...'}
🌐 Sending request to: http://192.168.9.64:5000/api/posts
📥 Response status: 201
📥 Response body: {"success":true,"post":{...},"message":"Post created successfully"}
```

### **3. Common Error Messages**

#### **Database Connection Error:**
```
❌ PostgreSQL connection error: connect ECONNREFUSED 192.168.9.64:5432
```
**Solution:** Ensure PostgreSQL is running and accessible

#### **Missing Fields Error:**
```
❌ Missing user_id
❌ Missing content and media
❌ Missing type
```
**Solution:** Check that all required fields are being sent

#### **File Upload Error:**
```
❌ Error creating post: ENOENT: no such file or directory, open 'uploads/...' 
```
**Solution:** Ensure uploads directory exists and is writable

## 🛠️ **Manual Testing**

### **1. Test Database Connection**
```bash
# Connect to PostgreSQL
psql -h 192.168.9.64 -p 5432 -U postgres -d reloc

# Test query
SELECT * FROM posts LIMIT 5;
```

### **2. Test API Endpoint**
```bash
# Test with curl
curl -X POST http://192.168.9.64:5000/api/posts \
  -H "Content-Type: application/json" \
  -d 
    "user_id": "test_user",
    "content": "Test post",
    "type": "Experience"
  
```

### **3. Test File Upload**
```bash
# Test file upload with curl
curl -X POST http://192.168.9.64:5000/api/posts \
  -F "user_id=test_user" \
  -F "content=Test post with image" \
  -F "type=Experience" \
  -F "media=@/path/to/test/image.jpg"
```

## 🔧 **Configuration Files**

### **1. Environment Variables (.env)**
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

### **2. Database Schema**
Ensure your database has the correct schema:
```sql
CREATE TABLE posts (
    id SERIAL PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    content TEXT,
    type VARCHAR(50) NOT NULL,
    media_url TEXT,
    likes INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);
```

## 🚨 **Common Issues & Solutions**

### **Issue 1: "Cannot connect to server"**
**Cause:** Network connectivity or server not running
**Solution:**
1. Check if server is running: `npm start`
2. Check network connectivity
3. Verify IP address and port

### **Issue 2: "Database connection error"**
**Cause:** PostgreSQL not running or wrong credentials
**Solution:**
1. Start PostgreSQL service
2. Check database credentials
3. Verify database exists

### **Issue 3: "File upload failed"**
**Cause:** Uploads directory not writable
**Solution:**
1. Check uploads directory permissions
2. Ensure directory exists
3. Check disk space

### **Issue 4: "Missing required fields"**
**Cause:** Frontend not sending all required data
**Solution:**
1. Check Flutter form validation
2. Verify all fields are populated
3. Check network request format

## 📱 **Mobile-Specific Issues**

### **1. Network Issues**
- Ensure phone and server are on same network
- Check firewall settings
- Verify IP address is accessible from phone

### **2. File Permission Issues**
- Grant storage permissions to app
- Check file picker permissions
- Ensure media files are accessible

### **3. Firebase Authentication**
- Ensure user is properly authenticated
- Check Firebase configuration
- Verify user ID is being sent

## ✅ **Success Indicators**

When everything is working correctly, you should see:

### **Backend Logs:**
```
✅ PostgreSQL connected successfully!
✅ Database query test successful
📝 Creating post with data: {...}
💾 Saving post to database: {...}
✅ Post created successfully: {...}
```

### **Frontend Response:**
```
📥 Response status: 201
📥 Response body: {"success":true,"post":{...},"message":"Post created successfully"}
```

### **User Experience:**
- Green success message: "✅ Post created successfully!"
- Post appears in community feed
- No error messages in console

## 🎯 **Next Steps**

If you're still experiencing issues:

1. **Check all logs** (backend and frontend)
2. **Verify network connectivity**
3. **Test database connection manually**
4. **Check file permissions**
5. **Verify Firebase authentication**

The enhanced error handling and logging will help identify the specific issue causing the server error.
