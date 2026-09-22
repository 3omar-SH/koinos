import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../model/group_model.dart';

class GroupRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _currentUserId => _auth.currentUser!.uid;

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(8, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }

  Future<GroupModel> createGroup({required String name}) async {
    final groupCode = _generateCode();

    final group = GroupModel(
      id: '',
      name: name,
      groupCode: groupCode,
      adminId: _currentUserId,
      membersIds: [_currentUserId],
    );

    final docRef = await _firestore.collection('workspaces').add(group.toMap());
    await docRef.update({'id': docRef.id});

    return GroupModel.fromMap({...group.toMap(), 'id': docRef.id});
  }

  Future<GroupModel> joinGroup({required String groupCode}) async {
    final query = await _firestore
        .collection('workspaces')
        .where('groupCode', isEqualTo: groupCode)
        .get();

    if (query.docs.isEmpty) {
      throw Exception('Workspace not found with the provided code.');
    }

    final group = GroupModel.fromMap(
      query.docs.first.data() as Map<String, dynamic>,
    );

    if (group.membersIds.contains(_currentUserId)) {
      throw Exception('You are already a member of this group.');
    }

    await _firestore.collection('workspaces').doc(group.id).update({
      'membersIds': FieldValue.arrayUnion([_currentUserId]),
    });

    return GroupModel.fromMap({
      ...group.toMap(),
      'membersIds': [...group.membersIds, _currentUserId],
    });
  }

  Future<void> leaveGroup({required String groupId}) async {
    if (groupId.isEmpty) throw Exception('No workspace to leave.');

    await _firestore.collection('workspaces').doc(groupId).update({
      'membersIds': FieldValue.arrayRemove([_currentUserId]),
    });
  }

  Future<void> deleteGroup({required String groupId}) async {
    if (groupId.isEmpty) throw Exception('No workspace to delete.');

    await _firestore.collection('workspaces').doc(groupId).delete();
  }

  Future<List<GroupModel>> fetchGroups() async {
    final query = await _firestore
        .collection('workspaces')
        .where('membersIds', arrayContains: _currentUserId)
        .get();

    return query.docs
        .map((doc) => GroupModel.fromMap(doc.data() as Map<String, dynamic>))
        .toList();
  }

  Future<GroupModel> getGroupById(String groupId) async {
    final doc = await _firestore.collection('workspaces').doc(groupId).get();
    if (!doc.exists) {
      throw Exception('Workspace with ID $groupId not found.');
    }
    return GroupModel.fromMap(doc.data() as Map<String, dynamic>);
  }
}
