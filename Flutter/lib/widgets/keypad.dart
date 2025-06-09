import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/dialer_controller.dart';

class Keypad extends StatelessWidget {
  const Keypad({super.key});

  @override
  Widget build(BuildContext context) {
    final dialerController = Provider.of<DialerController>(context);

    // 1. 숫자 버튼 배열 (키패드 구성)
    final List<List<String>> buttons = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['*', '0', '#'],
    ];

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 2. 숫자 버튼들 - 4줄(Row)로 묶음
        ...buttons.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children:
                row.map((text) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _KeyButton(
                      text: text,
                      onTap: () => dialerController.addDigit(text),
                    ),
                  );
                }).toList(),
          );
        }),

        const SizedBox(height: 12),

        // 3. 하단 기능 버튼 행 - 통화 버튼 + 지우기 버튼
        SizedBox(
          height: 72,
          width: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // 중앙 고정: 통화 버튼
              GestureDetector(
                onTap: () => dialerController.callNumber(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  alignment: Alignment.center,
                  child: const Icon(Icons.phone, color: Colors.white, size: 32),
                ),
              ),

              // 우측 고정: 항상 자리를 차지하되 내용만 보여주기
              Positioned(
                right: 0,
                child: SizedBox(
                  width: 72,
                  height: 72,
                  child: Visibility(
                    visible: dialerController.rawPhoneNumber.isNotEmpty,
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    child: _BackspaceButton(
                      onTap: () => dialerController.removeLastDigit(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// 숫자 버튼 UI 컴포넌트
class _KeyButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const _KeyButton({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey[200],
        ),
        alignment: Alignment.center,
        child: Text(text, style: const TextStyle(fontSize: 28)),
      ),
    );
  }
}

// 지우기 버튼 UI 컴포넌트
class _BackspaceButton extends StatelessWidget {
  final VoidCallback onTap;
  const _BackspaceButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 72,
        height: 72,
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.redAccent,
        ),
        alignment: Alignment.center,
        child: Stack(
          alignment: Alignment.center,
          children: const [
            Icon(Icons.arrow_back, color: Colors.white, size: 28),
            Positioned(
              top: 22,
              right: 22,
              child: Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ],
        ),
      ),
    );
  }
}
