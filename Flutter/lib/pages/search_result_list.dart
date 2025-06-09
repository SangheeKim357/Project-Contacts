import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'search_controller.dart'; // SearchStateController의 실제 경로를 확인하세요.
import '../models/contact.dart';
import 'package:characters/characters.dart';
import 'dart:math';
import '../services/contact_service.dart';

/// 검색 결과를 리스트로 보여주는 결과 표시용 UI 컴포넌트
class SearchResultList extends StatelessWidget {
  final ScrollController scrollController;

  const SearchResultList({required this.scrollController, Key? key})
    : super(key: key);

  Color getRandomColor({int opacity = 255}) {
    final Random random = Random();
    final List<Color> colors = [
      Colors.red,
      Colors.pink,
      Colors.purple,
      Colors.deepPurple,
      Colors.indigo,
      Colors.blue,
      Colors.lightBlue,
      Colors.cyan,
      Colors.teal,
      Colors.green,
      Colors.lightGreen,
      Colors.lime,
      Colors.yellow,
      Colors.amber,
      Colors.orange,
      Colors.deepOrange,
      Colors.brown,
      Colors.grey,
      Colors.blueGrey,
    ];
    return colors[random.nextInt(colors.length)].withAlpha(opacity);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SearchStateController>(
      builder: (context, controller, _) {
        final results = controller.filteredContacts;

        if (results.isEmpty) {
          if (controller.textController.text.isEmpty) {
            return const Center(child: Text('연락처를 검색해보세요.'));
          }
          return const Center(child: Text('검색 결과가 없습니다.'));
        }

        return ListView.builder(
          controller: scrollController,
          itemCount: results.length,
          itemBuilder: (context, index) {
            final contact = results[index];

            // displayImageUrl을 final 대신 'var'로 변경하여 재할당 가능하게 함
            var displayImageUrl = contact.image;
            print(
              'Contact Name: ${contact.name}, Image URL (before modification): $displayImageUrl',
            );

            // --- displayImageUrl 수정 로직 ---
            if (displayImageUrl != null &&
                displayImageUrl.isNotEmpty &&
                !displayImageUrl.startsWith(
                  'http',
                ) && // 'http' 또는 'https'로 시작하지 않는 경우
                !displayImageUrl.startsWith('https')) {
              // 'https'도 함께 확인하는 것이 좋습니다.
              displayImageUrl =
                  '${ContactService.serverBaseUrl}$displayImageUrl';
              print(
                'Contact Name: ${contact.name}, Image URL (after modification): $displayImageUrl',
              ); // 변경 후 URL 확인
            }
            // ---------------------------------

            return ListTile(
              leading: CircleAvatar(
                backgroundColor: getRandomColor(opacity: 150),
                backgroundImage:
                    (displayImageUrl != null && displayImageUrl.isNotEmpty)
                        ? NetworkImage(displayImageUrl)
                            as ImageProvider<Object>?
                        : null,
                child:
                    (displayImageUrl == null || displayImageUrl.isEmpty)
                        ? Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '',
                          style: const TextStyle(
                            color: Colors.white, // 배경색과 대비되도록 흰색으로 설정
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        )
                        : null,
              ),
              title: Text(
                contact.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                contact.phone ?? "연락처 없음",
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  '/detail', // 상세 페이지의 라우트 이름
                  arguments: contact, // 상세 페이지로 전달할 Contact 객체
                );
              },
            );
          },
        );
      },
    );
  }
}
