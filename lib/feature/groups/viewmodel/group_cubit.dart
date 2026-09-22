import 'package:flutter_bloc/flutter_bloc.dart';
import '../data/model/group_model.dart';
import '../data/repository/group_repository.dart';
import 'group_state.dart';

class GroupCubit extends Cubit<GroupState> {
  final GroupRepository _repository;
  GroupModel? currentGroup;

  GroupCubit({GroupRepository? repository})
      : _repository = repository ?? GroupRepository(),
        super(GroupInitial());

  Future<void> createGroup({required String name}) async {
    emit(GroupLoading());
    try {
      currentGroup = await _repository.createGroup(name: name);
      emit(GroupSuccess('Workspace created successfully!'));
      await fetchGroups();
    } catch (e) {
      emit(GroupFailure('Failed to create workspace: ${e.toString()}'));
    }
  }

  Future<void> joinGroup({required String groupCode}) async {
    emit(GroupLoading());
    try {
      currentGroup = await _repository.joinGroup(groupCode: groupCode);
      emit(GroupSuccess('Joined workspace successfully!'));
      await fetchGroups();
    } catch (e) {
      emit(GroupFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> leaveGroup(String groupId) async {
    emit(GroupLoading());
    try {
      await _repository.leaveGroup(groupId: groupId);
      currentGroup = null;
      emit(GroupSuccess('Left workspace successfully!'));
      await fetchGroups();
    } catch (e) {
      emit(GroupFailure('Failed to leave workspace: ${e.toString()}'));
    }
  }

  Future<void> deleteGroup(String groupId) async {
    emit(GroupLoading());
    try {
      await _repository.deleteGroup(groupId: groupId);
      currentGroup = null;
      emit(GroupSuccess('Workspace deleted successfully!'));
      await fetchGroups();
    } catch (e) {
      emit(GroupFailure('Failed to delete workspace: ${e.toString()}'));
    }
  }

  Future<void> fetchGroups() async {
    emit(GroupLoading());
    try {
      final groups = await _repository.fetchGroups();
      emit(GroupLoaded(groups));
    } catch (e) {
      emit(GroupFailure('Failed to fetch workspaces: ${e.toString()}'));
    }
  }
}
