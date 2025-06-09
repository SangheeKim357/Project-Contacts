// lib/screens/groups_screen.dart
import 'package:flutter/material.dart';
import '../pages/search_screen.dart';
import 'package:provider/provider.dart';
import '../providers/group_provider.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/group_card.dart';
import 'group_detail_screen.dart';
import '../models/group.dart';

// 다른 화면 임포트 (하단 내비게이션 바 이동을 위해 필요)
import '../pages/contact_list_page.dart';
import '../screens/favorites_screen.dart';
import '../services/keypad_screen.dart';
// import 'package:flutter_teampjtsample01/screens/more_screen.dart'; // 더보기 화면 (필요 시 추가)

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final TextEditingController _groupNameController = TextEditingController();
  int _selectedIndex =
      3; // 그룹 탭이므로 초기 선택 인덱스를 3으로 설정합니다. (연락처:0, 즐겨찾기:1, 키패드:2, 그룹:3...)

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<GroupProvider>(context, listen: false).fetchGroups();
    });
  }

  @override
  void dispose() {
    _groupNameController.dispose();
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
      case 1: // 즐겨찾기
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesScreen()),
        );
        break;
      case 2: // 키패드
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const KeypadScreen()),
        );
        break;
      case 3: // 그룹 (현재 페이지)
        // 현재 페이지이므로 아무 동작 안 함
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

  void _showRenameGroupDialog(BuildContext context, String oldName) {
    _groupNameController.text = oldName;
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('그룹 이름 변경'),
          content: TextField(
            controller: _groupNameController,
            decoration: const InputDecoration(hintText: '새 그룹 이름'),
          ),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('변경'),
              onPressed: () async {
                final newName = _groupNameController.text.trim();
                if (newName.isNotEmpty && newName != oldName) {
                  try {
                    await Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    ).renameGroup(oldName, newName);
                    Navigator.of(dialogContext).pop();
                    await Provider.of<GroupProvider>(
                      context,
                      listen: false,
                    ).fetchGroups();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('그룹 이름 변경 실패: ${e.toString()}')),
                    );
                  }
                } else {
                  Navigator.of(dialogContext).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  void _showDeleteGroupConfirmDialog(BuildContext context, String groupName) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('그룹 삭제'),
          content: Text('\'$groupName\' 그룹을 정말로 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다.'),
          actions: [
            TextButton(
              child: const Text('취소'),
              onPressed: () => Navigator.of(dialogContext).pop(),
            ),
            TextButton(
              child: const Text('삭제'),
              onPressed: () async {
                try {
                  await Provider.of<GroupProvider>(
                    context,
                    listen: false,
                  ).deleteGroup(groupName);
                  Navigator.of(dialogContext).pop();
                  await Provider.of<GroupProvider>(
                    context,
                    listen: false,
                  ).fetchGroups();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('그룹 삭제 실패: ${e.toString()}')),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: '그룹',
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/');
          },
        ),
      ),
      body: Consumer<GroupProvider>(
        builder: (context, groupProvider, child) {
          if (groupProvider.groups.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_off_rounded,
                    size: 80,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withOpacity(0.5),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '아직 생성된 그룹이 없습니다.',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '현재는 그룹 생성 기능이 없습니다. 추후 업데이트되면 관련 기능을 추가해야 합니다.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: groupProvider.groups.length,
            itemBuilder: (context, index) {
              final group = groupProvider.groups[index];
              return GroupCard(
                group: group,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => GroupDetailScreen(groupName: group.name),
                    ),
                  ).then((_) {
                    groupProvider.fetchGroups();
                  });
                },
                onRename: () => _showRenameGroupDialog(context, group.name),
                onDelete:
                    () => _showDeleteGroupConfirmDialog(context, group.name),
              );
            },
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
