// lib/screens/search_result.dart
import 'package:ai_shopping_chatbot/services/tts_service.dart';
import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'shoppingbag_screen.dart';
import 'login_screen.dart';

class SearchResult extends StatefulWidget {
  final String searchQuery;
  final List<Map<String, dynamic>> products;
  final List<String>? ttsMessages;

  const SearchResult({
    Key? key,
    required this.searchQuery,
    required this.products,
    this.ttsMessages,
  }) : super(key: key);

  @override
  State<SearchResult> createState() => _SearchResultState();
}

class _SearchResultState extends State<SearchResult> {
  @override
  void initState() {
    super.initState();
    _speakBufferedMessages();
  }

  Future<void> _speakBufferedMessages() async {
    final tts = TtsService();
    for (final text in widget.ttsMessages ?? []) {
      await tts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("'${widget.searchQuery}' 검색 결과"),
        backgroundColor: const Color(0xFFD0F8E4),
      ),
      body:
          widget.products.isEmpty
              ? const Center(
                child: Text("검색 결과가 없습니다.", style: TextStyle(fontSize: 18)),
              )
              : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: widget.products.length,
                itemBuilder: (_, idx) {
                  final item = widget.products[idx];
                  final rawUrl = item['image'] as String?;
                  String? imageUrl;
                  if (rawUrl != null && rawUrl.isNotEmpty) {
                    if (rawUrl.startsWith('//')) {
                      imageUrl = 'https:$rawUrl';
                    } else if (rawUrl.startsWith('http://') ||
                        rawUrl.startsWith('https://')) {
                      imageUrl = rawUrl;
                    } else {
                      imageUrl = 'https://$rawUrl';
                    }
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                    child: ListTile(
                      leading:
                          imageUrl != null
                              ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(
                                  imageUrl,
                                  width: 60,
                                  height: 60,
                                  fit: BoxFit.cover,
                                  errorBuilder:
                                      (_, __, ___) =>
                                          const Icon(Icons.broken_image),
                                ),
                              )
                              : const Icon(Icons.image_not_supported, size: 60),
                      title: Text(item['name'] ?? ''),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("💰 가격: ${item['price']}원"),
                          Text("⭐ 리뷰: ${item['review']}점"),
                        ],
                      ),
                    ),
                  );
                },
              ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        onTap: (i) {
          if (i == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => ShoppingBagScreen(
                      updateNavigationBar: (_) => setState(() {}),
                      userName: '',
                    ),
              ),
            );
          } else if (i == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen(userName: '')),
            );
          } else if (i == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: '장바구니',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
        ],
      ),
    );
  }
}
