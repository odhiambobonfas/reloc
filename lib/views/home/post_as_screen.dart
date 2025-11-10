import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:reloc/core/network/api_service.dart';
import '../../core/constants/app_colors.dart';

class PostAsScreen extends StatefulWidget {
  const PostAsScreen({super.key});

  @override
  State<PostAsScreen> createState() => _PostAsScreenState();
}

class _PostAsScreenState extends State<PostAsScreen> {
  final TextEditingController _controller = TextEditingController();
  String _selectedPostType = 'Experience';
  bool _isLoading = false;
  File? _mediaFile;
  bool _isVideo = false;
  VideoPlayerController? _videoController;
  final ImagePicker _picker = ImagePicker();
  String? _authorName;

  final List<String> postTypes = ['Experience', 'Need to Vacate', 'Can Help Vacate'];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

        if (mounted) {
          setState(() {
            if (doc.exists) {
              _authorName = doc.data()?['fullName'] ??
                  user.displayName ??
                  user.email ??
                  "Anonymous";
            } else {
              _authorName = user.displayName ?? user.email ?? "Anonymous";
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _authorName = "Anonymous");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⚠️ Could not fetch user name: $e'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.navBar,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Select Media Type",
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          "Choose whether to add a photo or video to your post",
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'photo'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text("Photo"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'video'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
            child: const Text("Video"),
          ),
        ],
      ),
    );

    if (result == null) return;

    final pickedFile = result == 'photo'
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = result == 'video';

        if (_isVideo) {
          _videoController = VideoPlayerController.file(_mediaFile!)
            ..initialize().then((_) {
              if (mounted) {
                setState(() {});
              }
            });
        }
      });
    }
  }

  Future<void> _submitPost() async {
    final content = _controller.text.trim();
    if ((content.isEmpty && _mediaFile == null) || _authorName == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Please add text or media, and ensure you are logged in'),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      final response = await ApiService.uploadFile(
        '/posts',
        filePath: _mediaFile?.path ?? '', // Use empty string if no file
        fieldName: 'media',
        additionalFields: {
          'content': content,
          'uid': user.uid, // Correct field name
          'type': _selectedPostType,
        },
        requiresAuth: true,
      );

      if (response['success']) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('✅ Post created successfully!'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Server error: ${response['statusCode']}\n${response['message']}'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('❌ Exception occurred: $e');
      debugPrint('❌ Exception type: ${e.runtimeType}');
      
      String errorMessage = 'Unknown error occurred';
      
      if (e.toString().contains('SocketException')) {
        errorMessage = 'Cannot connect to server. Please check your internet connection and try again.';
      } else if (e.toString().contains('TimeoutException')) {
        errorMessage = 'Request timed out. Please try again.';
      } else if (e.toString().contains('FormatException')) {
        errorMessage = 'Invalid response from server. Please try again.';
      } else {
        errorMessage = 'Error: $e';
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Create Relocation Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.navBar,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User info section
            if (_authorName != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.navBar.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Posting as: $_authorName",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),

            // Post type dropdown
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: DropdownButtonFormField<String>(
                value: _selectedPostType,
                dropdownColor: AppColors.navBar,
                decoration: InputDecoration(
                  labelText: "Select Post Type",
                  labelStyle: const TextStyle(color: Colors.white70),
                  floatingLabelStyle: TextStyle(color: AppColors.primary),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                ),
                style: const TextStyle(color: Colors.white, fontSize: 16),
                items: postTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(color: Colors.white),
                          ),
                        ))
                    .toList(),
                onChanged: (val) => setState(() => _selectedPostType = val!),
                icon: Icon(Icons.arrow_drop_down, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 24),

            // Content text field
            Text(
              "Post Content",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: TextField(
                controller: _controller,
                maxLines: 6,
                style: const TextStyle(color: Colors.white, fontSize: 16),
                decoration: InputDecoration(
                  hintText: "Describe your experience or request...",
                  hintStyle: const TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Media preview section
            if (_mediaFile != null)
              Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.2)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: _isVideo
                          ? AspectRatio(
                              aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  VideoPlayer(_videoController!),
                                  if (!_videoController!.value.isPlaying)
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black.withOpacity(0.3),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.play_arrow,
                                        color: Colors.white,
                                        size: 48,
                                      ),
                                    ),
                                ],
                              ),
                            )
                          : Image.file(
                              _mediaFile!,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        _isVideo ? "Video attached" : "Photo attached",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: Icon(Icons.delete_outline, color: Colors.red),
                        onPressed: () => setState(() {
                          _mediaFile = null;
                          _videoController?.dispose();
                          _videoController = null;
                        }),
                        tooltip: "Remove media",
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),

            // Add media button
            Container(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _pickMedia,
                icon: Icon(Icons.add_photo_alternate, color: Colors.black),
                label: Text(
                  "Add Photo/Video",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            _isLoading
                ? Center(
                    child: Column(
                      children: [
                        CircularProgressIndicator(
                          color: AppColors.primary,
                          strokeWidth: 3,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "Creating post...",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : Container(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _submitPost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: Text(
                        "Create Post",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}