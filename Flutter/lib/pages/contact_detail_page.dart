import 'package:share_plus/share_plus.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:intl/intl.dart'; // 날짜 형식을 위해 추가

// 프로젝트 내부 모델 및 서비스 파일 임포트 (경로를 실제 프로젝트에 맞게 수정)
import '../models/contact.dart'; // Contact 모델 파일 경로
import '../pages/contact_edit_page.dart';
import '../services/contact_service.dart';

// ContactDetailPage 내부 bottomNavigationBar 분리된 위젯

class ContactDetailBottomBar extends StatelessWidget {
  final Contact contact;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onEdit;
  final VoidCallback onShare;
  final VoidCallback onMore;

  const ContactDetailBottomBar({
    Key? key,
    required this.contact,
    required this.onFavoriteToggle,
    required this.onEdit,
    required this.onShare,
    required this.onMore,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color.fromARGB(255, 255, 255, 255),
      shape: const CircularNotchedRectangle(),
      child: SafeArea(
        child: SizedBox(
          // Container 대신 SizedBox 사용 (height 명시를 위해)
          height: 80,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildBottomBarIcon(
                icon:
                    (contact.favorite) // contact.favorite는 이제 bool이라고 가정
                        ? Icons.star
                        : Icons.star_border,
                label: '즐겨찾기',
                onTap: onFavoriteToggle,
                iconSize: 20,
              ),
              _buildBottomBarIcon(icon: Icons.edit, label: '편집', onTap: onEdit),
              _buildBottomBarIcon(
                icon: Icons.share,
                label: '공유',
                onTap: onShare,
              ),
              _buildBottomBarIcon(
                icon: Icons.more_vert,
                label: '더보기',
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('더보기 화면은 아직 구현되지 않았습니다.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // 하단 바의 아이콘과 텍스트를 꾸며주는 위젯 함수
  Widget _buildBottomBarIcon({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    double iconSize = 20,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: Colors.black, size: iconSize),
              const SizedBox(height: 6),
              Text(label, style: const TextStyle(color: Colors.black)),
            ],
          ),
        ),
      ),
    );
  }
}

// ContactDetailPage를 StatefulWidget으로 변경합니다.
class ContactDetailPage extends StatefulWidget {
  final Contact contact; // 초기 contact 객체는 id를 가져오기 위해 필요합니다.

  const ContactDetailPage({Key? key, required this.contact}) : super(key: key);

  @override
  _ContactDetailPageState createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  // 상태를 관리할 Contact 객체. 초기에는 null일 수 있습니다 (로딩 중).
  Contact? _currentContact;
  bool _isLoading = true; // 로딩 상태를 나타내는 플래그
  String? _errorMessage; // 오류 메시지 저장

  // 서버의 기본 URL을 정의합니다. (ContactService에 있는 것을 재활용해도 좋습니다)
  static const String _serverBaseUrl =
      'http://192.168.0.73:8083'; // 실제 서버 주소에 맞게 수정해주세요.

  @override
  void initState() {
    super.initState();
    // 페이지 로드 시 서버에서 최신 연락처 정보를 불러옵니다.
    _fetchContactDetails();
  }

  // ⭐ 서버에서 연락처 상세 정보를 불러오는 함수 ⭐
  Future<void> _fetchContactDetails() async {
    if (widget.contact.id == null) {
      setState(() {
        _isLoading = false;
        _errorMessage = '연락처 ID가 없습니다.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      print("테스트01");
      final fetchedContact = await ContactService.getContactById(
        widget.contact.id!,
      );
      if (mounted) {
        setState(() {
          _currentContact = fetchedContact;
          _isLoading = false;
        });
        print('불러온 연락처 데이터:');
        print('  모바일: ${_currentContact?.phone}');
        print('  집: ${_currentContact?.home}');
        print('  회사: ${_currentContact?.company}');
      }
    } catch (e) {
      debugPrint('연락처 상세 정보 로드 실패: $e');
      if (mounted) {
        setState(() {
          _errorMessage = '연락처 정보를 불러오는데 실패했습니다: $e';
          _isLoading = false;
        });
      }
    }
  }

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return '번호 없음';
    }

    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return '번호 없음';
    }

    if (digitsOnly.length == 10) {
      if (digitsOnly.startsWith('01')) {
        return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
      } else if (digitsOnly.startsWith('02')) {
        return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2, 6)}-${digitsOnly.substring(6)}';
      } else {
        return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 6)}-${digitsOnly.substring(6)}';
      }
    } else if (digitsOnly.length == 11) {
      return '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
    } else if (digitsOnly.length == 9) {
      return '${digitsOnly.substring(0, 2)}-${digitsOnly.substring(2, 5)}-${digitsOnly.substring(5)}';
    } else if (digitsOnly.length == 8) {
      return '${digitsOnly.substring(0, 4)}-${digitsOnly.substring(4)}';
    } else if (digitsOnly.length < 8) {
      return digitsOnly;
    }
    return phoneNumber;
  }

  // 즐겨찾기 상태를 토글하고 서버에 업데이트하는 함수
  Future<void> _toggleFavoriteStatus() async {
    if (_currentContact == null || _currentContact!.id == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('즐겨찾기 상태를 변경할 수 없습니다 (ID 없음).')),
        );
      }
      return;
    }

    final bool newFavoriteStatus = !(_currentContact!.favorite); // 현재 상태 반전

    try {
      // ContactService를 사용하여 서버에 즐겨찾기 상태 업데이트 요청
      // 이 요청이 성공하면 _currentContact를 업데이트하고 다시 빌드합니다.
      final updatedContact = await ContactService.updateContactFavorite(
        _currentContact!.id!,
        newFavoriteStatus,
      );

      // 서버 업데이트 성공 시, UI 상태 업데이트
      if (mounted) {
        setState(() {
          _currentContact = updatedContact; // 서버에서 반환된 최신 객체로 업데이트
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newFavoriteStatus ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.',
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint('즐겨찾기 상태 업데이트 실패: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('즐겨찾기 상태 변경에 실패했습니다.')));
      }
    }
  }

  /// 연락처 정보를 공유하는 함수
  void _shareContactInfo(Contact contact) {
    final info = '''
이름: ${contact.name}
휴대폰: ${contact.phone != null ? _formatPhoneNumber(contact.phone) : '없음'}
집: ${contact.home != null ? _formatPhoneNumber(contact.home) : '없음'}
회사: ${contact.company != null ? _formatPhoneNumber(contact.company) : '없음'}
이메일: ${contact.email ?? '없음'}
주소: ${contact.address ?? '없음'}
그룹: ${contact.group ?? '없음'}
생일: ${contact.birthday != null ? DateFormat('yyyy년 MM월 dd일').format(contact.birthday!) : '없음'}
''';
    Share.share(info);
  }

  /// 더보기 옵션(삭제)을 보여주는 바텀 시트
  void _showMoreOptions(BuildContext context) {
    if (_currentContact == null) return; // 데이터 로드 전에는 동작하지 않음

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('삭제', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context); // 바텀 시트 닫기

                  final confirm = await showDialog<bool>(
                    context: context,
                    builder:
                        (context) => AlertDialog(
                          title: const Text('삭제 확인'),
                          content: Text(
                            '${_currentContact!.name} 연락처를 삭제하시겠습니까?',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('취소'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('삭제'),
                            ),
                          ],
                        ),
                  );

                  if (confirm == true && _currentContact!.id != null) {
                    try {
                      await ContactService.deleteContact(_currentContact!.id!);
                      if (mounted) {
                        // Navigator.pop(context, true); // 목록 페이지에 갱신 필요 신호
                        Navigator.pop(context, {
                          'action': 'delete',
                          'success': true,
                          'name': _currentContact!.name,
                        });
                      }
                    } catch (e) {
                      debugPrint('삭제 중 오류 발생: $e');
                      if (mounted) {
                        // ScaffoldMessenger.of(context).showSnackBar(
                        //   SnackBar(content: Text('삭제 중 오류 발생: $e')),
                        // );
                        Navigator.pop(context, {
                          'action': 'delete',
                          'success': false,
                          'error': e.toString(),
                        });
                      }
                    }
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  /// 연락처 정보 한 줄을 꾸며주는 위젯 함수
  Widget _buildDetailRow(
    String label,
    String value,
    BoxDecoration decoration, {
    bool enableCall = false,
    bool enableSms = false,
    bool enableEmail = false,
  }) {
    // 전화/문자/이메일 액션에 사용할 원본 값
    String rawValueForAction = value;
    if (enableCall || enableSms) {
      rawValueForAction = value.replaceAll(RegExp(r'\D'), ''); // 숫자만 추출
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(15),
      width: double.infinity,
      decoration: decoration,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(value, style: const TextStyle(fontSize: 16)),
          ), // 표시용 값
          // 전화 아이콘
          if (enableCall)
            GestureDetector(
              onTap: () async {
                final Uri telUri = Uri(scheme: 'tel', path: rawValueForAction);
                if (await canLaunchUrl(telUri)) {
                  await launchUrl(telUri);
                } else {
                  debugPrint('전화 걸기 실패: $rawValueForAction');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('전화 걸기 기능을 사용할 수 없습니다.')),
                    );
                  }
                }
              },
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.green, width: 2),
                ),
                child: const Icon(Icons.phone, color: Colors.green, size: 18),
              ),
            ),

          // 문자 아이콘
          if (enableSms)
            GestureDetector(
              onTap: () async {
                final Uri smsUri = Uri(scheme: 'sms', path: rawValueForAction);
                if (await canLaunchUrl(smsUri)) {
                  await launchUrl(smsUri);
                } else {
                  debugPrint('문자 보내기 실패: $rawValueForAction');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('문자 보내기 기능을 사용할 수 없습니다.')),
                    );
                  }
                }
              },
              child: Container(
                width: 30,
                height: 30,
                margin: const EdgeInsets.only(right: 10),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.orange, width: 2),
                ),
                child: const Icon(
                  Icons.message,
                  color: Colors.orange,
                  size: 18,
                ),
              ),
            ),

          // 이메일 아이콘
          if (enableEmail)
            GestureDetector(
              onTap: () async {
                final Uri emailUri = Uri(
                  scheme: 'mailto',
                  path: rawValueForAction,
                );
                if (await canLaunchUrl(emailUri)) {
                  await launchUrl(emailUri);
                } else {
                  debugPrint('이메일 보내기 실패: $rawValueForAction');
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('이메일 보내기 기능을 사용할 수 없습니다.')),
                    );
                  }
                }
              },
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blue, width: 2),
                ),
                child: const Icon(Icons.email, color: Colors.blue, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 로딩 중이거나 오류가 발생한 경우 처리
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('연락처 상세')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('오류 발생')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _fetchContactDetails, // 다시 시도 버튼
                  child: const Text('다시 로드'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    Contact contact = _currentContact ?? widget.contact;

    final boxDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    );

    String? displayImageUrl = contact.image;

    if (displayImageUrl != null &&
        displayImageUrl.isNotEmpty &&
        !displayImageUrl.startsWith('http')) {
      displayImageUrl = '$_serverBaseUrl$displayImageUrl';
    }
    print("모바일, 집, 회사 ${contact.phone}, ${contact.home}, ${contact.company}");
    print('displayImageUrl: $displayImageUrl'); // Debug print

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, true); // 뒤로가기 눌렀을 때 true 반환
        return false; // 직접 pop 처리했으니 false 리턴
      },

      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
          // AppBar의 즐겨찾기 아이콘도 상태를 따르도록 변경
          // actions: [
          //   IconButton(
          //     icon: Icon(
          //       contact.favorite ? Icons.star : Icons.star_border,
          //       color: contact.favorite ? Colors.yellow[700] : null,
          //     ),
          //     onPressed: _toggleFavoriteStatus, // 즐겨찾기 토글 함수 연결
          //   ),
          // ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverSafeArea(
              sliver: SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    Row(
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          margin: const EdgeInsets.only(right: 20),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.grey[200],
                          ),
                          child: ClipOval(
                            child:
                                (displayImageUrl != null &&
                                        displayImageUrl.isNotEmpty)
                                    ? Image.network(
                                      displayImageUrl,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
                                            Icons.person,
                                            size: 50,
                                            color: Colors.grey[600],
                                          ),
                                      loadingBuilder: (
                                        context,
                                        child,
                                        loadingProgress,
                                      ) {
                                        if (loadingProgress == null)
                                          return child;
                                        return Center(
                                          child: CircularProgressIndicator(
                                            value:
                                                loadingProgress
                                                            .expectedTotalBytes !=
                                                        null
                                                    ? loadingProgress
                                                            .cumulativeBytesLoaded /
                                                        loadingProgress
                                                            .expectedTotalBytes!
                                                    : null,
                                          ),
                                        );
                                      },
                                    )
                                    : Icon(
                                      Icons.person,
                                      size: 50,
                                      color: Colors.grey[600],
                                    ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            contact.name, // contact 사용
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    if (contact.phone != null && contact.phone!.isNotEmpty)
                      _buildDetailRow(
                        '📞 모바일',
                        _formatPhoneNumber(contact.phone),
                        boxDecoration,
                        enableCall: true,
                        enableSms: true,
                      ),
                    if (contact.home != null && contact.home!.isNotEmpty)
                      _buildDetailRow(
                        '🏠 집',
                        _formatPhoneNumber(contact.home),
                        boxDecoration,
                        enableCall: true,
                      ),
                    if (contact.company != null && contact.company!.isNotEmpty)
                      _buildDetailRow(
                        '🏢 회사',
                        _formatPhoneNumber(contact.company),
                        boxDecoration,
                        enableCall: true,
                      ),
                    _buildDetailRow(
                      '📧 이메일',
                      contact.email ?? '이메일 정보 없음',
                      boxDecoration,
                      enableEmail: true,
                    ),
                    _buildDetailRow(
                      '👥 그룹',
                      contact.group ?? '그룹 없음',
                      boxDecoration,
                    ),
                    _buildDetailRow(
                      '🏡 주소',
                      contact.address ?? '주소 정보 없음',
                      boxDecoration,
                    ),
                    _buildDetailRow(
                      '🎂 생일',
                      contact.birthday != null
                          ? DateFormat(
                            'yyyy년 MM월 dd일',
                          ).format(contact.birthday!)
                          : '생일 정보 없음',
                      boxDecoration,
                    ),
                    _buildDetailRow(
                      '📝 메모',
                      contact.memo ?? '메모 없음',
                      boxDecoration,
                    ),
                    _buildDetailRow(
                      '⭐ 즐겨찾기',
                      contact.favorite ? "예" : "아니오", // contact 사용
                      boxDecoration,
                    ),
                    _buildDetailRow(
                      '📅 등록일',
                      contact.created != null
                          ? DateFormat(
                            'yyyy년 MM월 dd일 HH:mm',
                          ).format(contact.created!)
                          : '등록일 정보 없음',
                      boxDecoration,
                    ),
                    _buildDetailRow(
                      '🛠 수정일',
                      contact.updated != null
                          ? DateFormat(
                            'yyyy년 MM월 dd일 HH:mm',
                          ).format(contact.updated!)
                          : '수정일 정보 없음',
                      boxDecoration,
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: SizedBox(
          height: 80,
          child: ContactDetailBottomBar(
            contact: contact,
            onFavoriteToggle: _toggleFavoriteStatus,
            onEdit: () async {
              final bool? didUpdate = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ContactEditPage(contact: contact),
                ),
              );

              print('EditPage에서 돌아옴, 수정했나요? $didUpdate');

              if (didUpdate == true && mounted) {
                print("ContactEditPage에서 true 반환, ContactDetailPage 새로고침!");
                await _fetchContactDetails();
              } else {
                print("ContactEditPage에서 수정 없음 또는 취소.");
              }
            },
            onShare: () => _shareContactInfo(contact),
            onMore: () => _showMoreOptions(context),
          ),
        ),
      ),
    );
  }

  void _onBack() {
    Navigator.pop(context, true);
  }
}
