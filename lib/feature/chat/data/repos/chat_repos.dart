import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Koinos/feature/chat/data/model/message_model.dart';

class ChatRepository {
  ChatRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  Stream<List<MessageModel>> streamMessages(String workspaceId) {
    return _firestore
        .collection('messages')
        .where('workspaceId', isEqualTo: workspaceId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList());
  }

  Future<void> sendMessage(MessageModel message) async {
    await _firestore.collection('messages').add(message.toMap());
  }

  Stream<List<MessageModel>> streamMessagesBySender(String workspaceId, String senderId) {
    return _firestore
        .collection('messages')
        .where('workspaceId', isEqualTo: workspaceId)
        .where('senderId', isEqualTo: senderId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MessageModel.fromMap(doc.data(), doc.id)).toList());
  }
}
