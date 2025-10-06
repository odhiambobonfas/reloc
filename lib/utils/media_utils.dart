class MediaUtils {
  static const String serverBaseUrl = 'http://192.168.20.58:5000';

  static String getFullMediaUrl(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) {
      print('MediaUtils: mediaUrl is null or empty');
      return '';
    }
    
    print('MediaUtils: Processing mediaUrl: $mediaUrl');
    
    // If it's already a full URL, return as is
    if (mediaUrl.startsWith('http://') || mediaUrl.startsWith('https://')) {
      print('MediaUtils: Already a full URL, returning as is');
      return mediaUrl;
    }
    
    // If it's a relative path, add the server base URL
    if (mediaUrl.startsWith('/')) {
      final fullUrl = '$serverBaseUrl$mediaUrl';
      print('MediaUtils: Created full URL: $fullUrl');
      return fullUrl;
    }
    
    // If it doesn't start with /, add it
    final fullUrl = '$serverBaseUrl/$mediaUrl';
    print('MediaUtils: Created full URL: $fullUrl');
    return fullUrl;
  }
  
  /// Checks if a media URL is a video
  static bool isVideo(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) return false;
    
    final videoExtensions = ['.mp4', '.avi', '.mov', '.wmv', '.flv', '.webm'];
    final lowerUrl = mediaUrl.toLowerCase();
    
    return videoExtensions.any((ext) => lowerUrl.endsWith(ext));
  }
  
  /// Gets the media type (image, video, or unknown)
  static String getMediaType(String? mediaUrl) {
    if (mediaUrl == null || mediaUrl.isEmpty) return 'unknown';
    
    if (isVideo(mediaUrl)) return 'video';
    
    final imageExtensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp'];
    final lowerUrl = mediaUrl.toLowerCase();
    
    if (imageExtensions.any((ext) => lowerUrl.endsWith(ext))) {
      return 'image';
    }
    
    return 'unknown';
  }
}
