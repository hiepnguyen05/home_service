import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mobile/features/chat/viewmodel/chat_viewmodel.dart';

class QuickActionsBar extends StatelessWidget {
  const QuickActionsBar({super.key});

  final List<String> _actions = const [
    "Tôi đang đến",
    "Tôi ở cửa",
    "Bạn có thể gọi cho tôi không?",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(vertical: 8),
      color: const Color(0xFFF8FAFC),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: _actions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: OutlinedButton(
              onPressed: () {
                context.read<ChatViewModel>().sendTextMessage(_actions[index]);
              },
              style: OutlinedButton.styleFrom(
                backgroundColor: Colors.white,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                _actions[index],
                style: const TextStyle(
                  color: Color(0xFF1F2937),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
