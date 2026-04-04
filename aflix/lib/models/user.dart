class UserModel {
  final String token;
  final int? id;
  final String name, email, role, subscriptionType;

  const UserModel({
    required this.token, this.id,
    required this.name, required this.email,
    required this.role, required this.subscriptionType,
  });

  bool get isPremium => subscriptionType == 'PREMIUM';
  bool get isAdmin   => role == 'ADMIN';

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    token: j['token'] ?? '', id: j['id'],
    name: j['name'] ?? '', email: j['email'] ?? '',
    role: j['role'] ?? 'USER',
    subscriptionType: j['subscriptionType'] ?? 'FREE',
  );

  Map<String, dynamic> toJson() => {
    'token': token, 'id': id,
    'name': name, 'email': email,
    'role': role, 'subscriptionType': subscriptionType,
  };
}
