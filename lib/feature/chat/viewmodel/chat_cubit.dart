import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Koinos/feature/chat/data/model/message_model.dart';
import 'package:Koinos/feature/chat/data/repos/chat_repos.dart';
import 'package:Koinos/feature/chat/viewmodel/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  ChatCubit({ChatRepository? chatRepository})
      : _chatRepository = chatRepository ?? ChatRepository(),
        super(ChatStateInitial());

  final ChatRepository _chatRepository;
  StreamSubscription? _chatSubscription;

  void initChat(String workspaceId) {
    emit(ChatStateLoading());

    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    try {
      _chatSubscription?.cancel();
      _chatSubscription = _chatRepository.streamMessages(workspaceId).listen(
        (messages) {
          emit(ChatStateLoaded(messages: messages, currentUserId: currentUserId));
        },
        onError: (error) {
          emit(ChatStateError(message: error.toString()));
        },
      );
    } catch (e) {
      emit(ChatStateError(message: e.toString()));
    }
  }

  Future<void> sendMessage(String workspaceId, String messageContent) async {
    final trimmed = messageContent.trim();
    if (trimmed.isEmpty) return;

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      final currentUserId = currentUser?.uid ?? '';
      final senderName =
          currentUser?.displayName ?? currentUser?.email?.split('@').first ?? 'User';

      final newMessage = MessageModel(
        id: '',
        text: trimmed,
        senderId: currentUserId,
        senderName: senderName,
        workspaceId: workspaceId,
        timestamp: DateTime.now(),
      );

      await _chatRepository.sendMessage(newMessage);
    } catch (e) {
      _emitActionError('Failed to send message: ${e.toString()}');
    }
  }

  void clearActionError() {
    final current = state;
    if (current is ChatStateLoaded && current.errorMessage != null) {
      emit(current.copyWith(clearError: true));
    }
  }

  void _emitActionError(String message) {
    final current = state;
    if (current is ChatStateLoaded) {
      emit(current.copyWith(errorMessage: message));
    } else {
      emit(ChatStateError(message: message));
    }
  }

  @override
  Future<void> close() {
    _chatSubscription?.cancel();
    return super.close();
  }
}
