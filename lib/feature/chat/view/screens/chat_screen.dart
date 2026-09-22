// ignore_for_file: deprecated_member_use

import 'package:Koinos/core/theme/app_colors.dart';
import 'package:Koinos/feature/chat/viewmodel/chat_cubit.dart';
import 'package:Koinos/feature/chat/viewmodel/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/message_bubble_widget.dart';

class ChatScreen extends StatefulWidget {
  final String workspaceId;

  const ChatScreen({super.key, required this.workspaceId});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage(BuildContext context) {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    context.read<ChatCubit>().sendMessage(widget.workspaceId, text);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider(
      create: (context) => ChatCubit()..initChat(widget.workspaceId),
      child: BlocListener<ChatCubit, ChatState>(
        listenWhen: (previous, current) =>
            current is ChatStateLoaded && current.errorMessage != null,
        listener: (context, state) {
          final message = (state as ChatStateLoaded).errorMessage!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message), backgroundColor: AppColors.error),
          );
          context.read<ChatCubit>().clearActionError();
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: Column(
            children: [
              Expanded(
                child: BlocBuilder<ChatCubit, ChatState>(
                  builder: (context, state) {
                    if (state is ChatStateLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.primaryBlue));
                    }

                    if (state is ChatStateError) {
                      return Center(child: Text(state.message, style: TextStyle(color: theme.hintColor)));
                    }

                    if (state is ChatStateLoaded) {
                      final messages = state.messages;

                      if (messages.isEmpty) {
                        return Center(
                          child: Text('No messages yet. Start the conversation!', style: TextStyle(color: theme.hintColor)),
                        );
                      }

                      return ListView.builder(
                        reverse: true,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final message = messages[index];
                          final isMe = message.senderId == state.currentUserId;

                          return MessageBubbleWidget(
                            key: ValueKey(message.id),
                            message: message,
                            isMe: isMe,
                          );
                        },
                      );
                    }

                    return const SizedBox();
                  },
                ),
              ),

              Builder(
                builder: (context) {
                  return Container(
                    padding: const EdgeInsets.only(left: 16, right: 16, bottom: 24, top: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B).withOpacity(0.5) : Colors.white,
                      border: Border(top: BorderSide(color: isDark ? Colors.white.withOpacity(0.05) : Colors.black.withOpacity(0.05))),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark ? theme.scaffoldBackgroundColor : Colors.black.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: TextField(
                              controller: _messageController,
                              style: TextStyle(color: theme.textTheme.bodyLarge?.color),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(context),
                              decoration: InputDecoration(
                                hintText: 'Type a message...',
                                hintStyle: TextStyle(color: theme.hintColor),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _sendMessage(context),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: const BoxDecoration(
                              color: AppColors.primaryBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ],
                    ),
                  );
                }
              ),
              const SizedBox(height: 90),
            ],
          ),
        ),
      ),
    );
  }
}
