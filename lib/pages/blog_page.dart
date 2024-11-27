import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class BloggerPostsPage extends StatefulWidget {
  @override
  _BloggerPostsPageState createState() => _BloggerPostsPageState();
}

class _BloggerPostsPageState extends State<BloggerPostsPage> {
  List posts = [];

  @override
  void initState() {
    super.initState();
    fetchPosts();
  }

  Future<void> fetchPosts() async {
    // API Anahtarı ve Blog ID'si .env dosyasından alınıyor
    final String? apiKey = dotenv.env['API_KEY'];
    final String? blogId = dotenv.env['BLOG_ID'];

    if (apiKey == null || blogId == null) {
      print("API_KEY veya BLOG_ID tanımlı değil.");
      return;
    }

    final url =
        'https://www.googleapis.com/blogger/v3/blogs/$blogId/posts?key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          posts = data['items'] ?? [];
        });
      } else {
        print('Failed to load posts: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching posts: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blogger Postları"),
      ),
      body: posts.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return Card(
                  child: ListTile(
                    title: Text(post['title'] ?? 'No Title'),
                    subtitle: Text(post['published'] ?? 'No Date'),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PostDetailPage(
                            title: post['title'] ?? 'No Title',
                            content: post['content'] ?? 'No Content',
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;

  PostDetailPage({required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Text(content),
      ),
    );
  }
}
