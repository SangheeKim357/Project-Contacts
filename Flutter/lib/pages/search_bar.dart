import 'package:flutter/material.dart';
import '../pages/search_controller.dart';
import 'package:provider/provider.dart';
//검색 입력창 UI를 담당하며, SearchStateController와 연결되어 검색 기능의 입력을 처리

/// 🔍 사용자 검색 입력창 위젯 (상태는 SearchStateController에서 관리)
class CustomSearchBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SearchStateController>(
      builder: (context, controller, _) {
        return Padding(
          padding: EdgeInsets.zero,
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller.textController,
                  focusNode: controller.focusNode,
                  keyboardType: TextInputType.text,
                  decoration: InputDecoration(
                    hintText: '검색',
                    prefixIcon: Icon(Icons.search),
                    suffixIcon:
                        controller.textController.text.isNotEmpty
                            ? IconButton(
                              icon: Icon(Icons.clear),
                              onPressed: controller.clearSearch,
                            )
                            : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),

                  onChanged: controller.onSearchChanged,
                ),
              ),

              /// 🔙 포커스 상태일 때만 취소 버튼 표시
              if (controller.focusNode.hasFocus)
                TextButton(
                  onPressed: controller.clearSearch,
                  child: Text('취소'),
                ),
            ],
          ),
        );
      },
    );
  }
}
