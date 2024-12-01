import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';

class BloggerPostsPage extends StatefulWidget {
  const BloggerPostsPage({super.key});

  @override
  _BloggerPostsPageState createState() => _BloggerPostsPageState();
}

class _BloggerPostsPageState extends State<BloggerPostsPage> {
  List posts = [];
  List filteredPosts = [];
  TextEditingController searchController = TextEditingController();
  bool isSearchActive = false; // Arama çubuğu durumu
  String selectedCategory = "Hepsi"; // Varsayılan kategori

  @override
  void initState() {
    super.initState();
    fetchPosts();
    searchController.addListener(() {
      filterPosts();
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPosts() async {
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
          filteredPosts = posts; // Tüm gönderiler başlangıçta gösterilir
        });
      } else {
        print('Sayfalar yüklenemedi: ${response.statusCode}');
      }
    } catch (e) {
      print('Yayınlar yüklenirken hata oluştu: $e');
    }
  }

  void filterPosts() {
    setState(() {
      filteredPosts = posts.where((post) {
        final title = post['title']?.toLowerCase() ?? '';
        final query = searchController.text.toLowerCase();
        final labels = List<String>.from(post['labels'] ?? []);
        return (title.contains(query)) &&
            (selectedCategory == "Hepsi" || labels.contains(selectedCategory));
      }).toList();
    });
  }

  Set<String> extractTags() {
    final tags = <String>{"Hepsi"}; // "Hepsi" etiketi ekleniyor
    for (var post in posts) {
      if (post['labels'] != null) {
        tags.addAll(List<String>.from(post['labels']));
      }
    }
    return tags;
  }

  void filterByCategory(String category) {
    setState(() {
      selectedCategory = category;
      filterPosts(); // Kategori seçimiyle filtreleme yap
    });
  }

  @override
  Widget build(BuildContext context) {
    final tags = extractTags();
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                width: isSearchActive ? MediaQuery.of(context).size.width - 100 : 0,
                child: isSearchActive
                    ? TextField(
                  controller: searchController,
                  decoration: const InputDecoration(
                    hintText: 'Ara...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 8),
                  ),
                  autofocus: true,
                )
                    : null,
              )
            ),
            IconButton(
              icon: Icon(isSearchActive ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (isSearchActive) {
                    searchController.clear();
                    filteredPosts = posts;
                  }
                  isSearchActive = !isSearchActive;
                });
              },
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.menu), // Hamburger menü ikonu
              onSelected: (String value) {
                filterByCategory(value);
              },
              itemBuilder: (BuildContext context) {
                return tags.map((String tag) {
                  return PopupMenuItem<String>(
                    value: tag,
                    child: Row(
                      children: [
                        Icon(
                          tag == "Hepsi" ? Icons.all_inclusive : Icons.label,
                          color: tag == selectedCategory
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          tag,
                          style: TextStyle(
                            fontWeight: tag == selectedCategory
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: tag == selectedCategory
                                ? Colors.blue
                                : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList();
              },
            ),
          ],
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.greenAccent],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: filteredPosts.isEmpty
                ? (searchController.text.isNotEmpty ||
                        selectedCategory != "Hepsi"
                    ? const Center(
                        child: Text(
                          "Sonuç bulunamadı.",
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      )
                    : const Center(child: CircularProgressIndicator()))
                : ListView.builder(
                    itemCount: filteredPosts.length,
                    itemBuilder: (context, index) {
                      final post = filteredPosts[index];
                      return Card(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 5,
                        child: ListTile(
                          title: Text(post['title'] ?? 'Başlık Yok'),
                          subtitle: Text(
                            DateFormat('dd MMM yyyy').format(
                              DateTime.parse(post['published']),
                            ),
                          ),
                          trailing: const Icon(Icons.arrow_forward),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PostDetailPage(
                                  title: post['title'] ?? 'Başlık Yok',
                                  content: post['content'] ?? 'İçerik Yok',
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class PostDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const PostDetailPage({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Html(
          data: content,
          style: {
            "img": Style(
              display: Display.block,
              width:
                  Width(MediaQuery.of(context).size.width * 0.8, Unit.percent),
            ),
            "*": Style(
              margin: Margins.symmetric(vertical: 3, horizontal: 0),
              padding: HtmlPaddings.zero,
              fontSize: FontSize(16),
              lineHeight: const LineHeight(1.5),
            ),
          },
        ),
      ),
    );
  }
}
