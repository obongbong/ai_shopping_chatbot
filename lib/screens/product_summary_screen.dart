import 'package:flutter/material.dart';
import 'main_screen.dart';
import 'shoppingbag_screen.dart';
import 'login_screen.dart';

class ProductSummaryScreen extends StatefulWidget {
  const ProductSummaryScreen({super.key});

  @override
  State<ProductSummaryScreen> createState() => _ProductSummaryScreenState();
}

class _ProductSummaryScreenState extends State<ProductSummaryScreen> {
  int _selectedIndex = 1;
  String searchQuery = "";

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
                userName: '',
              ),
        ),
      );
    } else if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen(userName: '')),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    }
  }

  void _onSearch() {
    // TODO: 검색 기능 연결
    debugPrint('검색어: $searchQuery');
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFCFFFE5),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCFFFE5),
        elevation: 0,
        toolbarHeight: 80,
        title: Padding(
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: screenWidth * 0.4,
                height: screenWidth * 0.4,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: Icon(Icons.image, size: 60, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              '상품명: Apple 2024 에어팟 4세대',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ), // 폰트 크기 키움
            ),
            const SizedBox(height: 8),
            const Text('• 가격: 255,450원', style: TextStyle(fontSize: 30)),
            const Text('• 색상: 화이트', style: TextStyle(fontSize: 30)),
            const Text('• 주요 기능:', style: TextStyle(fontSize: 30)),
            const Text(
              '   • 액티브 노이즈 캔슬링 (ANC): 주변 소음 차단',
              style: TextStyle(fontSize: 28),
            ),
            const Text(
              '   • 적응형 투명 모드: 환경 소리를 자연스럽게 전달',
              style: TextStyle(fontSize: 28),
            ),
            const Text('   • 고품질 블루투스 연결', style: TextStyle(fontSize: 28)),
          ],
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
