import 'package:flutter/material.dart';
import '../pages/contact_detail_page.dart';
import '../pages/contact_list_page.dart';
import 'package:provider/provider.dart';
import '../providers/favorite_provider.dart'; // FavoriteProvider 임포트
import '../widgets/custom_app_bar.dart';
import '../widgets/contact_card.dart'; // ContactCard 임포트 확인: 이 줄이 있어야 합니다!

// 다른 화면 임포트 (하단 내비게이션 바 이동을 위해 필요)
import '../services/keypad_screen.dart';
import '../screens/groups_screen.dart';
// import 'package:flutter_teampjtsample01/screens/more_screen.dart'; // 더보기 화면 (필요 시 추가)

// FavoritesScreen은 StatefulWidget이어야 합니다.
class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  int _selectedIndex =
      1; // 즐겨찾기 탭이므로 초기 선택 인덱스를 1로 설정합니다. (연락처:0, 즐겨찾기:1, 키패드:2...)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FavoriteProvider>(
        context,
        listen: false,
      ).fetchFavoriteContacts();
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  // 하단 내비게이션 바 탭을 눌렀을 때 호출될 메서드
  void _onItemTapped(int index) {
    if (index == _selectedIndex) return; // 같은 탭을 다시 누르면 아무것도 하지 않음

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // 연락처
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ContactListPage()),
        );
        break;
      case 1: // 즐겨찾기 (현재 페이지)
        // 현재 페이지이므로 아무 동작 안 함
        break;
      case 2: // 키패드
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KeypadScreen()),
        );
        break;
      case 3: // 그룹
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GroupsScreen()),
        );
        break;
      case 4: // 더보기 (추후 구현)
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => MoreScreen()),
        // );
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('더보기 화면은 아직 구현되지 않았습니다.')));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '즐겨찾기',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back), // 상수화
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/'); // ContactListPage로 이동
          },
        ),
      ),

      body: Consumer<FavoriteProvider>(
        builder: (context, favoriteProvider, child) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (favoriteProvider.favoriteContacts.isEmpty)
                Expanded(
                  child: InkWell(
                    onTap: () {
                      // 탭 로직
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('새로운 연락처를 추가해 즐겨찾기에 등록해보세요!'),
                        ),
                      );
                    },
                    splashColor: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.2), // 물결 효과 (약간의 지연 가능)
                    highlightColor: Theme.of(context).colorScheme.primary
                        .withOpacity(0.15), // ✅ 눌리자마자 바로 적용되는 배경색
                    borderRadius: BorderRadius.circular(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 80,
                          color: Theme.of(
                            context,
                          ).colorScheme.primary.withOpacity(0.7),
                        ),
                        const SizedBox(height: 20), // 상수화
                        Text(
                          '즐겨찾는 연락처가 없습니다.',
                          style: Theme.of(
                            context,
                          ).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.8),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10), // 상수화
                        Text(
                          '연락처를 길게 눌러 즐겨찾기에 추가해보세요.',
                          style: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.6),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.builder(
                    itemCount: favoriteProvider.favoriteContacts.length,
                    itemBuilder: (context, index) {
                      final contact = favoriteProvider.favoriteContacts[index];
                      return ContactCard(
                        contact: contact,
                        onTap: () async {
                          // 탭 확인용 로그 추가
                          print('Contact tapped: ${contact.name}');

                          // ContactDetailPage로 이동 (연락처 상세/편집 페이지)
                          final bool? result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => ContactDetailPage(
                                    contact: contact,
                                  ), // ContactDetailPage로 수정
                            ),
                          );

                          // 상세 페이지에서 변경사항이 있었다면 (true 반환)
                          if (result == true) {
                            // FavoriteProvider의 즐겨찾기 목록을 새로고침
                            await favoriteProvider.fetchFavoriteContacts();
                          }
                        },
                        onFavoriteToggled: () async {
                          // 즐겨찾기 아이콘 탭 시 즐겨찾기 목록 새로고침
                          await favoriteProvider.fetchFavoriteContacts();
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),

      // 🚨🚨🚨 추가된 하단 내비게이션 바 🚨🚨🚨
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
