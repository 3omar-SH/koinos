import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Koinos/feature/auth/data/model/user_model.dart';

class WorkspaceInfo {
  final String name;
  final String adminId;
  final List<String> memberIds;

  const WorkspaceInfo({
    required this.name,
    required this.adminId,
    required this.memberIds,
  });
}

class WorkspaceRepository {
  WorkspaceRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  static final Map<String, WorkspaceInfo> _workspaceCache = {};

  Future<WorkspaceInfo> getWorkspaceInfo(
    String workspaceId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _workspaceCache.containsKey(workspaceId)) {
      return _workspaceCache[workspaceId]!;
    }

    final doc = await _firestore.collection('workspaces').doc(workspaceId).get();

    if (!doc.exists) {
      throw Exception('Workspace not found');
    }

    final data = doc.data()!;
    final info = WorkspaceInfo(
      name: data['name'] ?? 'Workspace',
      adminId: data['adminId'] ?? '',
      memberIds: List<String>.from(data['membersIds'] ?? const []),
    );

    _workspaceCache[workspaceId] = info;
    return info;
  }

  Future<List<UserModel>> getTeamMembers(List<String> memberIds) async {
    if (memberIds.isEmpty) return [];

    const chunkSize = 10;
    final chunks = <List<String>>[];
    for (var i = 0; i < memberIds.length; i += chunkSize) {
      final end = (i + chunkSize < memberIds.length) ? i + chunkSize : memberIds.length;
      chunks.add(memberIds.sublist(i, end));
    }

    final snapshots = await Future.wait(
      chunks.map(
        (chunk) => _firestore.collection('users').where('uid', whereIn: chunk).get(),
      ),
    );

    return snapshots
        .expand((snapshot) => snapshot.docs)
        .map((doc) => UserModel.fromMap(doc.data()))
        .toList();
  }

  Future<void> removeMember(String workspaceId, String memberId) async {
    final info = await getWorkspaceInfo(workspaceId);
    if (memberId == info.adminId) {
      throw Exception('The workspace admin cannot be removed.');
    }

    await _firestore.collection('workspaces').doc(workspaceId).update({
      'membersIds': FieldValue.arrayRemove([memberId]),
    });

    final cached = _workspaceCache[workspaceId];
    if (cached != null) {
      _workspaceCache[workspaceId] = WorkspaceInfo(
        name: cached.name,
        adminId: cached.adminId,
        memberIds: cached.memberIds.where((id) => id != memberId).toList(),
      );
    }
  }

  Future<void> renameWorkspace(String workspaceId, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty) {
      throw Exception('Workspace name cannot be empty.');
    }

    await _firestore.collection('workspaces').doc(workspaceId).update({'name': trimmed});

    final cached = _workspaceCache[workspaceId];
    if (cached != null) {
      _workspaceCache[workspaceId] = WorkspaceInfo(
        name: trimmed,
        adminId: cached.adminId,
        memberIds: cached.memberIds,
      );
    }
  }

  static void invalidate(String workspaceId) {
    _workspaceCache.remove(workspaceId);
  }
}
