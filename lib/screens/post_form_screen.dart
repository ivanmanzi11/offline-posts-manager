import 'package:flutter/material.dart';
import '../models/post.dart';
import '../database/database_helper.dart';

class PostFormScreen extends StatefulWidget {
  final Post? post;

  const PostFormScreen({super.key, this.post});

  @override
  State<PostFormScreen> createState() => _PostFormScreenState();
}

class _PostFormScreenState extends State<PostFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final dbHelper = DatabaseHelper.instance;

  late TextEditingController titleController;
  late TextEditingController bodyController;
  late TextEditingController userIdController;

  bool isLoading = false;

  bool get isEditing => widget.post != null;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.post?.title ?? '');
    bodyController = TextEditingController(text: widget.post?.body ?? '');
    userIdController =
        TextEditingController(text: widget.post?.userId.toString() ?? '1');
  }

  Future<void> submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    final post = Post(
      id: widget.post?.id ?? DateTime.now().millisecondsSinceEpoch,
      userId: int.tryParse(userIdController.text) ?? 1,
      title: titleController.text.trim(),
      body: bodyController.text.trim(),
    );

    try {
      if (isEditing) {
        await dbHelper.updatePost(post);
      } else {
        await dbHelper.insertPost(post);
      }

      Navigator.pop(context, post);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.blue[100],

    appBar: AppBar(
      backgroundColor: Colors.blue,
      elevation: 2,
      centerTitle: true,
      iconTheme: const IconThemeData(color: Colors.white),
      title: Text(
        isEditing ? 'Edit Post' : 'Create Post',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    ),

    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            /// 🔹 TITLE
            const Text(
              "Post Information",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),

            const SizedBox(height: 12),

            /// 🧾 CARD
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [

                    /// USER ID
                    TextFormField(
                      controller: userIdController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'User ID',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter user ID';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// TITLE
                    TextFormField(
                      controller: titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        prefixIcon: const Icon(Icons.title),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter title';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    /// BODY
                    TextFormField(
                      controller: bodyController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: 'Body',
                        prefixIcon: const Icon(Icons.description),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter body';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            /// 🔵 BUTTON
            isLoading
                ? const Center(child: CircularProgressIndicator())
                : Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 30,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: submitForm,
                      child: Text(
                        isEditing ? 'Update Post' : 'Create Post',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    ),
  );
}
}