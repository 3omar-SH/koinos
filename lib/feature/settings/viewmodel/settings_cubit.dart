import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';
import 'package:Koinos/feature/workspace/data/repos/workspace_repos.dart';
import 'settings_state.dart';

class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit({WorkspaceRepository? workspaceRepository})
      : _workspaceRepository = workspaceRepository ?? WorkspaceRepository(),
        super(SettingsInitial());

  final WorkspaceRepository _workspaceRepository;
  String? _workspaceId;

  Future<void> initSettings(String workspaceId) async {
    _workspaceId = workspaceId;
    emit(SettingsLoading());

    try {
      final currentUserUid = FirebaseAuth.instance.currentUser?.uid;

      final workspaceInfo =
          await _workspaceRepository.getWorkspaceInfo(workspaceId, forceRefresh: true);
      final members = await _workspaceRepository.getTeamMembers(workspaceInfo.memberIds);

      emit(SettingsLoaded(
        workspaceName: workspaceInfo.name,
        adminId: workspaceInfo.adminId,
        members: members,
        isAdmin: currentUserUid != null && currentUserUid == workspaceInfo.adminId,
      ));
    } catch (e) {
      emit(SettingsError(e.toString()));
    }
  }

  Future<void> removeMember(UserModel member) async {
    final current = state;
    if (current is! SettingsLoaded || _workspaceId == null) return;
    if (!current.isAdmin || member.uid == current.adminId) return;

    emit(current.copyWith(removingMemberId: member.uid, clearError: true));

    try {
      await _workspaceRepository.removeMember(_workspaceId!, member.uid);
      final updatedMembers = current.members.where((m) => m.uid != member.uid).toList();
      emit(current.copyWith(members: updatedMembers, clearRemoving: true));
    } catch (e) {
      emit(current.copyWith(
        clearRemoving: true,
        errorMessage: 'Failed to remove ${member.username}: ${e.toString()}',
      ));
    }
  }

  Future<void> renameWorkspace(String newName) async {
    final current = state;
    if (current is! SettingsLoaded || _workspaceId == null) return;
    if (!current.isAdmin) return;
    if (newName.trim() == current.workspaceName) return;

    final previousName = current.workspaceName;
    // Optimistic update so the app bar / header rename feels instant;
    // rolled back below if the write fails.
    emit(current.copyWith(workspaceName: newName.trim(), clearError: true));

    try {
      await _workspaceRepository.renameWorkspace(_workspaceId!, newName);
    } catch (e) {
      final rolledBack = state;
      if (rolledBack is SettingsLoaded) {
        emit(rolledBack.copyWith(
          workspaceName: previousName,
          errorMessage: 'Failed to rename workspace: ${e.toString()}',
        ));
      }
    }
  }

  void clearActionError() {
    final current = state;
    if (current is SettingsLoaded && current.errorMessage != null) {
      emit(current.copyWith(clearError: true));
    }
  }

  Future<void> signOut() => FirebaseAuth.instance.signOut();
}
