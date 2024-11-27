import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

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
        print('Sayfalar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Yayınlar yüklenirken hata oluştu: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Blog"),
        centerTitle: true,
    flexibleSpace: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.greenAccent],
        ),
      ),
    ),
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
                    subtitle: Text(
                      DateFormat('dd MMM yyyy').format(DateTime.parse(post['published'])),
                    ),
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
        child: Html(
            data: content,
          style: {

            // Varsayılan olarak tüm stil özelliklerini sıfırlama
            "*": Style(
              margin: Margins.zero, // Tüm margin değerlerini sıfırla
              padding: HtmlPaddings.zero, // Tüm padding değerlerini sıfırla
              fontSize: FontSize(16), // Varsayılan font boyutu
              lineHeight: LineHeight(1.5), // Varsayılan satır yüksekliği
            ),
            // Özel etiketler için margin/padding
            "h2": Style(
              margin: Margins.only(bottom: 12), // Başlıkların altına biraz boşluk bırak
              fontSize: FontSize.large, // Büyük font boyutu
              color: Colors.red, // Kırmızı renk
            ),
            "p": Style(
              margin: Margins.only(bottom: 8), // Paragraflar arasına az boşluk bırak
              fontSize: FontSize(14), // Daha küçük font boyutu
              color: Colors.black,
            ),
            "div": Style(
              alignment: Alignment.center, // Resmi kapsayan divleri ortala
            ),
          },
        ),
      ),
    );
  }
}
