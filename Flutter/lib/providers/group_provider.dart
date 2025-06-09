// group_provider.dart
import 'package:flutter/material.dart';
import '../models/contact.dart'; // Contact 모델 필요
import '../api/contact_api.dart';
import '../models/group.dart'; // ContactGroup 모델 임포트

class GroupProvider with ChangeNotifier {
  final ContactApi _contactApi = ContactApi();
  List<ContactGroup> _groups = []; // List<ContactGroup>으로 유지
  List<Contact> _contactsInSelectedGroup = []; // 선택된 그룹의 연락처 목록
  String? _selectedGroupName; // 현재 선택된 그룹 이름
  List<Contact> _allContactsForAssignment = []; // 그룹 할당을 위한 모든 연락처

  List<ContactGroup> get groups => _groups; // getter도 List<ContactGroup>으로 유지
  List<Contact> get contactsInSelectedGroup => _contactsInSelectedGroup;
  String? get selectedGroupName => _selectedGroupName;
  List<Contact> get allContactsForAssignment => _allContactsForAssignment;

  GroupProvider() {
    fetchGroups();
    fetchAllContactsForGroupAssignment();
  }

  Future<void> fetchGroups() async {
    try {
      final List<Map<String, dynamic>> rawGroups =
          await _contactApi.getAllGroups();
      _groups = rawGroups.map((map) => ContactGroup.fromMap(map)).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching groups: $e');
      _groups = [];
      notifyListeners();
    }
  }

  Future<void> fetchContactsByGroup(String groupName) async {
    try {
      _selectedGroupName = groupName;
      _contactsInSelectedGroup = await _contactApi.getContactsByGroup(
        groupName,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching contacts by group: $e');
      _contactsInSelectedGroup = [];
      notifyListeners();
    }
  }

  Future<void> createGroup(String groupName) async {
    try {
      await _contactApi.createGroup(groupName);
      await fetchGroups(); // 그룹 목록 새로고침
    } catch (e) {
      debugPrint('Error creating group: $e');
      rethrow;
    }
  }

  Future<void> renameGroup(String oldName, String newName) async {
    try {
      await _contactApi.renameGroup(oldName, newName);
      await fetchGroups(); // 그룹 목록 새로고침
      if (_selectedGroupName == oldName) {
        _selectedGroupName = newName;
        await fetchContactsByGroup(newName); // 그룹 상세 정보 새로고침
      }
    } catch (e) {
      debugPrint('Error renaming group: $e');
      rethrow;
    }
  }

  Future<void> deleteGroup(String groupName) async {
    try {
      await _contactApi.deleteGroup(groupName);
      await fetchGroups(); // 그룹 목록 새로고침
      if (_selectedGroupName == groupName) {
        _selectedGroupName = null;
        _contactsInSelectedGroup = []; // 그룹 상세 정보 초기화
      }
    } catch (e) {
      debugPrint('Error deleting group: $e');
      rethrow;
    }
  }

  Future<void> fetchAllContactsForGroupAssignment() async {
    try {
      _allContactsForAssignment =
          await _contactApi.getAllContactsForGroupAssignment();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching all contacts for assignment: $e');
      _allContactsForAssignment = [];
      notifyListeners();
    }
  }

  Future<void> updateContactGroup(int contactId, String? newGroup) async {
    try {
      await _contactApi.updateContactGroup(contactId, newGroup);
      // 변경된 연락처 정보를 즉시 반영
      // _allContactsForAssignment 목록 업데이트
      final index = _allContactsForAssignment.indexWhere(
        (contact) => contact.id == contactId,
      );
      if (index != -1) {
        // 서버에서 최신 연락처 정보를 다시 가져오는 것이 가장 정확합니다.
        // 여기서는 단순히 그룹만 업데이트한다고 가정합니다.
        // 실제 구현에서는 API에서 해당 contactId의 최신 정보를 가져와서 업데이트하는 것이 좋습니다.
        final updatedContact = _allContactsForAssignment[index].copyWith(
          group: newGroup,
        );
        _allContactsForAssignment[index] = updatedContact;
      }

      // 선택된 그룹의 연락처 목록도 업데이트
      if (_selectedGroupName != null) {
        await fetchContactsByGroup(_selectedGroupName!);
      }

      // 전체 그룹 목록 (멤버 카운트)도 업데이트
      await fetchGroups();

      notifyListeners(); // UI 업데이트
    } catch (e) {
      debugPrint('Error updating contact group: $e');
      rethrow;
    }
  }
}
