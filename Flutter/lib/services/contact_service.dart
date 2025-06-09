import 'dart:convert';
import 'dart:io'; // File 클래스를 위해 추가
import 'package:http/http.dart' as http;
import '../models/contact.dart'; // Contact 모델 임포트
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime/mime.dart';

class ContactService {
  // TODO: 실제 서버의 기본 URL로 변경해주세요. (현재는 192.168.0.73 기준)
  static const String baseUrl = 'http://192.168.0.73:8083/api/contacts';
  static const String uploadBaseUrl =
      'http://192.168.0.73:8083/api/contacts/uploads'; // 이미지 업로드 전용 URL
  static const String serverBaseUrl =
      'http://192.168.0.73:8083'; // 이미지를 표시할 때 사용될 기본 서버 URL

  static final ImagePicker _picker = ImagePicker();

  static Future<File?> pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      return File(pickedFile.path);
    }
    return null;
  }

  static Future<void> deleteContactsByIds(List<int> contactIds) async {
    print('ContactService: 여러 연락처 삭제 요청 (IDs: $contactIds)');
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/contacts/batch-delete'), // 서버의 일괄 삭제 엔드포인트 URL
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(contactIds), // 삭제할 ID 목록을 JSON 배열로 전송
      );

      print('Response status (deleteContactsByIds): ${response.statusCode}');
      print(
        'Response body (deleteContactsByIds): ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        // 200 OK 또는 204 No Content는 성공적인 삭제를 의미
        print('ContactService: 연락처 ${contactIds} 삭제 성공');
      } else {
        throw Exception(
          '여러 연락처 삭제 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e) {
      print('ContactService: 여러 연락처 삭제 중 오류 발생: $e');
      rethrow; // 오류를 호출자에게 다시 전달
    }
  }

  // 새로운 연락처를 추가하는 메서드 (Contact 객체 사용)
  static Future<Contact> addContact(Contact contact) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
      }, // charset 추가
      body: jsonEncode(contact.toJson()), // Contact 객체를 JSON으로 인코딩
    );

    print('Response status (addContact): ${response.statusCode}');
    print('Response body (addContact): ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 201) {
      // 201 Created는 성공적인 생성을 의미
      return Contact.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        '연락처 등록 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  // ⭐ 특정 ID의 연락처를 가져오는 메서드 (가장 중요) ⭐
  static Future<Contact?> getContactById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'));

      print('Response status (getContactById): ${response.statusCode}');
      print(
        'Response body (getContactById): ${utf8.decode(response.bodyBytes)}',
      );

      if (response.statusCode == 200) {
        print("Response body (getContactById): ${response.body}");

        final dynamic body = json.decode(utf8.decode(response.bodyBytes));
        return Contact.fromJson(body);
      } else if (response.statusCode == 404) {
        print("연락처를 찾을 수 없습니다: $id");
        // throw Exception('ID $id를 가진 연락처를 찾을 수 없습니다.');
        return null;
      } else {
        print("단일 연락처 불러오기 실패: ${response.statusCode}");
        throw Exception('연락처 상세 정보 로드 실패: ${response.statusCode}');
      }
    } catch (e) {
      print("단일 연락처 불러오기 중 오류 발생: $e");
      return null;
    }
  }

  // ⭐ 연락처 삭제 메서드 ⭐
  static Future<void> deleteContact(int id) async {
    print("테스트01");
    final response = await http.delete(Uri.parse('$baseUrl/$id'));

    print('Response status (deleteContact): ${response.statusCode}');
    print('Response body (deleteContact): ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode != 204) {
      // 204 No Content는 성공적인 삭제를 의미
      throw Exception(
        '연락처 삭제 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  // 기존 연락처를 업데이트하는 메서드 (Contact 객체 사용)
  static Future<Contact> updateContact(Contact contact) async {
    if (contact.id == null) {
      throw Exception('ID가 누락되어 연락처를 업데이트할 수 없습니다.');
    }

    final url = '$baseUrl/${contact.id}';
    print('--- [디버그] 업데이트 요청 시작 ---');
    print('요청 URL: $url');
    print('요청 헤더: Content-Type: application/json; charset=UTF-8');
    print('요청 바디: ${jsonEncode(contact.toJson())}'); // Contact 객체를 JSON으로 변환

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode(contact.toJson()), // Contact 객체를 JSON으로 변환
      );

      print('응답 상태 코드 (updateContact): ${response.statusCode}');
      print('응답 본문 (updateContact): ${utf8.decode(response.bodyBytes)}');

      if (response.statusCode == 200) {
        return Contact.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
      } else {
        throw Exception(
          '연락처 수정 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
        );
      }
    } catch (e, stacktrace) {
      print('[에러] updateContact 중 예외 발생: $e');
      print(stacktrace);
      rethrow; // 예외를 호출자에게 다시 전달
    }
  }

  // ⭐ 즐겨찾기 상태를 업데이트하는 메서드 ⭐
  static Future<Contact> updateContactFavorite(
    int id,
    bool favoriteStatus,
  ) async {
    final response = await http.post(
      Uri.parse(
        '$baseUrl/$id/toggleFavorite',
      ), // 서버가 'toggleFavorite'과 같은 POST 엔드포인트를 제공할 경우
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, bool>{'favorite': favoriteStatus}),
    );
    print('Response status (updateContactFavorite): ${response.statusCode}');
    print(
      'Response body (updateContactFavorite): ${utf8.decode(response.bodyBytes)}',
    );

    if (response.statusCode == 200) {
      // 서버에서 업데이트된 Contact 객체를 다시 돌려주는 경우
      return Contact.fromJson(jsonDecode(utf8.decode(response.bodyBytes)));
    } else {
      throw Exception(
        '즐겨찾기 상태 업데이트 실패: ${response.statusCode} - ${utf8.decode(response.bodyBytes)}',
      );
    }
  }

  static Future<String?> uploadImage(File imageFile) async {
    final mimeType = lookupMimeType(imageFile.path); // null을 허용하지 않도록 수정
    // mimeType이 null일 경우 기본값 설정 또는 에러 처리
    if (mimeType == null) {
      print('[에러] 이미지 파일의 MIME 타입을 알 수 없습니다.');
      return null;
    }

    final typeSplit = mimeType.split('/');

    try {
      if (!await imageFile.exists()) {
        print('[에러] 파일이 존재하지 않습니다: ${imageFile.path}');
        return null;
      }

      print('[디버그] 이미지 업로드 요청 준비: ${imageFile.path}');
      print('[디버그] ContentType: $mimeType');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse(uploadBaseUrl), // 이미지 업로드 전용 URL 사용
      );

      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // 서버에서 파일을 받을 때 사용하는 필드 이름 (일반적으로 'image' 또는 'file')
          imageFile.path,
          contentType: MediaType(typeSplit[0], typeSplit[1]),
        ),
      );

      print('[디버그] 이미지 업로드 요청 전송 중...');

      var response = await request.send();

      print('[디버그] 응답 상태 코드: ${response.statusCode}');

      final respStr = await response.stream.bytesToString();

      print('[디버그] 응답 본문: $respStr');

      if (response.statusCode == 200) {
        try {
          final jsonResponse = json.decode(respStr);
          print('[디버그] JSON 파싱 결과: $jsonResponse');
          // 서버 응답에서 이미지 URL을 추출합니다. (서버 응답 형식에 따라 'url', 'imageUrl' 등 달라질 수 있음)
          return jsonResponse['url'];
        } catch (e) {
          print('[에러] JSON 파싱 실패: $e');
          return null;
        }
      } else {
        print('[에러] 이미지 업로드 실패 (${response.statusCode}): $respStr');
        return null;
      }
    } catch (e, stacktrace) {
      print('[에러] 이미지 업로드 중 예외 발생: $e');
      print(stacktrace);
      return null;
    }
  }

  // ⭐ 모든 연락처를 가져오는 메서드 추가 ⭐
  // (구) fetchcontacts()
  static Future<List<Contact>> getAllContacts() async {
    print("리스트 새로고침 시작");

    try {
      final response = await http.get(Uri.parse('$serverBaseUrl/api/contacts'));
      if (response.statusCode == 200) {
        print("서버 응답 원본 바디 (fetchContacts): ${response.body}");
        final List<dynamic> data = jsonDecode(response.body);
        print("새로 불러온 연락처 개수: ${data.length}");

        return data.map((json) => Contact.fromJson(json)).toList();
      } else {
        print("연락처 목록 불러오기 실패: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("연락처 목록 불러오기 중 오류 발생: $e");
      return [];
    }
  }

  // 모든 연락처를 가져오는 메서드 (fetchContacts 대신 getAllContacts로 명확하게 이름 변경)
  // static Future<List<Contact>> getAllContacts() async {
  //   try {
  //     final response = await http.get(Uri.parse(baseUrl));

  //     print('Response status (getAllContacts): ${response.statusCode}');
  //     print(
  //       'Response body (getAllContacts): ${utf8.decode(response.bodyBytes)}',
  //     );

  //     if (response.statusCode == 200) {
  //       List<dynamic> body = jsonDecode(utf8.decode(response.bodyBytes));
  //       print("서버 응답 원본 바디 (fetchContacts): ${response.body}");
  //       return body.map((json) => Contact.fromJson(json)).toList();
  //     } else {
  //       throw Exception('연락처 목록 로드 실패: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print("연락처 목록 불러오기 중 오류 발생: $e");
  //     return [];
  //   }
  // }

  // 연락처 검색 메서드 (기존 fetchContact에서 이름 변경 및 static 추가)
  static Future<List<Contact>> searchContacts({String input = ''}) async {
    final uri = Uri.parse(
      '$baseUrl/search',
    ).replace(queryParameters: {'input': input});
    print("검색입력값: $input");
    final response = await http.get(uri);

    print('Response status (searchContacts): ${response.statusCode}');
    print('Response body (searchContacts): ${utf8.decode(response.bodyBytes)}');

    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(utf8.decode(response.bodyBytes));
      return jsonList.map((e) => Contact.fromJson(e)).toList();
    } else {
      throw Exception('연락처 검색 실패: ${response.statusCode}');
    }
  }
}
