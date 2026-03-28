class User {
  final int id;
  final String username;
  final String? email;
  final String? firstName;
  final String? lastName;
  final bool isStaff;
  final bool isSuperuser;

  User({
    required this.id,
    required this.username,
    this.email,
    this.firstName,
    this.lastName,
    this.isStaff = false,
    this.isSuperuser = false,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      isStaff: json['is_staff'] ?? false,
      isSuperuser: json['is_superuser'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
    };
  }

  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    return username;
  }

  // Check if user is a branch user (staff member with view-only access)
  bool get isBranchUser => isStaff && !isSuperuser;

  // Check if user is a delegate (regular user, not staff)
  bool get isDelegate => !isStaff && !isSuperuser;
}
