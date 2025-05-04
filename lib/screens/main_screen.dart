import 'package:ai_shopping_chatbot/screens/my_page_screen.dart';
import 'package:flutter/material.dart';
import '../services/audio_service.dart';
import 'login_screen.dart';
import 'shoppingbag_screen.dart';
import 'search_result.dart';
import '../services/chat_service.dart';
import '../services/tts_service.dart';

class HomeScreen extends StatefulWidget {
  final String userName;

  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  String searchQuery = "";
  bool _isListening = false;
  final _audio = AudioService();

  @override
  void initState() {
    super.initState();

    _audio.speechStream.listen((recognizedText) async {
      final replies = await ChatService.sendRawMessage(recognizedText);

      String? product;
      String? intent;

      for (final r in replies) {
        final text = r['text'];
        if (text != null && text is String && text.trim().isNotEmpty) {
          debugPrint("[챗봇 응답] $text");
          await TtsService().speak(text);
        }

        if (r.containsKey('intent')) intent = r['intent'];
        if (r.containsKey('product')) product = r['product'];
      }

      if (intent == 'search_product' && product != null && mounted) {
        final products = await ChatService.fetchTopProductsFromFlask(product);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => SearchResult(
                  searchQuery: product!, // <- null 확인 후 강제 언래핑
                  products: products,
                ),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ShoppingBagScreen(
                updateNavigationBar: (selectedIndex) {
                  setState(() {
                    _selectedIndex = selectedIndex;
                  });
                },
                userName: widget.userName,
              ),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(userName: widget.userName),
        ),
      );
    } else if (index == 2) {
      if (widget.userName.isEmpty) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyPageScreen(userName: widget.userName),
          ),
        );
      }
    }
  }

  void _onSearch() {
    if (searchQuery.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => SearchResult(searchQuery: searchQuery, products: []),
        ),
      );
    }
  }

  void _toggleSTT() async {
    setState(() {
      _isListening = !_isListening;
    });

    if (_isListening) {
      await _audio.init();
      _audio.startListening();
    } else {
      _audio.stopListening();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 188, 247, 219),
      appBar: AppBar(
        backgroundColor: const Color(0xFFB2EBD0),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: StreamBuilder<String>(
            stream: _audio.speechStream,
            builder: (context, snapshot) {
              final recognized = snapshot.data ?? '';
              if (recognized.isEmpty) return const SizedBox();
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(
                  "🎤 인식된 텍스트: $recognized",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _toggleSTT,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width * 0.6,
                      height: MediaQuery.of(context).size.width * 0.6,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFE2FFF2),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/ai_chatbot_character.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (_isListening)
                      const Positioned(
                        bottom: 10,
                        child: Text(
                          '🎙 음성 인식 중...',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: '상품을 검색해 주세요.',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.arrow_forward),
                      onPressed: _onSearch,
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.all(12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      searchQuery = value;
                    });
                  },
                  onSubmitted: (value) {
                    _onSearch();
                  },
                ),
              ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    CategoryIcon(icon: Icons.tv, label: 'TV'),
                    CategoryIcon(icon: Icons.build, label: '공구'),
                    CategoryIcon(icon: Icons.weekend, label: '가구'),
                    CategoryIcon(icon: Icons.desktop_windows, label: '가전'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    CategoryIcon(icon: Icons.work, label: '가방'),
                    CategoryIcon(icon: Icons.fastfood, label: '패스트푸드'),
                    CategoryIcon(icon: Icons.local_pizza, label: '식품'),
                    CategoryIcon(icon: Icons.fitness_center, label: '운동'),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
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

class CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryIcon({Key? key, required this.icon, required this.label})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: Colors.black),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.black)),
      ],
    );
  }
}
