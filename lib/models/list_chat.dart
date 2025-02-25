class ListChatData {
  const ListChatData({
    required this.uid,
    required this.username,
    required this.email,
    required this.createAt,
    required this.isRead,
  });
  final String uid;
  final String username;
  final String email;
  final bool isRead;
  final DateTime createAt;
  Map<String, dynamic> getListChatData() {
    return {
      "username": username,
      "email": email,
      "is_read": isRead,
      "create_at": createAt,
    };
  }
}
