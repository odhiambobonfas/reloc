import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/constants/app_colors.dart';

const String apiBaseUrl = "http://192.168.100.76:5000/api";

class PostDialog extends StatefulWidget {
  final VoidCallback onPostCreated;
  const PostDialog({super.key, required this.onPostCreated});

  @override
  State<PostDialog> createState() => _PostDialogState();
}

class _PostDialogState extends State<PostDialog> {
  final TextEditingController _controller = TextEditingController();
  File? _mediaFile;
  bool _isVideo = false;
  bool _isLoading = false;
  final ImagePicker _picker = ImagePicker();
  String? _authorName;

  @override
  void initState() {
    super.initState();
    _fetchUserName();
  }

  Future<void> _fetchUserName() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      setState(() {
        _authorName = (doc.exists
            ? (doc.data()?['fullName'] ?? user.displayName ?? "Anonymous")
            : (user.displayName ?? "Anonymous"));
      });
    }
  }

  Future<void> _pickMedia() async {
    final choice = await showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Select Media"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, 'photo'),
              child: const Text("Photo")),
          TextButton(
              onPressed: () => Navigator.pop(context, 'video'),
              child: const Text("Video")),
        ],
      ),
    );
    if (choice == null) return;
    final pickedFile = choice == 'photo'
        ? await _picker.pickImage(source: ImageSource.gallery)
        : await _picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        _isVideo = choice == 'video';
      });
    }
  }

  Future<void> _submitPost() async {
    if ((_controller.text.trim().isEmpty && _mediaFile == null) ||
        _authorName == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Add text or media to your post")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      var request =
          http.MultipartRequest('POST', Uri.parse('$apiBaseUrl/posts'));
      request.fields['content'] = _controller.text.trim();
      request.fields['author'] = _authorName!;
      request.fields['is_video'] = _isVideo.toString();
      if (_mediaFile != null) {
        request.files.add(
            await http.MultipartFile.fromPath('media', _mediaFile!.path));
      }
      final response = await request.send();
      if (response.statusCode == 200) {
        widget.onPostCreated();
        Navigator.pop(context);
      } else {
        throw Exception("Failed to create post");
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.navBar,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Posting as: ${_authorName ?? 'Loading...'}",
                style: const TextStyle(color: AppColors.primary)),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              maxLines: 4,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: "What's on your mind?",
                hintStyle: TextStyle(color: Colors.white54),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (_mediaFile != null)
              Column(children: [
                _isVideo
                    ? const Icon(Icons.videocam, color: Colors.white, size: 50)
                    : Image.file(_mediaFile!, height: 150),
                IconButton(
                    onPressed: () => setState(() => _mediaFile = null),
                    icon: const Icon(Icons.delete, color: Colors.red))
              ]),
            ElevatedButton.icon(
              onPressed: _pickMedia,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text("Add Photo/Video"),
              style:
                  ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            ),
            const SizedBox(height: 12),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submitPost,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary),
                    child: const Text("Post",
                        style: TextStyle(color: Colors.black)),
                  )
          ]),
        ),
      ),
    );
  }
}
