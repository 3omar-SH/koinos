class GroupModel {
  final String id;
  final String name;
  final String groupCode;
  final String adminId;
  final List<String> membersIds;

  GroupModel({
    required this.id,
    required this.name,
    required this.groupCode,
    required this.adminId,
    required this.membersIds,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      groupCode: map['groupCode'] ?? '',
      adminId: map['adminId'] ?? '',
      membersIds: List<String>.from(map['membersIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'groupCode': groupCode,
      'adminId': adminId,
      'membersIds': membersIds,
    };
  }
}
