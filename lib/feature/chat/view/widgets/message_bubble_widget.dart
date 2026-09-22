import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/chat/data/model/message_model.dart';
import 'package:flutter/material.dart';

class MessageBubbleWidget extends StatelessWidget {
  final MessageModel message;
  final bool isMe;

  const MessageBubbleWidget({
    super.key,
    required this.message,
    required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final timeString =
        "${message.timestamp.hour.toString().padLeft(2, '0')}:${message.timestamp.minute.toString().padLeft(2, '0')}";

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        child: Column(
          crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe) ...[
              Text(
                message.senderName,
                style: TextStyle(fontSize: 12, color: theme.hintColor, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
            ],

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isMe
                    ? AppColors.primaryBlue
                    : (isDark ? const Color(0xFF1E293B) : Colors.grey.shade200),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isMe ? 16 : 0),
                  bottomRight: Radius.circular(isMe ? 0 : 16),
                ),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isMe ? Colors.white : theme.textTheme.bodyLarge?.color,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 4),
            Text(
              timeString,
              style: TextStyle(fontSize: 10, color: theme.hintColor),
            ),
          ],
        ),
      ),
    );
  }
}
