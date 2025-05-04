import 'package:flutter/material.dart';
import 'main_screen.dart'; // HomeScreen import

class ShoppingBagScreen extends StatefulWidget {
  final void Function(int) updateNavigationBar;

  const ShoppingBagScreen({
    Key? key,
    required this.updateNavigationBar,
    required String userName,
  }) : super(key: key);

  @override
  State<ShoppingBagScreen> createState() => _ShoppingBagScreenState();
}

class _ShoppingBagScreenState extends State<ShoppingBagScreen> {
  int _selectedTabIndex = 0; // 0: 전체, 1: 자주산상품

  void _onTabSelected(int index) {
    setState(() {
      _selectedTabIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('장바구니', style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // 상단 탭 바 (좌우 반반)
          Container(
            color: Colors.white,
            child: Row(
              children: [
                _expandedTabButton('전체', 0),
                _expandedTabButton('자주산상품', 1),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Colors.grey),

          // 빈 상태 메시지
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: screenWidth * 0.3,
                    height: screenWidth * 0.3,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.sentiment_dissatisfied,
                        color: Colors.white,
                        size: 50,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    '장바구니에 담긴 상품이 없습니다.',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: () {
                      widget.updateNavigationBar(1);
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HomeScreen(userName: ''),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                    ),
                    child: const Text(
                      '홈으로 가기',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // 좌우 반반 탭 버튼 (배경은 흰색, 텍스트 색상만 변화)
  Widget _expandedTabButton(String label, int index) {
    final bool isSelected = _selectedTabIndex == index;

    return Expanded(
      child: GestureDetector(
        onTap: () => _onTabSelected(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          color: Colors.white, // 항상 흰색 배경
          child: Center(
            child: Text(
              '$label 0',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.green[700] : Colors.black,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
