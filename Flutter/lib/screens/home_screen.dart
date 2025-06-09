import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'AI Phonebook'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.phone_rounded,
                size: 80,
                color: Theme.of(context).colorScheme.primary.withOpacity(0.7),
              ),
              const SizedBox(height: 20),
              Text(
                'AI Phonebook에 오신 것을 환영합니다!',
                style: Theme.of(context).textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                '하단 탭에서 즐겨찾기 및 그룹 기능을 확인해보세요.',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              // 실제 연락처 목록이 여기에 표시될 수 있습니다.
              // 현재는 즐겨찾기와 그룹 기능에 집중
            ],
          ),
        ),
      ),
      // FAB (연락처 추가 버튼) - 필요시 추가
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     // 연락처 추가 화면으로 이동
      //   },
      //   child: const Icon(Icons.add_rounded),
      // ),
    );
  }
}
