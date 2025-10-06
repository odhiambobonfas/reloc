import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
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
  String? _authorName; // ✅ Real user name from Firestore

  final List<String> postTypes = ['Experience', 'Need to Vacate', 'Can Help Vacate'];

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  /// ✅ Fetch user name from Firestore (users collection)
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
          SnackBar(content: Text('⚠️ Could not fetch user name: $e')),
        );
      }
    }
  }

  Future<void> _pickMedia() async {
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Select Media Type"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, 'photo'),
            child: const Text("Photo"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, 'video'),
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

  /// ✅ Submit Post to your backend API
  Future<void> _submitPost() async {
    final content = _controller.text.trim();
    if ((content.isEmpty && _mediaFile == null) || _authorName == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please add text or media, and ensure you are logged in')),
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

      debugPrint('🚀 Submitting post with data:');
      debugPrint('  - Content: ${content.isEmpty ? "No content" : content}');
      debugPrint('  - User ID: ${user.uid}');
      debugPrint('  - Type: $_selectedPostType');
      debugPrint('  - Media: ${_mediaFile != null ? _mediaFile!.path : "No media"}');

      var uri = Uri.parse("http://192.168.20.58:5000/api/posts");
      var request = http.MultipartRequest("POST", uri);

      // ✅ Add text fields
      request.fields['content'] = content;
      request.fields['user_id'] = user.uid;
      request.fields['type'] = _selectedPostType;

      debugPrint('📤 Request fields: ${request.fields}');

      // ✅ Add media file if any
      if (_mediaFile != null) {
        debugPrint('📁 Adding media file: ${_mediaFile!.path}');
        request.files.add(
          await http.MultipartFile.fromPath('media', _mediaFile!.path),
        );
        debugPrint('✅ Media file added to request');
      }

      debugPrint('🌐 Sending request to: $uri');
      var response = await request.send();
      debugPrint('📥 Response status: ${response.statusCode}');

      final responseBody = await response.stream.bytesToString();
      debugPrint('📥 Response body: $responseBody');

      if (response.statusCode == 200 || response.statusCode == 201) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Post created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } else {
        debugPrint('❌ Server error: ${response.statusCode}');
        debugPrint('❌ Response body: $responseBody');
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('❌ Server error: ${response.statusCode}\n$responseBody'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Create Relocation Post"),
        backgroundColor: AppColors.navBar,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_authorName != null)
              Text(
                "Posting as: $_authorName",
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedPostType,
              dropdownColor: Colors.grey[850],
              decoration: InputDecoration(
                labelText: "Select Post Type",
                labelStyle: const TextStyle(color: Colors.white),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              style: const TextStyle(color: Colors.white),
              items: postTypes
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (val) => setState(() => _selectedPostType = val!),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              maxLines: 6,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: "Describe your experience or request...",
                hintStyle: const TextStyle(color: Colors.white54),
                filled: true,
                fillColor: Colors.black12,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 20),
            if (_mediaFile != null)
              Column(
                children: [
                  _isVideo
                      ? AspectRatio(
                          aspectRatio: _videoController?.value.aspectRatio ?? 16 / 9,
                          child: VideoPlayer(_videoController!),
                        )
                      : Image.file(_mediaFile!),
                  const SizedBox(height: 10),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => setState(() {
                      _mediaFile = null;
                      _videoController?.dispose();
                      _videoController = null;
                    }),
                  ),
                ],
              ),
            ElevatedButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Add Photo/Video"),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text("Post", style: TextStyle(color: Colors.black)),
                  ),
          ],
        ),
      ),
    );
  }
}
