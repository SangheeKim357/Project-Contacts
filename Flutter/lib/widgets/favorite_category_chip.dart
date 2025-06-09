import 'package:flutter/material.dart';

class FavoriteCategoryChip extends StatelessWidget {
  final String categoryName;
  final bool isSelected;
  final VoidCallback onTap;
  // 백엔드에서 카테고리 이름 변경/삭제를 지원하지 않으므로
  // 이 콜백들은 호출되지 않거나, 프론트엔드에서만 처리됩니다.
  final VoidCallback onRename;
  final VoidCallback onDelete;

  const FavoriteCategoryChip({
    super.key,
    required this.categoryName,
    required this.isSelected,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: () {
        // 길게 누르면 팝업 메뉴 표시
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent, // 배경 투명
          builder: (context) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    leading: Icon(
                      Icons.edit_rounded,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: Text(
                      '이름 변경',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // BottomSheet 닫기
                      onRename(); // FavoritesScreen에서 구현된 더미 함수 호출
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      Icons.delete_rounded,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    title: Text(
                      '카테고리 삭제',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context); // BottomSheet 닫기
                      onDelete(); // FavoritesScreen에서 구현된 더미 함수 호출
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Chip(
        label: Text(categoryName),
        backgroundColor:
            isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.secondary.withOpacity(0.2),
        labelStyle: Theme.of(context).textTheme.labelLarge?.copyWith(
          color:
              isSelected
                  ? Theme.of(context).colorScheme.onPrimary
                  : Theme.of(context).colorScheme.onSurface,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side:
              isSelected
                  ? BorderSide.none
                  : BorderSide(
                    color: Theme.of(context).dividerColor.withOpacity(0.5),
                    width: 1,
                  ),
        ),
      ),
    );
  }
}
