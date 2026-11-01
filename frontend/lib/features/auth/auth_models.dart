class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String role;
  final String? phone;
  final String? avatarUrl;

  const UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    required this.role,
    this.phone,
    this.avatarUrl,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? 'GymOwner',
      phone: json['phone'],
      avatarUrl: json['avatarUrl'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'fullName': fullName,
    'email': email,
    'role': role,
    'phone': phone,
    'avatarUrl': avatarUrl,
  };
}

class TenantModel {
  final String id;
  final String name;
  final String slug;
  final String? logoUrl;
  final String subscriptionPlan;
  final int maxBranches;
  final int maxMembers;

  const TenantModel({
    required this.id,
    required this.name,
    required this.slug,
    this.logoUrl,
    required this.subscriptionPlan,
    required this.maxBranches,
    required this.maxMembers,
  });

  factory TenantModel.fromJson(Map<String, dynamic> json) {
    return TenantModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      slug: json['slug'] ?? '',
      logoUrl: json['logoUrl'],
      subscriptionPlan: json['subscriptionPlan'] ?? 'Starter',
      maxBranches: json['maxBranches'] ?? 5,
      maxMembers: json['maxMembers'] ?? 1000,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'logoUrl': logoUrl,
    'subscriptionPlan': subscriptionPlan,
    'maxBranches': maxBranches,
    'maxMembers': maxMembers,
  };
}

class BranchModel {
  final String id;
  final String name;
  final String code;
  final String? address;
  final String? city;

  const BranchModel({
    required this.id,
    required this.name,
    required this.code,
    this.address,
    this.city,
  });

  factory BranchModel.fromJson(Map<String, dynamic> json) {
    return BranchModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      code: json['code'] ?? '',
      address: json['address'],
      city: json['city'],
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'address': address,
    'city': city,
  };
}

