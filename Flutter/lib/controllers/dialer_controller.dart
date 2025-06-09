import 'package:flutter/material.dart';
import '../services/call_service.dart';
import '../utils/phone_formatter.dart';

class DialerController extends ChangeNotifier {
  String _phoneNumber = '';

  String get rawPhoneNumber => _phoneNumber;

  String get formattedPhoneNumber => formatPhoneNumber(_phoneNumber);

  void addDigit(String digit) {
    _phoneNumber += digit;
    notifyListeners();
  }

  void removeLastDigit() {
    if (_phoneNumber.isNotEmpty) {
      _phoneNumber = _phoneNumber.substring(0, _phoneNumber.length - 1);
      notifyListeners();
    }
  }

  void clear() {
    _phoneNumber = '';
    notifyListeners();
  }

  void callNumber() {
    CallService.call(_phoneNumber);
    clear();
  }
}
