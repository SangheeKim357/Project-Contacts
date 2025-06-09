import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart'; // DateFormat을 위해 추가
import '../pages/contact_list_page.dart';

import 'package:provider/provider.dart'; // GroupProvider를 사용하기 위해 추가
import '../providers/group_provider.dart'; // GroupProvider 경로 확인
import '../widgets/group_selection_dialog.dart'; // GroupSelectionDialog 경로 확인

import '../services/contact_service.dart';
import '../models/contact.dart';

class ContactEditPage extends StatefulWidget {
  final Contact contact;

  const ContactEditPage({Key? key, required this.contact}) : super(key: key);

  @override
  _ContactEditPageState createState() => _ContactEditPageState();
}

class _ContactEditPageState extends State<ContactEditPage> {
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  String? _displayImageUrl;

  DateTime? _selectedBirthday;
  bool _showMoreFields = false;
  File? _selectedImage;
  final ImagePicker _picker = ImagePicker();

  late List<Map<String, dynamic>> _phoneFields;

  String _selectedStorage = '저장위치';

  @override
  void initState() {
    super.initState();

    _phoneFields = [];

    if (widget.contact.phone != null && widget.contact.phone!.isNotEmpty) {
      _phoneFields.add({
        'label': '모바일',
        'key': 'phone',
        'type': '모바일',
        'value': widget.contact.phone!,
      });
    }

    if (widget.contact.home != null && widget.contact.home!.isNotEmpty) {
      _phoneFields.add({
        'label': '집',
        'key': 'home',
        'type': '집',
        'value': _formatPhoneNumber(widget.contact.home),
      });
    }

    if (widget.contact.company != null && widget.contact.company!.isNotEmpty) {
      _phoneFields.add({
        'label': '회사',
        'key': 'company',
        'type': '회사',
        'value': _formatPhoneNumber(widget.contact.company),
      });
    }

    if (_phoneFields.isEmpty) {
      _phoneFields.add({
        'label': '모바일',
        'key': 'phone',
        'type': '모바일',
        'value': _formatPhoneNumber(widget.contact.phone),
      });
    }

    _formData = {
      'id': widget.contact.id,
      'name': widget.contact.name,
      'phone': null,
      'home': null,
      'company': null,
      'email': widget.contact.email,
      'group': widget.contact.group,
      'memo': widget.contact.memo,
      'address': widget.contact.address,
      'birthday': widget.contact.birthday,
      'favorite': widget.contact.favorite,
      'image': widget.contact.image,
    };
    _selectedBirthday = widget.contact.birthday;

    if (widget.contact.image != null && widget.contact.image!.isNotEmpty) {
      _displayImageUrl = 'http://192.168.0.73:8083${widget.contact.image}';
    }
  }

  void _submitForm() async {
    print('버튼이 눌렸습니다.');
    print('ID 확인: ${_formData['id']}');

    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      print('[디버그] 최종 formData 전송 전:');
      _formData.forEach((key, value) {
        if (!['phone', 'home', 'company'].contains(key)) {
          print('   $key: $value');
        }
      });

      _formData['phone'] = null;
      _formData['home'] = null;
      _formData['company'] = null;

      for (var field in _phoneFields) {
        if (field['value'] != null && (field['value'] as String).isNotEmpty) {
          if (field['type'] == '모바일') {
            _formData['phone'] = field['value'];
            print('[디버그] 최종 저장될 모바일 번호: ${_formData['phone']}');
          } else if (field['type'] == '집') {
            _formData['home'] = field['value'];
            print('[디버그] 최종 저장될 집 번호: ${_formData['home']}');
          } else if (field['type'] == '회사') {
            _formData['company'] = field['value'];
            print('[디버그] 최종 저장될 회사 번호: ${_formData['company']}');
          }
        }
      }

      print('[디버그] _phoneFields 처리 후 _formData 상태:');
      _formData.forEach((key, value) {
        print('   $key: $value');
      });

      // 1. 새 이미지가 선택되었다면 이미지 업로드
      if (_selectedImage != null) {
        try {
          final imageUrl = await ContactService.uploadImage(_selectedImage!);
          print('이미지경로앳서브밋: $imageUrl');
          print('셀렉티드이미지: ${_selectedImage}');
          print('_formData[image]: ${_formData['image']}');
          if (imageUrl != null) {
            _formData['image'] = imageUrl;
            setState(() {
              _displayImageUrl = imageUrl;
            });
          } else {
            print('마운티드: ${context.mounted}');
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('이미지 업로드에 실패했습니다.')));
            }
            return;
          }
        } catch (e) {
          print('이미지 업로드 중 에러: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('이미지 업로드 중 오류가 발생했습니다: $e')));
          }
          return;
        }
      } else if (_formData['image'] == null ||
          (_formData['image'] as String).isEmpty) {
        _formData['image'] = null;
      }

      // 2. _formData에 있는 birthday DateTime?을 String으로 변환하여 전송
      if (_selectedBirthday != null) {
        _formData['birthday'] = _selectedBirthday!.toIso8601String();
      } else {
        _formData['birthday'] = null;
      }
      _formData['favorite'] = _formData['favorite'] as bool? ?? false;

      try {
        // 3. ContactService를 통해 연락처 정보 업데이트
        print("업데이트 전달값: $_formData");
        final Contact contactToUpdate = Contact.fromJson(_formData);
        await ContactService.updateContact(contactToUpdate);

        setState(() {
          _selectedImage = null;
          _displayImageUrl = null;
        });

        if (context.mounted) {
          print("edit페이지에서 수정 완료 후 Detail페이지로 돌아가기 (true 반환)");
          Navigator.pop(context, true); // 수정 성공 신호를 이전 페이지(Detail)로 보냄
        }
      } catch (e) {
        print('연락처 저장/업데이트 중 오류 발생: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('연락처 저장/업데이트 실패: $e')));
          Navigator.pop(context, false);
        }
      }
    }
  }

  void _pickBirthday() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _displayImageUrl = pickedFile.path;
          print('[디버그] 선택한 이미지 경로: ${_selectedImage!.path}');
        });
      }
    } catch (e) {
      print("이미지 선택 중 오류 발생: $e");
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('이미지 선택 중 오류 발생: $e')));
      }
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _formData['image'] = null;
      _displayImageUrl = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.group),
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedStorage = value;
                });
              },
              itemBuilder:
                  (context) => [
                    const PopupMenuItem(
                      value: '로컬드라이브',
                      child: Row(
                        children: [
                          Icon(Icons.group),
                          SizedBox(width: 8),
                          Text('로컬드라이브'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: '클라우드',
                      child: Row(
                        children: [
                          Icon(Icons.cloud),
                          SizedBox(width: 8),
                          Text('클라우드'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'SD 카드',
                      child: Row(
                        children: [
                          Icon(Icons.sd_storage),
                          SizedBox(width: 8),
                          Text('SD 카드'),
                        ],
                      ),
                    ),
                  ],
              child: Row(
                children: [
                  Text(_selectedStorage, style: const TextStyle(fontSize: 18)),
                  const Icon(Icons.arrow_drop_down),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildRoundedField('name', '이름'),
              ..._phoneFields.map((field) => _buildPhoneField(field)).toList(),

              if (_phoneFields.length < 3)
                TextButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text('전화번호 추가'),
                  onPressed: () {
                    setState(() {
                      if (!_phoneFields.any((f) => f['type'] == '집')) {
                        _phoneFields.add({
                          'label': '집',
                          'key': 'home',
                          'type': '집',
                          'value': '',
                        });
                      } else if (!_phoneFields.any((f) => f['type'] == '회사')) {
                        _phoneFields.add({
                          'label': '회사',
                          'key': 'company',
                          'type': '회사',
                          'value': '',
                        });
                      }
                    });
                  },
                ),
              _buildRoundedField('email', '이메일'),
              _buildGroupField(), // <-- 그룹 필드 호출 변경

              if (_showMoreFields) ...[
                _buildRoundedField('address', '주소'),
                _buildRoundedField('memo', '메모'),
                const SizedBox(height: 10),
                _buildImagePreview(),

                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '생일: ${_selectedBirthday != null ? DateFormat('yyyy년 MM월 dd일').format(_selectedBirthday!) : '선택 안 함'}',
                      ),
                      TextButton(
                        onPressed: _pickBirthday,
                        child: const Text('날짜 선택'),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _formData['favorite'] as bool? ?? false,
                        onChanged: (val) {
                          setState(() {
                            _formData['favorite'] = val!;
                          });
                        },
                      ),
                      const Text('즐겨찾기'),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() => _showMoreFields = !_showMoreFields);
                },
                icon: Icon(
                  _showMoreFields ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(_showMoreFields ? '간략히' : '더보기'),
              ),

              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('취소'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm, // _saveChanges 대신 _submitForm 호출
                      child: const Text('저장'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('삭제 확인'),
                                content: const Text('이 연락처를 정말 삭제하시겠습니까?'),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text('취소'),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      '삭제',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (confirm == true) {
                          try {
                            if (widget.contact.id == null) {
                              // 이 부분은 이미 추가하셨을 가능성이 높지만, 안전을 위해 다시 강조합니다.
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('삭제할 연락처 ID가 유효하지 않습니다.'),
                                  ),
                                );
                              }
                              return;
                            }

                            await ContactService.deleteContact(
                              widget.contact.id!,
                            );

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('삭제가 완료되었습니다')),
                              );
                              Navigator.pushAndRemoveUntil(
                                // 스택에서 해당 페이지까지 제거하고 새 페이지 푸시
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ContactListPage(),
                                ),
                                (Route<dynamic> route) => false, // 모든 이전 라우트 제거
                              );
                              // Navigator.pop(context, true);
                            }
                          } catch (e) {
                            print('연락처 삭제 중 오류 발생: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('삭제 실패: ${e.toString()}'),
                                ),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('삭제'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(fontSize: 16),
                        backgroundColor: const Color(0xFFFFC0CB),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePreview() {
    final bool hasExistingImage =
        widget.contact.image != null && widget.contact.image!.isNotEmpty;
    final String existingImageUrl =
        'http://192.168.0.73:8083${widget.contact.image}';

    ImageProvider? currentImage;
    if (_selectedImage != null) {
      currentImage = FileImage(_selectedImage!);
    } else if (hasExistingImage &&
        (_formData['image'] == widget.contact.image)) {
      currentImage = NetworkImage(existingImageUrl);
    } else if (_displayImageUrl != null &&
        _displayImageUrl!.startsWith('http')) {
      currentImage = NetworkImage(_displayImageUrl!);
    } else if (_displayImageUrl != null &&
        _displayImageUrl!.startsWith('/data')) {
      currentImage = FileImage(File(_displayImageUrl!));
    }

    print('[디버그] _formData[image]: ${_formData['image']}');
    print('[디버그] _selectedImage: ${_selectedImage?.path}');
    print('[디버그] widget.contact.image: ${widget.contact.image}');
    print('[디버그] _displayImageUrl: ${_displayImageUrl}');

    if (currentImage != null) {
      print('[디버그] 이미지가 로드됨: ${currentImage.runtimeType}');
    } else {
      print('[디버그] 로드할 이미지 없음');
    }
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          currentImage != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image(
                  image: currentImage,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    );
                  },
                ),
              )
              : Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.image, color: Colors.grey),
              ),
          const SizedBox(width: 12),
          Expanded(
            child: Align(
              alignment: Alignment.centerRight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (currentImage != null)
                    TextButton(
                      onPressed: _clearImage,
                      child: const Text(
                        '이미지 삭제',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: _pickImage,
                    child: const Text('이미지 선택'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoundedField(String key, String label) {
    IconData? icon;
    switch (key) {
      case 'name':
        icon = Icons.person;
        break;
      case 'phone':
        icon = Icons.phone;
        break;
      case 'email':
        icon = Icons.email;
        break;
      case 'group': // 'group' 키는 이제 별도의 _buildGroupField에서 처리됩니다.
        icon = Icons.group;
        break;
      case 'address':
        icon = Icons.location_on;
        break;
      case 'memo':
        icon = Icons.note;
        break;
      case 'image':
        icon = Icons.image;
        break;
      default:
        icon = null;
    }

    if (key == 'group') {
      // 'group' 키는 여기서 처리하지 않고 _buildGroupField에서 처리
      return const SizedBox.shrink(); // 빈 위젯 반환
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        initialValue: _formData[key]?.toString(),
        keyboardType:
            ['phone', 'home', 'company'].contains(key)
                ? TextInputType.phone
                : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        onSaved: (val) {
          final cleaned = val?.replaceAll('-', ''); // 하이픈 제거

          if (key == 'name') {
            _formData[key] = val ?? '';
          } else if (['phone', 'home', 'company'].contains(key)) {
            _formData[key] = cleaned == '' ? null : cleaned;
          } else {
            _formData[key] = val == '' ? null : val;
          }
        },
        validator: (val) {
          final cleaned = val?.replaceAll('-', '') ?? '';
          final String type = _formData['type'] ?? '';

          // 정규식 정의
          final RegExp mobileRegExp = RegExp(r'^010[0-9]{7,8}$');
          final RegExp landlineRegExp = RegExp(r'^0(2|[3-6][0-5])[0-9]{7,8}$');
          final RegExp emailRegExp = RegExp(
            r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
          );

          // 📞 전화번호 유효성 검사
          if (type == '모바일') {
            if (cleaned.isEmpty) return '모바일 전화번호를 입력하세요';
            if (!mobileRegExp.hasMatch(cleaned)) {
              return '유효한 모바일 번호 형식이 아닙니다 (예: 01012345678)';
            }
          } else if (type == '집' || type == '회사') {
            if (cleaned.isEmpty) return '$type 전화번호를 입력하세요';
            if (!landlineRegExp.hasMatch(cleaned)) {
              return '유효한 $type 번호 형식이 아닙니다 (예: 0212345678, 0311234567)';
            }
          }

          // ✉️ 이메일 유효성 검사 (type이 'email'인 경우 또는 key 기반 분기도 가능)
          if (type == '이메일') {
            final email = val?.trim() ?? '';
            if (email.isEmpty) return '이메일을 입력하세요';
            if (!emailRegExp.hasMatch(email)) {
              return '유효한 이메일 형식이 아닙니다';
            }
          }

          return null;
        },
      ),
    );
  }

  Widget _buildPhoneField(Map<String, dynamic> phoneData) {
    final allowedTypes = ['모바일', '집', '회사'];

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          DropdownButton<String>(
            value:
                (phoneData['type'] != null &&
                        allowedTypes.contains(phoneData['type']))
                    ? phoneData['type']
                    : '모바일',
            items:
                allowedTypes.map((label) {
                  return DropdownMenuItem(value: label, child: Text(label));
                }).toList(),
            onChanged: (val) {
              setState(() {
                phoneData['type'] = val!;
              });
              print('타입버튼: ${val}');
            },
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextFormField(
              // controller: phoneData['type'] == '모바일' ? _phoneController : null,
              initialValue: phoneData['value'],
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                border: InputBorder.none,
                prefixIcon: Icon(Icons.phone),
              ),
              onChanged: (val) {
                phoneData['value'] = val;
              },
              onSaved: (val) {
                final cleaned = val?.replaceAll('-', ''); // 하이픈 제거 후 저장
                if (phoneData['type'] == '모바일') {
                  _formData['phone'] = cleaned == '' ? null : cleaned;
                } else if (phoneData['type'] == '집') {
                  _formData['home'] = cleaned == '' ? null : cleaned;
                } else if (phoneData['type'] == '회사') {
                  _formData['company'] = cleaned == '' ? null : cleaned;
                }
              },
              validator: (val) {
                final cleaned = val?.replaceAll('-', '') ?? '';
                final String type = phoneData['type'];

                final RegExp mobileRegExp = RegExp(r'^010[0-9]{7,8}$');
                final RegExp landlineRegExp = RegExp(
                  r'^0(2|[3-6][0-5])[0-9]{7,8}$',
                );

                if (type == '모바일') {
                  if (cleaned.isEmpty) {
                    return '모바일 전화번호를 입력하세요';
                  }
                  if (!mobileRegExp.hasMatch(cleaned)) {
                    return '유효한 모바일 번호 형식이 아닙니다 (예: 01012345678)';
                  }
                } else if (type == '집' || type == '회사') {
                  if (cleaned.isEmpty) {
                    return '${type} 전화번호를 입력하세요';
                  }
                  if (!landlineRegExp.hasMatch(cleaned)) {
                    return '유효한 ${type} 번호 형식이 아닙니다 (예: 0212345678, 0311234567)';
                  }
                }

                return null;
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: () {
              setState(() {
                _phoneFields.remove(phoneData);
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGroupField() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        // InkWell로 감싸서 탭 이벤트를 처리
        onTap: () async {
          final selectedGroup = await showDialog<String?>(
            context: context,
            builder: (BuildContext dialogContext) {
              return GroupSelectionDialog(
                initialGroup: _formData['group'],
              ); // 현재 그룹을 초기값으로 전달
            },
          );

          if (selectedGroup != null) {
            setState(() {
              _formData['group'] = selectedGroup;
            });
          }
        },
        child: InputDecorator(
          // 텍스트 필드처럼 보이게 하는 위젯
          decoration: InputDecoration(
            labelText: '그룹',
            border: InputBorder.none,
            prefixIcon: const Icon(Icons.group),
            // group 필드가 비어있을 때 힌트 텍스트
            hintText:
                (_formData['group'] == null ||
                        (_formData['group'] as String).isEmpty)
                    ? '그룹을 선택하거나 추가하세요'
                    : null,
          ),
          child: Text(
            _formData['group'] != null &&
                    (_formData['group'] as String).isNotEmpty
                ? _formData['group']!
                : '선택 안 함', // 현재 선택된 그룹 표시
            style: Theme.of(context).textTheme.titleMedium, // 텍스트 스타일 조정
          ),
        ),
      ),
    );
  }

  String _formatPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return ''; // '번호 없음' 대신 빈 문자열 반환하여 TextFormField에 표시되지 않도록 함
    }

    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) {
      return '';
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
}
