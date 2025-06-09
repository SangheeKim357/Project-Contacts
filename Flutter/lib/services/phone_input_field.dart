import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../controllers/dialer_controller.dart';
import '../utils/phone_formatter.dart'; // 하이픈 포매터 함수 임포트

class PhoneInputField extends StatelessWidget {
  const PhoneInputField({super.key});

  @override
  Widget build(BuildContext context) {
    final rawPhoneNumber = context.watch<DialerController>().rawPhoneNumber;
    final formattedPhoneNumber = formatPhoneNumber(rawPhoneNumber);

    return GestureDetector(
      onLongPress: () {
        if (formattedPhoneNumber.isNotEmpty) {
          Clipboard.setData(ClipboardData(text: formattedPhoneNumber));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('전화번호가 복사되었습니다')));
        }
      },
      child: Text(
        formattedPhoneNumber,
        style: const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}
