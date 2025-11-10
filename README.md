# Reloc - Relocation Community App

A comprehensive cross-platform relocation community application built with Flutter and Node.js, designed to work seamlessly across Android, iOS, and Web platforms.

## 🚀 Features

### Cross-Platform Support
- **Android**: Full native functionality with Material Design
- **iOS**: Native iOS experience with Cupertino design elements
- **Web**: Progressive Web App (PWA) with responsive design
- **Responsive Design**: Adapts to different screen sizes and orientations

### Core Functionality
- **Community Posts**: Share and interact with relocation-related content
- **Mover Services**: Find and connect with professional movers
- **Resident Network**: Connect with other residents in your area
- **Real-time Chat**: Built-in messaging system
- **Payment Integration**: M-Pesa payment processing
- **Location Services**: Find nearby services and users
- **Media Support**: Photo and video sharing capabilities

## 🛠️ Technical Stack

### Frontend (Flutter)
- **Framework**: Flutter 3.8+
- **State Management**: Provider pattern
- **Theme System**: Custom light/dark themes with platform-specific adjustments
- **Responsive Layout**: Adaptive UI for different screen sizes
- **Cross-Platform Services**: Unified APIs for all platforms

### Backend (Node.js)
- **Runtime**: Node.js 18+
- **Framework**: Express.js 5.1+
- **Database**: PostgreSQL with connection pooling
- **Security**: Helmet.js, rate limiting, CORS protection
- **File Upload**: Multer with secure file handling
- **Authentication**: JWT-based authentication system

## 🔧 Installation & Setup

### Prerequisites
- Flutter SDK 3.8+
- Node.js 18+
- PostgreSQL 12+
- Android Studio / Xcode (for mobile development)

### Frontend Setup
```bash
# Clone the repository
git clone <repository-url>
cd reloc

# Install Flutter dependencies
flutter pub get

# Run the app
flutter run
```

### Backend Setup
```bash
cd reloc_backend

# Install dependencies
npm install

# Set up environment variables
cp .env.example .env
# Edit .env with your database credentials

# Start the server
npm run dev
```

### Environment Variables
Create a `.env` file in the backend directory:
```env
DB_USER=postgres
DB_HOST=192.168.20.207
DB_NAME=reloc
DB_PASSWORD=your_password
DB_PORT=5432
NODE_ENV=development
SERVER_IP=192.168.20.207
```

## 📱 Platform-Specific Features

### Android
- Native Material Design components
- Permission handling for camera, location, storage
- Background services support
- Push notifications

### iOS
- Native Cupertino design elements
- iOS-specific permission dialogs
- Background app refresh
- Apple Push Notification Service (APNs)

### Web
- Progressive Web App (PWA) capabilities
- Service Worker for offline support
- Responsive design for desktop and mobile browsers
- Browser-based permission handling

## 🎨 Theme System

The app features a comprehensive theme system with:
- **Light Theme**: Clean, modern design for daytime use
- **Dark Theme**: Samsung-inspired dark theme for low-light environments
- **Platform Adaptation**: Automatic theme adjustments based on platform
- **Responsive Typography**: Adaptive font sizes across devices

## 🔒 Security Features

### Backend Security
- Helmet.js for security headers
- Rate limiting to prevent abuse
- CORS protection with configurable origins
- Input validation and sanitization
- Secure file upload handling

### Frontend Security
- Secure storage for sensitive data
- Permission-based feature access
- Input validation and sanitization
- Secure API communication

## 📊 Performance Optimizations

### Frontend
- Lazy loading for images and content
- Efficient state management
- Optimized rendering for large lists
- Platform-specific performance tuning

### Backend
- Database connection pooling
- Efficient query optimization
- File compression and caching
- Rate limiting and request throttling

## 🧪 Testing

### Frontend Testing
```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

### Backend Testing
```bash
cd reloc_backend

# Run tests
npm test

# Run with coverage
npm run test:coverage
```

## 📦 Building & Deployment

### Mobile Apps
```bash
# Build Android APK
flutter build apk --release

# Build iOS
flutter build ios --release
```

### Web App
```bash
# Build for web
flutter build web --release

# Deploy to hosting service
# Copy build/web contents to your web server
```

### Backend Deployment
```bash
cd reloc_backend

# Production build
npm run build

# Start production server
npm start
```

## 🔄 API Endpoints

### Posts
- `GET /api/posts` - Get all posts
- `POST /api/posts` - Create new post
- `PUT /api/posts/:id` - Update post
- `DELETE /api/posts/:id` - Delete post

### Messages
- `GET /api/messages` - Get user messages
- `POST /api/messages` - Send message
- `PUT /api/messages/:id` - Update message

### Payments
- `POST /api/mpesa/deposit` - Process deposit
- `POST /api/mpesa/payment` - Process payment
- `POST /api/mpesa/withdraw` - Process withdrawal

### Notifications
- `GET /api/notifications` - Get user notifications
- `POST /api/notifications` - Create notification

## 🚀 Recent Improvements (v2.0.0)

### Cross-Platform Enhancements
- **Responsive Layout System**: Adaptive UI for all screen sizes
- **Platform Detection**: Automatic platform-specific optimizations
- **Unified Services**: Cross-platform API and storage services
- **Enhanced Permissions**: Platform-aware permission handling

### Backend Improvements
- **Enhanced Security**: Helmet.js, rate limiting, CORS protection
- **Better Error Handling**: Comprehensive error management
- **Health Monitoring**: Health check endpoints and logging
- **Performance Optimization**: Connection pooling and request optimization

### Frontend Improvements
- **Enhanced Theme System**: Light/dark themes with platform adaptation
- **Responsive Design**: Mobile-first design with tablet and desktop support
- **Better State Management**: Improved provider pattern implementation
- **Cross-Platform Services**: Unified services for all platforms

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the ISC License - see the LICENSE file for details.

## 🆘 Support

For support and questions:
- Create an issue in the repository
- Contact the development team
- Check the documentation

## 🔮 Roadmap

### Upcoming Features
- **Real-time Notifications**: Push notifications for all platforms
- **Advanced Search**: AI-powered search and recommendations
- **Video Calling**: Built-in video chat functionality
- **Offline Support**: Enhanced offline capabilities
- **Analytics Dashboard**: User engagement and app performance metrics

### Platform Expansion
- **Desktop Apps**: Windows and macOS native applications
- **Smart TV**: Android TV and Apple TV support
- **Wearables**: Smartwatch companion apps

---

**Built with ❤️ by the Reloc Development Team**
