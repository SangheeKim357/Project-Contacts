import 'package:flutter/material.dart';
import '../models/contact.dart';
import 'package:characters/characters.dart';
import '../services/contact_service.dart'; // ContactService 임포트
import 'dart:async';

/// 🔧 검색 상태와 동작을 관리하는 컨트롤러 (Provider로 사용)
class SearchStateController extends ChangeNotifier {
  TextEditingController searchController = TextEditingController();
  List<String> searchResults = [];

  void updateSearchQuery(String query) {
    print('검색어 변경: $query'); // 디버깅: 입력된 검색어 확인
    searchResults = _searchData(query);
    print('검색 결과 업데이트: $searchResults'); // 디버깅: 업데이트된 검색 결과 확인
    notifyListeners();
  }

  List<String> _searchData(String query) {
    List<String> allData = ['Apple', 'Banana', 'Orange', 'Grapes'];
    return allData
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  /// 🧩 텍스트 입력 및 포커스 상태 관리
  final TextEditingController textController = TextEditingController();
  final FocusNode focusNode = FocusNode();

  /// 🔍 필터링된 연락처 리스트 (서버에서 검색 결과 받아서 저장)
  List<Contact> filteredContacts = [];

  /// 🅰️ 인덱스바에 사용될 키(ㄱ~ㅎ, A~Z)와 각 위치 맵핑
  Map<String, int> sectionIndexMap = {};

  // ✅ ContactService는 static 메서드를 제공하므로, 인스턴스화할 필요가 없습니다.
  // final ContactService _service = ContactService(); // 이 줄은 이제 필요 없습니다.

  /// ⏳ 디바운스 타이머
  Timer? _debounceTimer;

  /// 📦 생성자: 초기 데이터 불러오기 안 함
  SearchStateController() {
    textController.addListener(() {
      notifyListeners();
    });
  }

  /// 🔄 검색어가 변경될 때마다 호출됨 (디바운스 적용)
  void onSearchChanged(String input) {
    print("검색입력값: $input");
    // 기존 타이머가 있으면 취소
    _debounceTimer?.cancel();

    // 입력이 멈춘 후 200ms 뒤에 실제 검색 실행
    _debounceTimer = Timer(Duration(milliseconds: 200), () async {
      await _performSearch(input.trim());
    });
  }

  /// 실제 검색 로직 분리
  Future<void> _performSearch(String input) async {
    if (input.isEmpty) {
      filteredContacts = [];
      sectionIndexMap.clear();
      notifyListeners();
      return;
    }

    try {
      List<Contact> all = [];

      if (isOnlyKoreanInitials(input)) {
        // 초성만 입력된 경우: 서버에 검색어 넘기지 않고 전체 리스트 받아서 클라이언트 필터링
        // ContactService.getAllContacts()를 사용하여 전체 연락처를 가져옵니다.
        all = await ContactService.getAllContacts(); // ✨ 수정된 부분: static 메서드 호출
        filteredContacts =
            all.where((contact) {
              final initials = extractInitials(contact.name); // 이름에서 초성 추출
              return initials.startsWith(input);
            }).toList();
      } else {
        // 일반 검색 - 단일 input 파라미터로 서버에 요청
        // ContactService.searchContacts()를 사용하여 검색을 수행합니다.
        all = await ContactService.searchContacts(
          input: input,
        ); // ✨ 수정된 부분: static 메서드 호출

        String normalize(String text) => text.toLowerCase().replaceAll('-', '');

        final normalizedInput = input.toLowerCase().replaceAll('-', '');

        filteredContacts =
            all.where((contact) {
              final name = contact.name.toLowerCase();
              final phone = normalize(contact.phone ?? '');
              final memo = (contact.memo ?? '').toLowerCase();

              return name.contains(normalizedInput) ||
                  phone.contains(normalizedInput) ||
                  memo.contains(normalizedInput);
            }).toList();
      }
      filteredContacts.sort(customSort);

      _buildIndexMap();
      notifyListeners();
    } catch (e) {
      print('검색 중 에러: $e');
      // 사용자에게 에러를 알리는 로직을 추가할 수 있습니다 (예: SnackBar)
    }
  }

  /// 🧮 한글/영문/기타 기준으로 정렬
  int customSort(Contact a, Contact b) {
    String getKey(Contact c) {
      String first = c.name.characters.first;
      if (RegExp(r'[가-힣]').hasMatch(first)) {
        return getKoreanInitial(first); // 한글 초성
      } else if (RegExp(r'[a-zA-Z]').hasMatch(first)) {
        return first.toUpperCase(); // 알파벳
      } else {
        return '#'; // 그 외
      }
    }

    String keyA = getKey(a);
    String keyB = getKey(b);

    int getPriority(String key) {
      if (RegExp(r'[ㄱ-ㅎ]').hasMatch(key)) return 1; // 한글 초성
      if (RegExp(r'[A-Z]').hasMatch(key)) return 2; // 알파벳
      return 3; // 기타 문자
    }

    int priorityA = getPriority(keyA);
    int priorityB = getPriority(keyB);

    if (priorityA != priorityB) {
      return priorityA.compareTo(priorityB); // 우선순위 비교
    }

    return a.name.compareTo(b.name); // 우선순위 같으면 이름 가나다순
  }

  //초성만 입력되었는지 검사하는 함수
  bool isOnlyKoreanInitials(String text) {
    final initialPattern = RegExp(r'^[ㄱ-ㅎ]+$');
    return initialPattern.hasMatch(text);
  }

  //이름에서 초성 문자열 추출 함수
  String extractInitials(String text) {
    if (text.isEmpty) return '';
    return text.characters.map((c) => getKoreanInitial(c)).join();
  }

  /// 🏷️ 이름의 첫 글자를 기준으로 인덱스 키 생성
  String getIndexKey(String name) {
    if (name.isEmpty) return '#';

    final firstChar = name.characters.first;
    if (RegExp(r'[가-힣]').hasMatch(firstChar)) {
      return getKoreanInitial(firstChar);
    } else if (RegExp(r'[a-zA-Z]').hasMatch(firstChar)) {
      return firstChar.toUpperCase();
    } else {
      return '#';
    }
  }

  /// ✅ 한글 초성 추출 함수
  static String getKoreanInitial(String char) {
    if (char.isEmpty) return '';
    int code = char.runes.first - 0xAC00;
    if (code < 0 || code > 11171) return '#';

    int cho = code ~/ (21 * 28);
    const initials = [
      'ㄱ',
      'ㄲ',
      'ㄴ',
      'ㄷ',
      'ㄸ',
      'ㄹ',
      'ㅁ',
      'ㅂ',
      'ㅃ',
      'ㅅ',
      'ㅆ',
      'ㅇ',
      'ㅈ',
      'ㅉ',
      'ㅊ',
      'ㅋ',
      'ㅌ',
      'ㅍ',
      'ㅎ',
    ];
    return initials[cho];
  }

  /// 📚 필터된 연락처 기준으로 인덱스 키 → 리스트 위치 맵 생성
  void _buildIndexMap() {
    sectionIndexMap.clear();
    for (int i = 0; i < filteredContacts.length; i++) {
      final name = filteredContacts[i].name;
      final key = getIndexKey(name);
      if (!sectionIndexMap.containsKey(key)) {
        sectionIndexMap[key] = i;
      }
    }
  }

  /// ❌ 검색어 초기화 및 포커스 해제
  void clearSearch() {
    textController.clear();
    focusNode.unfocus();
    filteredContacts = [];
    sectionIndexMap.clear();
    print('clearSearch 호출됨, sectionIndexMap: $sectionIndexMap');
    notifyListeners();
  }

  /// 🔚 리소스 정리
  @override
  void dispose() {
    _debounceTimer?.cancel();
    textController.dispose();
    focusNode.dispose();
    super.dispose();
  }
}
