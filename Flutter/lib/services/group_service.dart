import 'dart:collection';

class GroupService {
  // 실제 애플리케이션에서는 이 목록을 영구 저장소(DB, Shared Preferences 등)에서 로드해야 합니다.
  static final List<String> _groups = ['직장', '가족', '친구', '기타'];

  // 그룹 목록을 변경 불가능하게 외부에 제공
  static UnmodifiableListView<String> get groups =>
      UnmodifiableListView(_groups);

  // 새 그룹 추가 (중복 방지)
  static bool addGroup(String newGroup) {
    final normalizedGroup = newGroup.trim();
    if (normalizedGroup.isNotEmpty && !_groups.contains(normalizedGroup)) {
      _groups.add(normalizedGroup);
      _groups.sort(); // 알파벳 순으로 정렬 (선택 사항)
      return true;
    }
    return false;
  }

  // 그룹 삭제 (선택 사항)
  static bool removeGroup(String groupToRemove) {
    return _groups.remove(groupToRemove);
  }
}
