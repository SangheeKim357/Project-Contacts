import 'package:flutter/material.dart';
import '../models/contact.dart';
import '../api/contact_api.dart';

class FavoriteProvider with ChangeNotifier {
  final ContactApi _contactApi = ContactApi();
  List<Contact> _favoriteContacts = [];

  List<Contact> get favoriteContacts => _favoriteContacts;

  FavoriteProvider() {
    fetchFavoriteContacts();
  }

  Future<void> fetchFavoriteContacts() async {
    try {
      _favoriteContacts =
          await _contactApi.getFavoriteContacts(); // 카테고리 파라미터 제거
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching favorite contacts: $e');
      _favoriteContacts = [];
      notifyListeners();
    }
  }

  // 즐겨찾기 카테고리 관련 메서드 모두 제거
}
