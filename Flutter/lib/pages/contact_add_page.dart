import 'package:flutter/material.dart';
import '../services/contact_service.dart';
import 'dart:io'; // File 클래스를 위해 필요
import '../models/contact.dart';
import 'package:image_picker/image_picker.dart'; // 이미지 피커를 위해 필요
import 'package:intl/intl.dart'; // DateFormat을 위해 추가
import '../widgets/group_selection_dialog.dart';

class ContactAddPage extends StatefulWidget {
  // 추가(2025_05_26, 8 / 10line )
  final String? initialPhone;
  const ContactAddPage({this.initialPhone});

  @override
  _ContactAddPageState createState() => _ContactAddPageState();
}

class _ContactAddPageState extends State<ContactAddPage> {
  final TextEditingController _groupController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  late Map<String, dynamic> _formData;
  File? _selectedImage; // 선택된 이미지 파일 (UI 표시 및 업로드용)
  final ImagePicker _picker = ImagePicker(); // 이미지 피커 인스턴스

  final TextEditingController _phoneController = TextEditingController(); // 모바일
  final TextEditingController _homeController = TextEditingController(); // 집
  final TextEditingController _companyController =
      TextEditingController(); // 회사

  // 이미지 미리보기 경로 (로컬 파일 또는 네트워크 URL)
  String? _displayImageUrl;
  late List<Map<String, dynamic>> _phoneFields;
  DateTime? _selectedBirthday;
  bool _showMoreFields = false;
  String _selectedStorage = '저장위치'; // 팝업 메뉴 버튼의 텍스트

  @override
  void initState() {
    super.initState();
    _formData = {
      'id': null,
      'name': '',
      'phone': widget.initialPhone ?? '', // initialPhone이 있다면 여기로
      'home': '',
      'company': '',
      'email': '',
      'address': '',
      'group': '',
      'birthday': null,
      'memo': '',
      'image': '',
      'favorite': false,
    };

    _phoneFields = [
      {
        'label': '모바일',
        'key': 'phone',
        'type': '모바일',
        'controller': _phoneController,
        'value': widget.initialPhone ?? '',
      },
      // 필요하다면 집, 회사 필드도 여기에 초기 추가할 수 있습니다.
      // {'label': '집', 'key': 'home', 'type': '집', 'controller': _homeController},
      // {'label': '회사', 'key': 'company', 'type': '회사', 'controller': _companyController},
    ];

    // if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
    //   _formData['phone'] = widget.initialPhone!;
    // }
    // _groupController.text = _formData['group'] as String;
    // _phoneController.text = _formData['phone'] as String;
    // _homeController.text = _formData['home'] as String;
    // _companyController.text = _formData['company'] as String;

    _groupController.text = _formData['group'] ?? '';
    _phoneController.text = _formData['phone'] ?? '';
    _homeController.text = _formData['home'] ?? '';
    _companyController.text = _formData['company'] ?? '';

    // _formData를 initState에서 초기화하여 'null' 할당 문제를 방지

    // 전화번호 필드도 initState에서 초기화

    _selectedBirthday = null; // 생일도 초기에는 선택 안 됨
    _displayImageUrl = null; // 이미지 미리보기도 초기에는 없음
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _homeController.dispose();
    _companyController.dispose();
    _groupController.dispose();

    super.dispose();
  }

  Widget _buildPhoneField(Map<String, dynamic> phoneData) {
    // 허용된 전화번호 타입 목록
    final allowedTypes = ['모바일', '집', '회사'];
    TextEditingController? currentController;
    switch (phoneData['key']) {
      // phoneData['key']를 사용하여 컨트롤러를 매핑
      case 'phone':
        currentController = _phoneController;
        break;
      case 'home':
        currentController = _homeController;
        break;
      case 'company':
        currentController = _companyController;
        break;
      default:
        currentController = null; // 예상치 못한 key인 경우
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          DropdownButton<String>(
            // phoneData['type']이 null이거나 allowedTypes에 없으면 '모바일'을 기본값으로 사용
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
            },
          ),
          SizedBox(width: 10),
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

  // 이미지 선택 함수
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 70, // 이미지 품질 조절 (선택 사항)
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _displayImageUrl = pickedFile.path; // 로컬 파일 경로를 미리보기용으로 저장
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

  // 이미지 삭제 함수
  void _clearImage() {
    setState(() {
      _selectedImage = null; // 선택된 로컬 이미지 파일 제거
      _formData['image'] = null; // formData에서도 이미지 정보 제거 (서버에 null로 전송)
      _displayImageUrl = null; // 미리보기 이미지 제거
    });
  }

  void _submitForm() async {
    print('버튼이 눌렸습니다.');

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      print('[디버그] 최종 formData 전송 전:');
      _formData.forEach((key, value) {
        print('   $key: $value');
      });

      // 컨트롤러
      // _formData['phone'] = null;
      // _formData['home'] = null;
      // _formData['company'] = null;

      for (var field in _phoneFields) {
        // 값이 비어있지 않은 경우에만 formData에 추가
        if (field['value'] != null && field['value'].isNotEmpty) {
          if (field['type'] == '모바일') {
            _formData['phone'] = field['value'];
            print('[디버그] 저장된 모바일 번호: ${_formData['phone']}');
          } else if (field['type'] == '집') {
            _formData['home'] = field['value'];
            print('[디버그] 저장된 집 번호: ${_formData['home']}');
          } else if (field['type'] == '회사') {
            _formData['company'] = field['value'];
            print('[디버그] 저장된 회사 번호: ${_formData['company']}');
          }
        }
      }
      print('[디버그] _formKey.currentState!.save() 후 _formData 상태:');

      // 1. 새 이미지가 선택되었다면 이미지 업로드
      if (_selectedImage != null) {
        try {
          final imageUrl = await ContactService.uploadImage(_selectedImage!);
          print('업로드된 이미지 URL: $imageUrl');
          if (imageUrl != null) {
            _formData['image'] = imageUrl; // 성공적으로 업로드된 이미지 URL을 formData에 저장
          } else {
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('이미지 업로드에 실패했습니다.')));
            }
            return; // 이미지 업로드 실패 시 연락처 추가를 중단
          }
        } catch (e) {
          print('이미지 업로드 중 에러: $e');
          if (context.mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('이미지 업로드 중 오류가 발생했습니다: $e')));
          }
          return; // 이미지 업로드 실패 시 연락처 추가를 중단
        }
      } else {
        // 이미지가 선택되지 않은 경우, 'image' 필드를 null로 유지 (기본값)
        _formData['image'] = null;
      }

      // 2. _formData에 있는 birthday DateTime?을 String으로 변환하여 전송
      if (_selectedBirthday != null) {
        _formData['birthday'] =
            _selectedBirthday!.toIso8601String().split('T')[0];
      } else {
        _formData['birthday'] = null;
      }
      // 'favorite' 필드는 Checkbox의 onChanged에서 직접 업데이트되므로 여기서는 추가 작업이 필요 없습니다.
      // _formData['favorite'] = _formData['favorite'] as bool? ?? false; // initState에서 false로 초기화했으므로 필요 없음

      // 3. ContactService를 통해 새 연락처 정보 추가
      print("새 연락처 추가 전달값: $_formData");
      final Contact newContact = Contact.fromJson(_formData);

      await ContactService.addContact(newContact);

      // 연락처 추가 성공 후 이미지 관련 상태 초기화
      setState(() {
        _selectedImage = null;
        _displayImageUrl = null;
      });

      if (context.mounted) {
        print("add페이지 데이터 전달");
        Navigator.pop(context, true); // 연락처 추가 완료 신호 전송
      }
    }
  }

  void _pickBirthday() async {
    if (!mounted) return;

    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthday ?? DateTime(1990, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedBirthday = picked;
        _formData['birthday'] = picked.toIso8601String().split('T')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.group),
            SizedBox(width: 8),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _selectedStorage = value; // 선택된 값을 _selectedStorage에 할당
                });
                print('선택한 저장위치: $value');
              },
              itemBuilder:
                  (context) => [
                    PopupMenuItem(
                      value: '로컬드라이브',
                      child: Row(
                        children: [
                          Icon(Icons.group),
                          SizedBox(width: 8),
                          Text('로컬드라이브'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: '클라우드',
                      child: Row(
                        children: [
                          Icon(Icons.cloud),
                          SizedBox(width: 8),
                          Text('클라우드'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
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
                  Text(
                    _selectedStorage,
                    style: TextStyle(fontSize: 18),
                  ), // _selectedStorage 값 표시
                  Icon(Icons.arrow_drop_down),
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

              // 전화번호 추가 버튼 (3개 이상이면 숨김)
              if (_phoneFields.length < 3)
                TextButton.icon(
                  icon: Icon(Icons.add),
                  label: Text('전화번호 추가'),
                  onPressed: () {
                    setState(() {
                      // 이미 존재하는 타입들
                      final existingTypes =
                          _phoneFields.map((f) => f['type']).toSet();

                      // 추가할 타입 우선순위 정의
                      final availableTypes = ['집', '회사', '모바일'];

                      // 추가할 수 있는 첫 번째 타입 찾기
                      final typeToAdd = availableTypes.firstWhere(
                        (type) => !existingTypes.contains(type),
                        orElse: () => '',
                      );

                      if (typeToAdd.isNotEmpty) {
                        _phoneFields.add({
                          'label': typeToAdd,
                          'key':
                              typeToAdd == '모바일'
                                  ? 'mobile${_phoneFields.length}'
                                  : typeToAdd.toLowerCase(),
                          'type': typeToAdd,
                          'value': '', // 항상 빈 값으로 초기화!
                        });
                      }
                    });
                  },
                ),

              _buildRoundedField('email', '이메일'),
              _buildGroupField(),

              // _buildRoundedField('group', '그룹'),
              if (_showMoreFields) ...[
                _buildRoundedField('address', '주소'),
                _buildRoundedField('memo', '메모'),
                SizedBox(height: 10),

                // 이미지 UI
                _buildImagePreview(), // 별도의 함수로 분리

                SizedBox(height: 10),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
                        child: Text('날짜 선택'),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value:
                            _formData['favorite'] as bool? ??
                            false, // null 안전성 추가
                        onChanged: (val) {
                          setState(() {
                            _formData['favorite'] = val!;
                          });
                        },
                      ),
                      Text('즐겨찾기'),
                    ],
                  ),
                ),
              ],

              SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  setState(() => _showMoreFields = !_showMoreFields);
                },
                icon: Icon(
                  _showMoreFields ? Icons.expand_less : Icons.expand_more,
                ),
                label: Text(_showMoreFields ? '간략히' : '더보기'),
              ),

              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('취소'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      child: Text('저장'),
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        textStyle: TextStyle(fontSize: 16),
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

  // 이미지 미리보기 UI를 별도의 함수로 분리
  Widget _buildImagePreview() {
    ImageProvider? currentImage;
    if (_selectedImage != null) {
      currentImage = FileImage(_selectedImage!); // 로컬에서 선택된 이미지
    } else if (_displayImageUrl != null &&
        _displayImageUrl!.startsWith('/data')) {
      // 이 경우는 드물지만, 혹시 로컬 파일 경로가 displayImageUrl에 저장되었을 때를 대비
      currentImage = FileImage(File(_displayImageUrl!));
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
                  if (_selectedImage != null) // 이미지가 있을 때만 '이미지 삭제' 버튼 표시
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
      case 'email':
        icon = Icons.email;
        break;
      case 'group':
        icon = Icons.group;
        break;
      case 'address':
        icon = Icons.location_on;
        break;
      case 'memo':
        icon = Icons.note;
        break;
      default:
        icon = null;
    }

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: TextFormField(
        initialValue: _formData[key]?.toString(), // 초기값 설정 (null 안전성)
        decoration: InputDecoration(
          labelText: label,
          border: InputBorder.none,
          prefixIcon: icon != null ? Icon(icon) : null,
        ),
        onSaved: (val) {
          if (key == 'name') {
            _formData[key] = val ?? ''; // 이름은 null이 되지 않도록 빈 문자열로 처리
          } else if (key == 'group') {
            // --- 이 부분 추가 ---
            _formData[key] =
                (val == null || val.isEmpty) ? '기타' : val; // 그룹이 비어있으면 '기타'로 설정
          } else {
            _formData[key] = val == '' ? null : val;
          }
        },
        validator: (val) {
          if (key == 'name') {
            return (val == null || val.isEmpty) ? '$label을 입력하세요' : null;
          }

          // ✅ 이메일 유효성 검사 추가
          if (key == 'email' && val != null && val.isNotEmpty) {
            final RegExp emailRegExp = RegExp(
              r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
            );
            if (!emailRegExp.hasMatch(val)) {
              return '유효한 이메일 형식이 아닙니다';
            }
          }

          return null;
        },
      ),
    );
  }

  Widget _buildGroupField() {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      padding: EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: InkWell(
        // TextFormFiled 대신 InkWell을 사용하여 터치 이벤트 감지
        onTap: () async {
          final selectedGroup = await showDialog<String>(
            context: context,
            builder: (BuildContext context) {
              return GroupSelectionDialog(initialGroup: _groupController.text);
            },
          );
          if (selectedGroup != null) {
            setState(() {
              _groupController.text = selectedGroup;
              _formData['group'] = selectedGroup; // formData도 업데이트
            });
          }
        },
        child: InputDecorator(
          // TextFormField처럼 보이도록 InputDecorator 사용
          decoration: const InputDecoration(
            labelText: '그룹',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.group),
          ),
          child: Text(
            _groupController.text.isEmpty ? '선택 또는 추가' : _groupController.text,
            style: TextStyle(
              color:
                  _groupController.text.isEmpty
                      ? Colors.grey[700]
                      : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
