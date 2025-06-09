import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../pages/contact_detail_page.dart';
import '../services/contact_service.dart';
import '../services/keypad_screen.dart';
import '../pages/search_controller.dart';

import '../services/contact_service.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';

import '../screens/favorites_screen.dart';
import '../screens/group_detail_screen.dart';
import '../screens/groups_screen.dart';
import '../screens/home_screen.dart';

// class ContactService {
//   // static const String _serverBaseUrl = 'http://10.0.2.2:8083';
//   // ContactService contactService = ContactService();

//   static Future<List<Contact>> fetchContacts() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$_serverBaseUrl/api/contacts'),
//       );
//       if (response.statusCode == 200) {
//         print("서버 응답 원본 바디 (fetchContacts): ${response.body}");
//         final List<dynamic> data = jsonDecode(response.body);
//         return data.map((json) => Contact.fromJson(json)).toList();
//       } else {
//         print("연락처 목록 불러오기 실패: ${response.statusCode}");
//         return [];
//       }
//     } catch (e) {
//       print("연락처 목록 불러오기 중 오류 발생: $e");
//       return [];
//     }
//   }

//   static Future<void> deleteContact(int id) async {
//     final response = await http.delete(
//       Uri.parse('$_serverBaseUrl/api/contacts/$id'),
//       headers: {'Content-Type': 'application/json'},
//     );
//     if (response.statusCode != 200) {
//       throw Exception('연락처 삭제 실패: ${response.statusCode}');
//     }
//   }
// }

Color getRandomColor({int opacity = 100}) {
  final Random random = Random();
  return Color.fromARGB(
    opacity, // 0~255 사이 값, 기본 100 (연한 투명도)
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

class ContactListPage extends StatefulWidget {
  // static const String _serverBaseUrl = 'http://192.168.0.73:8083';
  const ContactListPage({super.key}); // const 생성자 추가

  @override
  _ContactListPageState createState() => _ContactListPageState();
}

class _ContactListPageState extends State<ContactListPage> {
  late Future<List<Contact>> _contactsFuture;
  final ScrollController _scrollController = ScrollController();
  List<Contact> contacts = [];
  Map<String, List<Contact>> groupedMap = {};
  List<List<Contact>> grouped = [];

  bool _isFabVisible = true;

  int _selectedIndex = 0;

  bool _isEditingMode = false;
  Set<int> _selectedContactIds = {};

  // static Future<void> deleteContactsByIds(List<int> contactIds) async {
  //   print("deleteContactsByIds 호출됨"); // 호출 여부 확인용
  //   if (contactIds.isEmpty) {
  //     print('삭제할 연락처 ID가 없습니다.');
  //     return;
  //   }

  //   final uri = Uri.parse(
  //     '${ContactService._serverBaseUrl}/api/contacts/batch-delete',
  //   );
  //   try {
  //     print("다중삭제uri: $uri");
  //     final response = await http.post(
  //       uri,
  //       headers: {
  //         'Content-Type': 'application/json', // JSON 형식으로 데이터를 보냅니다.
  //       },
  //       body: jsonEncode({'ids': contactIds}), // ID 목록을 JSON 배열로 변환하여 바디에 담습니다.
  //     );

  //     // HTTP 상태 코드가 200번대(성공)가 아니면 예외를 발생시킵니다.
  //     if (response.statusCode < 200 || response.statusCode >= 300) {
  //       throw Exception('연락처 삭제 실패: ${response.statusCode} ${response.body}');
  //     }

  //     print('선택된 연락처 삭제 성공: ${contactIds.length}개');
  //   } catch (e) {
  //     print('연락처 삭제 중 오류 발생: $e');
  //     rethrow; // 호출한 곳에서 오류를 처리할 수 있도록 다시 던집니다.
  //   }
  // }

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _contactsFuture = ContactService.getAllContacts();

    _scrollController.addListener(() {
      if (!_isEditingMode) {
        if (_scrollController.offset > 150 && !_isFabVisible) {
          setState(() => _isFabVisible = true);
        } else if (_scrollController.offset <= 150 && _isFabVisible) {
          setState(() => _isFabVisible = false);
        }
      }
    });
  }

  void _onSaveOrDeleteSuccess() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder:
            (context) =>
                const ContactListPage(), // 이제 ContactListPage를 찾을 수 있습니다.
      ),
      (Route<dynamic> route) => false, // 모든 이전 라우트 제거
    );
  }

  // ✅ 연락처 데이터를 불러오는 전용 함수를 생성합니다.
  Future<void> _loadContacts() async {
    final fetchedContacts = await ContactService.getAllContacts();

    setState(() {
      contacts = fetchedContacts;
      groupedMap = groupContactsByInitial(fetchedContacts); // 정렬 및 그룹화
      grouped = groupedMap.values.toList(); // SliverList에 사용될 리스트
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  List<List<Contact>> _groupContacts(List<Contact> contacts, int groupSize) {
    List<List<Contact>> groups = [];
    for (int i = 0; i < contacts.length; i += groupSize) {
      int end =
          (i + groupSize < contacts.length) ? i + groupSize : contacts.length;
      groups.add(contacts.sublist(i, end));
    }
    return groups;
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    print('인덱스: $index');

    switch (index) {
      case 0:
        // Navigator.pushReplacement(
        //   context,
        //   MaterialPageRoute(builder: (context) => ContactListPage()),
        // );
        _loadContacts();
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => FavoritesScreen()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => GroupsScreen()),
        );
        break;
      case 2: // 키패드
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => KeypadScreen()),
        );
        break;
      case 4:
        _showMoreOptions(context);
        break;
    }
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.edit, color: Colors.blue),
                title: const Text(
                  '연락처 편집/삭제',
                  style: TextStyle(color: Colors.black),
                ),
                onTap: () {
                  Navigator.pop(context);
                  setState(() {
                    _isEditingMode = true;
                    _selectedContactIds.clear();
                    _isFabVisible = false;
                  });
                  debugPrint('연락처 편집/삭제 모드 진입');
                },
              ),
              // ListTile(
              //   leading: const Icon(Icons.settings),
              //   title: const Text('설정'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     debugPrint('설정으로 이동');
              //   },
              // ),
              // ListTile(
              //   leading: const Icon(Icons.info),
              //   title: const Text('앱 정보'),
              //   onTap: () {
              //     Navigator.pop(context);
              //     debugPrint('앱 정보 보기');
              //   },
              // ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Contact>>(
      future: _contactsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            body: Center(child: Text('오류 발생: ${snapshot.error}')),
          );
        }

        final contacts = snapshot.data ?? [];

        if (contacts.isEmpty) {
          return const Scaffold(body: Center(child: Text('표시할 연락처가 없습니다.')));
        }

        final grouped = _groupContacts(contacts, 5);

        return Scaffold(
          body: CustomScrollView(
            controller: _scrollController,
            slivers: [
              SliverAppBar(
                expandedHeight: 170,
                pinned: true,
                flexibleSpace: LayoutBuilder(
                  builder: (context, constraints) {
                    final top = constraints.biggest.height;
                    final isExpanded = top > kToolbarHeight + 50;
                    return Stack(
                      children: [
                        if (isExpanded)
                          Positioned(
                            top: 80,
                            left: 0,
                            right: 0,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Text(
                                  '전화',
                                  style: TextStyle(
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text('전화번호가 저장된 연락처 ${contacts.length}개'),
                              ],
                            ),
                          ),
                        // 이 코드가 Stack 위젯의 자식으로 들어가야 합니다.
                        if (!isExpanded)
                          Positioned(
                            left: 16,
                            right: 16,
                            bottom: 5,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  '전화',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (!_isEditingMode)
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.add),
                                        onPressed: () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                context,
                                                '/add',
                                              );
                                          if (result == true) {
                                            _loadContacts();
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.search),
                                        onPressed: () async {
                                          final result =
                                              await Navigator.pushNamed(
                                                context,
                                                '/search',
                                              );
                                          // result 처리 필요 시 여기서 사용 가능
                                        },
                                      ),
                                    ],
                                  ),
                              ],
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (!_isEditingMode) ...[
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/add',
                            );
                            if (result == true) {
                              _loadContacts();
                            }
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.search),
                          onPressed: () async {
                            final result = await Navigator.pushNamed(
                              context,
                              '/search',
                            );
                            // result 처리 필요 시 여기서 사용 가능
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              if (contacts.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.person_off, size: 60, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          '표시할 연락처가 없습니다.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        Text(
                          '새 연락처를 추가해 보세요.',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, groupIndex) {
                    final entry = groupedMap.entries.elementAt(groupIndex);
                    final initial = entry.key;
                    final group = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 초성 헤더
                        Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16.0,
                            vertical: 8.0,
                          ),
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey,
                            ),
                          ),
                        ),

                        // 연락처 목록
                        ...group.map((contact) {
                          String? displayImageUrl = contact.image;
                          if (displayImageUrl != null &&
                              displayImageUrl.isNotEmpty &&
                              !displayImageUrl.startsWith('http')) {
                            displayImageUrl =
                                '${ContactService.serverBaseUrl}$displayImageUrl';
                          }

                          return ListTile(
                            leading:
                                _isEditingMode
                                    ? Checkbox(
                                      value: _selectedContactIds.contains(
                                        contact.id,
                                      ),
                                      onChanged: (bool? isChecked) {
                                        setState(() {
                                          if (isChecked == true) {
                                            _selectedContactIds.add(
                                              contact.id!,
                                            );
                                          } else {
                                            _selectedContactIds.remove(
                                              contact.id!,
                                            );
                                          }
                                        });
                                      },
                                    )
                                    : CircleAvatar(
                                      backgroundColor: getRandomColor(
                                        opacity: 150,
                                      ),
                                      backgroundImage:
                                          (displayImageUrl != null &&
                                                  displayImageUrl.isNotEmpty)
                                              ? NetworkImage(displayImageUrl)
                                              : null,
                                      child:
                                          (displayImageUrl == null ||
                                                  displayImageUrl.isEmpty)
                                              ? Text(
                                                contact.name.isNotEmpty
                                                    ? contact.name[0]
                                                        .toUpperCase()
                                                    : '',
                                                style: const TextStyle(
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 20,
                                                ),
                                              )
                                              : null,
                                    ),
                            title: Text(
                              contact.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Row(
                              children: [
                                Text(
                                  _formatPhoneNumber(
                                    contact.phone ??
                                        contact.home ??
                                        contact.company,
                                  ),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                const Text(' • '),
                                Text(contact.group ?? '그룹 없음'),
                              ],
                            ),
                            trailing:
                                contact.favorite == true
                                    ? const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    )
                                    : null,
                            onTap: () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (context) =>
                                          ContactDetailPage(contact: contact),
                                ),
                              );

                              if (result == true) {
                                _loadContacts();
                              }
                            },
                          );
                        }).toList(),
                      ],
                    );
                  }, childCount: groupedMap.length),
                ),
            ],
          ),
          floatingActionButton:
              _isEditingMode
                  ? FloatingActionButton.extended(
                    onPressed: () async {
                      if (_selectedContactIds.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('삭제할 연락처를 선택해주세요.')),
                        );
                        return;
                      }

                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('연락처 삭제 확인'),
                              content: Text(
                                '${_selectedContactIds.length}개의 연락처를 정말로 삭제하시겠습니까?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('취소'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    '삭제',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                      );
                      // void _deleteSelectedContacts() async {
                      // bool confirm = true;

                      if (confirm == true) {
                        // ContactService.deleteContactsByIds는 ContactService에 정의되어 있어야 합니다.
                        print("테스트001");
                        await ContactService.deleteContactsByIds(
                          _selectedContactIds.toList(),
                        ); // << 여기를 수정!

                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('선택된 연락처가 삭제되었습니다.')),
                          );
                          setState(() {
                            _isEditingMode = false;
                            _selectedContactIds.clear();
                            _isFabVisible = true;
                          });
                          _loadContacts();
                        }
                        // }
                      }
                    },
                    backgroundColor: Colors.red.shade400,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.delete),
                    label: Text('선택 삭제 (${_selectedContactIds.length})'),
                  )
                  : null,
          // : Visibility(
          //   visible: _isFabVisible,
          //   child: FloatingActionButton(
          //     onPressed: () async {
          //       final result = await Navigator.pushNamed(
          //         context,
          //         '/add',
          //       );
          //       if (result == true) {
          //         setState(
          //           () =>
          //               _contactsFuture =
          //                   ContactService.fetchContacts(),
          //         );
          //       }
          //     },
          //     backgroundColor:
          //         Colors.purple[400], // 배경색 지정 (원하는 색으로 변경)
          //     foregroundColor: Colors.white,
          //     child: const Icon(Icons.add),
          //     tooltip: '연락처 등록',
          //   ),
          // ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _selectedIndex,
            selectedItemColor: Colors.purple[400],
            unselectedItemColor: Colors.grey,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.person), label: '연락처'),
              BottomNavigationBarItem(icon: Icon(Icons.star), label: '즐겨찾기'),
              BottomNavigationBarItem(icon: Icon(Icons.dialpad), label: '키패드'),
              BottomNavigationBarItem(icon: Icon(Icons.group), label: '그룹'),
              BottomNavigationBarItem(
                icon: Icon(Icons.more_vert),
                label: '더보기',
              ),
            ],
          ),
        );
      },
    );
  }

  void _openDetail(Contact contact) async {
    final bool? didUpdate = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ContactDetailPage(contact: contact)),
    );

    print('DetailPage에서 돌아옴, 수정 완료? $didUpdate');

    if (didUpdate == true && mounted) {
      print("DetailPage에서 true 받음, 리스트 새로고침");
      ContactService.getAllContacts();
    }
  }

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '번호 없음';
    }

    // 숫자만 남기고 모든 문자 제거
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return '번호 없음';
    }

    // 폰 번호 길이에 따라 포맷팅
    if (digitsOnly.length == 10) {
      // 예: 01012345678 (10자리) -> 010-1234-5678 (하지만 10자리는 보통 지역번호+7자리)
      // 01X-XXXX-XXXX 형태 (10자리)
      if (digitsOnly.startsWith('01')) {
        // 010, 011 등으로 시작하는 경우
        return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
      }
      // 지역번호+7자리 (예: 02-123-4567, 042-123-4567)
      else if (digitsOnly.startsWith('02')) {
        // 서울 지역번호
        return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
      } else {
        // 그 외 3자리 지역번호
        return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
      }
    } else if (digitsOnly.length == 11) {
      // 예: 01012345678
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
    } else if (digitsOnly.length == 9) {
      // 예: 021234567 (9자리)
      return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2, 5)}-${digitsOnly.substring(5)}';
    } else if (digitsOnly.length == 8) {
      // 0000-0000 (국번 없는 8자리)
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4)}';
    } else if (digitsOnly.length < 8) {
      // 8자리 미만은 그냥 반환
      return digitsOnly;
    }
    // 그 외의 경우 (예: 해외 전화번호, 너무 긴 번호 등)는 원본 반환
    return phoneNumber;
  }

  // 연락처 리스트를 초성 기준으로 그룹핑하고 정렬
  Map<String, List<Contact>> groupContactsByInitial(List<Contact> contacts) {
    Map<String, List<Contact>> grouped = {};

    for (var contact in contacts) {
      String initial = SearchStateController.getKoreanInitial(
        contact.name.trim(),
      );

      if (!grouped.containsKey(initial)) {
        grouped[initial] = [];
      }
      grouped[initial]!.add(contact);
    }

    // 각 그룹 내부의 연락처도 이름 기준으로 정렬
    grouped.forEach((key, value) {
      value.sort((a, b) => a.name.compareTo(b.name));
    });

    // 초성 키를 가나다 순으로 정렬
    final sortedKeys = grouped.keys.toList()..sort((a, b) => a.compareTo(b));

    // 정렬된 Map 반환
    final sortedMap = {for (var key in sortedKeys) key: grouped[key]!};

    return sortedMap;
  }
}
