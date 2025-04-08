import 'package:flutter/material.dart';
import 'package:ellena/core/constants/colors.dart';
import 'package:ellena/core/constants/text_styles.dart';
import 'package:ellena/core/models/chat_message.dart';
import 'package:ellena/core/utils/date_utils.dart';
import 'package:flutter_markdown/flutter_markdown.dart'; // Add this import

class MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final VoidCallback? onTaskTap;

  const MessageBubble({
    Key? key,
    required this.message,
    this.onTaskTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        child: Column(
          crossAxisAlignment: message.isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: onTaskTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColors.primary
                      : (onTaskTap != null
                          ? AppColors.primaryLight
                          : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(18).copyWith(
                    bottomRight: message.isUser ? const Radius.circular(4) : null,
                    bottomLeft: !message.isUser ? const Radius.circular(4) : null,
                  ),
                ),
                child: _buildMessageContent(context),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4, left: 8, right: 8),
              child: Text(
                AppDateUtils.formatTime(message.createdAt),
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textLight,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageContent(BuildContext context) {
    // Check if the message contains markdown
    final hasMarkdown = message.text.contains('**') ||
                        message.text.contains('*') ||
                        message.text.contains('_') ||
                        message.text.contains('#') ||
                        message.text.contains('- ') ||
                        message.text.contains('1. ');
    
    if (hasMarkdown) {
      return MarkdownBody(
        data: message.text,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: AppTextStyles.bodyMedium.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
          h1: AppTextStyles.headlineSmall.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
          h2: AppTextStyles.titleLarge.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
          h3: AppTextStyles.titleMedium.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
          ),
          blockquote: AppTextStyles.bodyMedium.copyWith(
            color: message.isUser ? Colors.white70 : AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          code: TextStyle(
            fontFamily: 'monospace',
            color: message.isUser ? Colors.white : AppColors.textPrimary,
            backgroundColor: message.isUser
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
          ),
          codeblockDecoration: BoxDecoration(
            color: message.isUser
                ? Colors.white.withOpacity(0.2)
                : Colors.grey.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      );
    } else {
      return Text(
        message.text,
        style: AppTextStyles.bodyMedium.copyWith(
          color: message.isUser ? Colors.white : AppColors.textPrimary,
        ),
      );
    }
  }
}