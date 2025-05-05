// lib/screens/home_screen.dart

import 'package:ai_shopping_chatbot/widgets/GlobalSttTtsWrapper.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'shoppingbag_screen.dart';
import 'search_result.dart';
import 'my_page_screen.dart';

class HomeScreen extends StatefulWidget {
  final String userName;
  const HomeScreen({Key? key, required this.userName}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 1;
  String searchQuery = "";

  void _onItemTapped(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (_) => ShoppingBagScreen(
                  updateNavigationBar:
                      (i) => setState(() => _selectedIndex = i),
                  userName: widget.userName,
                ),
          ),
        );
        break;
      case 1:
        break; // 홈
      case 2:
        if (widget.userName.isEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MyPageScreen(userName: widget.userName),
            ),
          );
        }
        break;
    }
  }

  void _onSearch() {
    if (searchQuery.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SearchResult(searchQuery: searchQuery, products: const []),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 223, 223, 223),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 209, 209, 209),
        elevation: 0,
        leading: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.menu, color: Colors.black),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications, color: Colors.black),
          ),
        ],
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child:
              searchQuery.isEmpty
                  ? const SizedBox()
                  : Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(
                      "🔍 검색어: $searchQuery",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ★ 로봇 이미지만 탭하면 STT 시작
              GestureDetector(
                onTap: () {
                  GlobalSttTtsWrapper.of(context)?.startListening();
                },
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
                    // STT 오버레이는 전역 래퍼가 그려줍니다.
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // 텍스트 검색
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
                  onChanged: (v) => setState(() => searchQuery = v),
                  onSubmitted: (_) => _onSearch(),
                ),
              ),

              const SizedBox(height: 40),

              // 기존 카테고리 UI…
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
              // … 이하 생략 …
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

// CategoryIcon 위젯은 그대로
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
