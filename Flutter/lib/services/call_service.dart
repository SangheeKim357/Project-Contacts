import 'package:url_launcher/url_launcher.dart';

class CallService {
  static Future<void> call(String phoneNumber) async {
    final cleanedNumber = phoneNumber.replaceAll(RegExp(r'\D'), '');
    final Uri url = Uri(scheme: 'tel', path: cleanedNumber);
    print('📞 전화 시도: $url');

    if (await canLaunchUrl(url)) {
      final launched = await launchUrl(
        url,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw '전화 앱 실행 실패';
      }
    } else {
      throw '전화 연결을 할 수 없습니다: $cleanedNumber';
    }
  }
}
