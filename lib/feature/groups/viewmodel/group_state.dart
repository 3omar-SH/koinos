import '../data/model/group_model.dart';

abstract class GroupState {}

class GroupInitial extends GroupState {
  @override
  String toString() => 'GroupInitial';
}

class GroupLoading extends GroupState {
  @override
  String toString() => 'GroupLoading';
}

class GroupLoaded extends GroupState {
  final List<GroupModel> groups;
  GroupLoaded(this.groups);
  @override
  String toString() => 'GroupLoaded{count: ${groups.length}}';
}

class GroupSuccess extends GroupState {
  final String message;
  GroupSuccess(this.message);
  @override
  String toString() => 'GroupSuccess{message: $message}';
}

class GroupFailure extends GroupState {
  final String message;
  GroupFailure(this.message);
  @override
  String toString() => 'GroupFailure{message: $message}';
}
