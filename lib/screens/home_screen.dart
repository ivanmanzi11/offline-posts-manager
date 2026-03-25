import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../models/post.dart';
import '../widgets/post_card.dart';
import 'post_detail_screen.dart';
import 'post_form_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final dbHelper = DatabaseHelper.instance;

  List<Post> posts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadPosts();
  }

  Future<void> loadPosts() async {
    setState(() => isLoading = true);

    final data = await dbHelper.getPosts();

    setState(() {
      posts = data;
      isLoading = false;
    });
  }

  Future<void> deletePost(int id) async {
    await dbHelper.deletePost(id);
    loadPosts();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Post deleted"),
      ),
    );
  }

  /// 🔹 CREATE POST
  void goToCreateScreen() async {
    final newPost = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const PostFormScreen()),
    );

    if (newPost != null) {
      loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The post is created successfully"),
        ),
      );
    }
  }

  /// 🔹 EDIT POST
  void goToEditScreen(Post post) async {
    final updatedPost = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostFormScreen(post: post),
      ),
    );

    if (updatedPost != null) {
      loadPosts();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("The post is edited successfully"),
        ),
      );
    }
  }

  /// 🔹 VIEW DETAILS
  void goToDetailScreen(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PostDetailScreen(post: post),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[100],

      /// 🔵 CLEAN APPBAR (NO LOGOUT)
      appBar: AppBar(
        backgroundColor: Colors.blue,
        centerTitle: true,
        elevation: 2,
        title: const Text(
          "Posts Manager",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      /// 📜 BODY
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : posts.isEmpty
              ? const Center(
                  child: Text(
                    "No posts yet",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.only(top: 8, bottom: 80),
                  itemCount: posts.length,
                  itemBuilder: (context, index) {
                    final post = posts[index];
                    return PostCard(
                      post: post,
                      onTap: () => goToDetailScreen(post),
                      onEdit: () => goToEditScreen(post),
                      onDelete: () => deletePost(post.id!),
                    );
                  },
                ),

      /// ➕ BUTTON
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue,
        elevation: 4,
        onPressed: goToCreateScreen,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Post",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}