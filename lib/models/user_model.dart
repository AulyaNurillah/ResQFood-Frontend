class UserModel {
  final String id;
  final String email;
  final String fullName;
  final List<String> roles;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.roles,
  });

  factory UserModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return UserModel(
      id: json["id"] ?? "",
      email: json["email"] ?? "",
      fullName: json["fullName"] ?? "",

      roles: List<String>.from(
        json["roles"] ?? [],
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "email": email,
      "fullName": fullName,
      "roles": roles,
    };
  }
}