import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/contact.dart';
import '../models/group.dart'; // ContactGroup 모델 임포트 다시 추가!
import '../utils/app_constants.dart'; // 서버 URL 정의

class ContactApi {
  final String baseUrl =
      AppConstants.baseUrl; // 예: "http://localhost:8083/contacts"

  // 즐겨찾기 상태 업데이트
  Future<void> updateFavoriteStatus(int id, bool favorite) async {
    final url = Uri.parse('$baseUrl/$id/favorite');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'favorite': favorite}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update favorite status: ${response.body}');
    }
  }

  // 즐겨찾기 연락처 조회 (카테고리 기능 제거, 즐겨찾기 상태만 필터링)
  Future<List<Contact>> getFavoriteContacts() async {
    String url = '$baseUrl/favorites';
    final response = await http.get(Uri.parse(url));
    print('프린트트트 baseUrl: ${baseUrl}');
    print('getFavoriteContacts response status: ${response.statusCode}');
    print('getFavoriteContacts response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Contact.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load favorite contacts: ${response.body}');
    }
  }

  // 모든 그룹 조회 (Map<String, dynamic> 반환하도록 수정)
  Future<List<Map<String, dynamic>>> getAllGroups() async {
    // 반환 타입을 Map<String, dynamic>으로 변경
    final response = await http.get(Uri.parse('$baseUrl/groups'));

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      // item을 Map<String, dynamic>으로 명시적으로 캐스팅
      return body.map((dynamic item) => item as Map<String, dynamic>).toList();
    } else {
      throw Exception('Failed to load groups: ${response.body}');
    }
  }

  // 그룹 생성
  Future<void> createGroup(String groupName) async {
    final url = Uri.parse('$baseUrl/groups');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': groupName}),
    );

    if (response.statusCode != 201) {
      // 201 Created
      throw Exception('Failed to create group: ${response.body}');
    }
  }

  // 그룹 이름 변경
  Future<void> renameGroup(String oldName, String newName) async {
    final url = Uri.parse('$baseUrl/groups?oldName=$oldName&newName=$newName');
    final response = await http.put(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to rename group: ${response.body}');
    }
  }

  // 그룹 삭제
  Future<void> deleteGroup(String groupName) async {
    final url = Uri.parse('$baseUrl/groups/$groupName');
    final response = await http.delete(url);

    if (response.statusCode != 204) {
      // No Content
      throw Exception('Failed to delete group: ${response.body}');
    }
  }

  // 모든 연락처 조회 (그룹 할당용)
  Future<List<Contact>> getAllContactsForGroupAssignment() async {
    final response = await http.get(
      Uri.parse('$baseUrl/all-contacts-for-group-assignment'),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Contact.fromJson(item)).toList();
    } else {
      throw Exception(
        'Failed to load all contacts for group assignment: ${response.body}',
      );
    }
  }

  // 특정 그룹의 연락처 조회
  Future<List<Contact>> getContactsByGroup(
    String groupName, {
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/groups/$groupName/contacts?sortBy=$sortBy&sortOrder=$sortOrder',
      ),
    );

    if (response.statusCode == 200) {
      List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
      return body.map((dynamic item) => Contact.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load contacts for group: ${response.body}');
    }
  }

  // 특정 연락처의 그룹 업데이트
  Future<void> updateContactGroup(int contactId, String? newGroup) async {
    final url = Uri.parse('$baseUrl/$contactId/group');
    final response = await http.put(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'group': newGroup}),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to update contact group: ${response.body}');
    }
  }
}
