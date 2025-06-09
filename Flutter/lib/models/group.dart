class ContactGroup {
  final String name;
  final int? memberCount; // 그룹에 속한 연락처 수 (옵션)

  ContactGroup({required this.name, this.memberCount});

  // Map에서 ContactGroup 객체를 생성하는 팩토리 생성자 추가 (백엔드 Map 응답을 파싱하기 위함)
  factory ContactGroup.fromMap(Map<String, dynamic> map) {
    return ContactGroup(
      name: map['name'] as String,
      memberCount: map['memberCount'] as int?,
    );
  }
}
