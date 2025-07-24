import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

const String apiBaseUrl = "http://192.168.100.76:5000/api"; // ✅ Node.js API

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
        final doc =
            await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

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
    } catch (e) {
      setState(() => _authorName = "Anonymous");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('⚠️ Could not fetch user name: $e')),
      );
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
              setState(() {});
            });
        }
      });
    }
  }

  /// ✅ Submit Post to Node.js API (PostgreSQL + Uploads)
  Future<void> _submitPost() async {
    final content = _controller.text.trim();
    if ((content.isEmpty && _mediaFile == null) || _authorName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add text or media, and ensure you are logged in')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/posts'));
      request.fields['content'] = content;
      request.fields['author'] = _authorName!; // ✅ Real logged-in user name
      request.fields['is_video'] = _isVideo.toString();
      request.fields['type'] = _selectedPostType;

      if (_mediaFile != null) {
        request.files.add(await http.MultipartFile.fromPath('media', _mediaFile!.path));
      }

      final response = await request.send();
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Post created successfully!')),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Failed to post! Code: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
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
                backgroundColor: AppColors.primary.withOpacity(0.8),
                foregroundColor: Colors.black,
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
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
