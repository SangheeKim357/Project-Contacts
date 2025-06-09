import 'package:flutter/material.dart';
import '../pages/search_controller.dart';
import 'package:provider/provider.dart';
//연락처 목록 우측에 표시되는 인덱스 바

class SearchIndexBar extends StatelessWidget {
  /// ✅ 리스트뷰를 제어할 스크롤 컨트롤러
  final ScrollController scrollController;

  /// ✅ 현재 표시할 인덱스 리스트 (ㄱ~ㅎ, A~Z 중 일부만 표시할 수도 있음)
  final List<String> indexes;

  /// ✅ 인덱스 선택 시 실행되는 콜백 함수
  final void Function(String index) onIndexSelected;

  SearchIndexBar({
    required this.scrollController,
    required this.indexes,
    required this.onIndexSelected,
  });

  /// ✅ 고정된 전체 인덱스 목록 (우측에 표시될 항목들)
  final List<String> indexLabels = [
    'ㄱ',
    'ㄴ',
    'ㄷ',
    'ㄹ',
    'ㅁ',
    'ㅂ',
    'ㅅ',
    'ㅇ',
    'ㅈ',
    'ㅊ',
    'ㅋ',
    'ㅌ',
    'ㅍ',
    'ㅎ',
    'A',
    'B',
    'C',
    'D',
    'E',
    'F',
    'G',
    'H',
    'I',
    'J',
    'K',
    'L',
    'M',
    'N',
    'O',
    'P',
    'Q',
    'R',
    'S',
    'T',
    'U',
    'V',
    'W',
    'X',
    'Y',
    'Z',
    '#',
  ];

  @override
  Widget build(BuildContext context) {
    /// ✅ Provider로부터 상태 컨트롤러 가져오기
    final controller = Provider.of<SearchStateController>(context);

    return Transform.translate(
      offset: Offset(0, -40), // ✅ 인덱스 바를 위로 살짝 올림
      child: Align(
        alignment: Alignment.centerRight,
        child: Container(
          width: 12,
          color: Colors.transparent,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final maxHeight = constraints.maxHeight;

              /// ✅ 화면에 너무 많은 인덱스가 보이지 않게 압축 비율 적용
              final compressedHeightRatio = 0.8;
              final compressedHeight = maxHeight * compressedHeightRatio;

              /// ✅ 각 인덱스 아이템의 높이 계산 (최소 8, 최대 16)
              final itemHeight = (compressedHeight / indexLabels.length).clamp(
                8.0,
                16.0,
              );

              /// ✅ 글자 크기 계산
              final fontSize = itemHeight * 0.8;

              return Column(
                children: [
                  Spacer(flex: 1),
                  ...indexLabels.map((label) {
                    final isActive = controller.sectionIndexMap.containsKey(
                      label,
                    );
                    return GestureDetector(
                      onTap: () {
                        final index = controller.sectionIndexMap[label];
                        if (index != null) {
                          final indexOffset = index * 72.0;
                          final maxScroll =
                              scrollController.position.maxScrollExtent;
                          final safeOffset =
                              indexOffset > maxScroll ? maxScroll : indexOffset;
                          scrollController.jumpTo(safeOffset);
                          print('Scroll to index: $index for label: $label');
                        } else {
                          print('No section index for label: $label');
                        }
                      },
                      child: SizedBox(
                        height: itemHeight,
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              fontSize: fontSize,
                              color:
                                  isActive
                                      ? const Color.fromARGB(255, 48, 47, 47)
                                      : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),

                  Spacer(flex: 1), // ✅ 아래 여백
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
