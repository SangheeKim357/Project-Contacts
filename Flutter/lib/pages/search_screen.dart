import 'package:flutter/material.dart';
import '../pages/search_controller.dart';
import '../pages/search_index_bar.dart';
import 'package:provider/provider.dart';
import 'search_bar.dart';
import 'search_result_list.dart';
//화면 구성 컨포넌트

/// ✅ 검색 화면 전체를 담당하는 Stateful 위젯
class SearchScreen extends StatefulWidget {
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  /// ✅ 검색 상태를 관리하는 컨트롤러
  late SearchStateController controller;

  /// ✅ 리스트뷰와 인덱스바를 연결하는 ScrollController
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    controller = Provider.of<SearchStateController>(context, listen: false);
    // Provider를 직접 생성하지 않고, context에서 사용
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.focusNode.requestFocus();
    });
  }

  /// ✅ 컨트롤러 dispose 처리
  @override
  void dispose() {
    scrollController.dispose();
    //controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("테스트01");
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          CustomSearchBar(),
          Expanded(
            child: Stack(
              children: [
                SearchResultList(scrollController: scrollController),
                Positioned(
                  right: 0,
                  top: 0,
                  bottom: 0,
                  child: SearchIndexBar(
                    indexes: controller.sectionIndexMap.keys.toList(),
                    onIndexSelected: (index) {
                      final targetIndex = controller.sectionIndexMap[index];
                      if (targetIndex != null) {
                        scrollController.animateTo(
                          targetIndex * 72.0,
                          duration: Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                        );
                      }
                    },
                    scrollController: scrollController,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
    );
  }
}
