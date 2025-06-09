import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../api/contact_api.dart';

class ContactProvider with ChangeNotifier {
  final ContactApi _contactApi = ContactApi();

  Future<void> toggleFavoriteStatus(Contact contact) async {
    final original = contact.favorite;
    contact.favorite = !original; // ✅ 상태를 직접 바꿔줌
    notifyListeners(); // 👉 먼저 UI 업데이트

    try {
      await _contactApi.updateFavoriteStatus(contact.id!, contact.favorite);
    } catch (e) {
      contact.favorite = original; // 실패하면 롤백
      notifyListeners();
      debugPrint('즐겨찾기 상태 변경 실패: $e');
      rethrow;
    }
  }
}
