import 'package:Koinos/feature/chat/data/model/message_model.dart';

abstract class ChatState {}

class ChatStateInitial extends ChatState {}

class ChatStateLoading extends ChatState {}

class ChatStateLoaded extends ChatState {
  final List<MessageModel> messages;
  final String currentUserId;
  final String? errorMessage;

  ChatStateLoaded({
    required this.messages,
    required this.currentUserId,
    this.errorMessage,
  });

  ChatStateLoaded copyWith({
    List<MessageModel>? messages,
    String? currentUserId,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ChatStateLoaded(
      messages: messages ?? this.messages,
      currentUserId: currentUserId ?? this.currentUserId,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class ChatStateError extends ChatState {
  final String message;

  ChatStateError({required this.message});
}
