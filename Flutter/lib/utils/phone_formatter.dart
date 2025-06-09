import 'package:flutter/services.dart';

/// 전화번호 입력 시 하이픈(-) 자동 삽입 포매터
class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // 숫자만 추출
    final digitsOnly = newValue.text.replaceAll(RegExp(r'\D'), '');
    String formatted = '';
    int length = digitsOnly.length;

    // 입력 길이에 따라 하이픈 형식 적용
    if (length <= 3) {
      formatted = digitsOnly;
    } else if (length <= 7) {
      formatted = '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3)}';
    } else if (length <= 11) {
      formatted =
          '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7)}';
    } else {
      formatted =
          '${digitsOnly.substring(0, 3)}-${digitsOnly.substring(3, 7)}-${digitsOnly.substring(7, 11)}';
    }

    // 커서 위치 설정
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// 일반 문자열에서 하이픈 포맷 적용
String formatPhoneNumber(String digitsOnly) {
  final numbers = digitsOnly.replaceAll(RegExp(r'\D'), '');
  if (numbers.length <= 3) return numbers;
  if (numbers.length <= 7) {
    return '${numbers.substring(0, 3)}-${numbers.substring(3)}';
  } else if (numbers.length <= 11) {
    return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7)}';
  } else {
    return '${numbers.substring(0, 3)}-${numbers.substring(3, 7)}-${numbers.substring(7, 11)}';
  }
}
