class UserData {
  const UserData({
    required this.uid,
    required this.username,
    required this.role,
    required this.email,
    required this.avatar,
  });
  final String uid;

  final String username;
  final String role;
  final String email;
  final String avatar;
  Map<String, dynamic> getUserData() {
    return {
      "uid": uid,
      "username": username,
      "role": role,
      "email": email,
      "avatar": avatar,
    };
  }
}
