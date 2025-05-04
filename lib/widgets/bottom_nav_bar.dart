import 'package:ai_shopping_chatbot/screens/main_screen.dart';
import 'package:flutter/material.dart';
import '../screens/login_screen.dart';
import '../screens/shoppingbag_screen.dart';

class BottomNavBar extends StatelessWidget {
  final int selectedIndex;
  final String userName; // ✅ 추가: 현재 로그인한 유저 이름
  final Function(int)? onTabSelected;

  const BottomNavBar({
    Key? key,
    required this.selectedIndex,
    required this.userName, // ✅ 추가
    this.onTabSelected,
  }) : super(key: key);

  void _defaultOnTap(BuildContext context, int index) {
    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  ShoppingBagScreen(updateNavigationBar: (_) {}, userName: ''),
        ),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomeScreen(userName: userName), // ✅ 넘겨야 한다
        ),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: selectedIndex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.grey,
      onTap: (index) {
        if (onTabSelected != null) {
          onTabSelected!(index);
        } else {
          _defaultOnTap(context, index);
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.shopping_bag), label: '장바구니'),
        BottomNavigationBarItem(icon: Icon(Icons.home), label: '홈'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: '내 정보'),
      ],
    );
  }
}
