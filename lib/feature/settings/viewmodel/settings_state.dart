import 'package:Koinos/feature/auth/data/model/user_model.dart';

abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String workspaceName;
  final String adminId;
  final List<UserModel> members;
  final bool isAdmin;

  final String? removingMemberId;

  final String? errorMessage;

  SettingsLoaded({
    required this.workspaceName,
    required this.adminId,
    required this.members,
    required this.isAdmin,
    this.removingMemberId,
    this.errorMessage,
  });

  SettingsLoaded copyWith({
    String? workspaceName,
    String? adminId,
    List<UserModel>? members,
    bool? isAdmin,
    String? removingMemberId,
    bool clearRemoving = false,
    String? errorMessage,
    bool clearError = false,
  }) {
    return SettingsLoaded(
      workspaceName: workspaceName ?? this.workspaceName,
      adminId: adminId ?? this.adminId,
      members: members ?? this.members,
      isAdmin: isAdmin ?? this.isAdmin,
      removingMemberId: clearRemoving ? null : (removingMemberId ?? this.removingMemberId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}
