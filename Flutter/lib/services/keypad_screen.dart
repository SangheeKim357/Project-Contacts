import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../pages/contact_add_page.dart';
import '../pages/contact_list_page.dart';
import '../screens/favorites_screen.dart';
import '../screens/groups_screen.dart';
import '../controllers/dialer_controller.dart';
import '../widgets/keypad.dart';

class KeypadScreen extends StatelessWidget {
  const KeypadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => DialerController(),
      child: const _KeypadScreenBody(),
    );
  }
}

class _KeypadScreenBody extends StatefulWidget {
  const _KeypadScreenBody();

  @override
  State<_KeypadScreenBody> createState() => _KeypadScreenBodyState();
}

class _KeypadScreenBodyState extends State<_KeypadScreenBody> {
  int _selectedIndex = 2; // 현재 키패드 탭

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContactListPage()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritesScreen()),
        );
        break;
      case 2:
        // 현재 페이지: 키패드 → 아무 동작 안함
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GroupsScreen()),
        );
        break;
      case 4:
        // '더보기' 화면으로 이동 (추후 구현)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dialerController = Provider.of<DialerController>(context);

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 60),

          // ✅ + 버튼 - 오른쪽 위 고정 + 패딩 추가
          if (dialerController.rawPhoneNumber.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 16), // ← 여기서 좌우 여백 조정
              child: Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => ContactAddPage(
                              initialPhone: dialerController.rawPhoneNumber,
                            ),
                      ),
                    );
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.blue,
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ),

          /// ✅ 전화번호 텍스트 + +버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Stack(
              children: [
                // ✅ 전화번호 텍스트 - 중앙 정렬
                Center(
                  child: Text(
                    dialerController.formattedPhoneNumber,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 80),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Keypad(),
          ),
        ],
      ),

      // ✅ 하단 바는 그대로 유지
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: '연락처'),
          BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
          BottomNavigationBarItem(icon: Icon(Icons.dialpad), label: '키패드'),
          BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹'),
          BottomNavigationBarItem(icon: Icon(Icons.more_vert), label: '더보기'),
        ],
      ),
    );
  }
}
