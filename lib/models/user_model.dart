class User {
  final String id;
  final String name;
  final String email;
  final String? phoneNumber;
  final String role; // 'admin', 'employee', 'student'
  final String? department;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;
  final String? profileImagePath;
  final String? organizationId; // For multi-tenant support

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
    required this.role,
    this.department,
    required this.createdAt,
    this.updatedAt,
    this.isActive = true,
    this.profileImagePath,
    this.organizationId,
  });

  // Convert to Map for database
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone_number': phoneNumber,
      'role': role,
      'department': department,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_active': isActive ? 1 : 0,
      'profile_image_path': profileImagePath,
      'organization_id': organizationId,
    };
  }

  // Create from Map
  factory User.fromMap(Map<String, dynamic> map) {
    // Handle both database format and API format
    final id = map['_id']?.toString() ?? map['id']?.toString() ?? '';
    final createdAt = map['createdAt'] != null 
        ? DateTime.parse(map['createdAt'] as String)
        : (map['created_at'] != null 
            ? DateTime.parse(map['created_at'] as String)
            : DateTime.now());
    final updatedAt = map['updatedAt'] != null
        ? DateTime.parse(map['updatedAt'] as String)
        : (map['updated_at'] != null
            ? DateTime.parse(map['updated_at'] as String)
            : null);
    final isActive = map['isActive'] ?? 
                     (map['is_active'] != null ? (map['is_active'] as int) == 1 : true);
    
    return User(
      id: id,
      name: map['name'] as String,
      email: map['email'] as String,
      phoneNumber: map['phoneNumber'] ?? map['phone_number'] as String?,
      role: map['role'] as String,
      department: map['department'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isActive: isActive as bool,
      profileImagePath: map['profileImageUrl'] ?? map['profile_image_path'] as String?,
      organizationId: map['organizationId']?.toString() ?? map['organization_id']?.toString(),
    );
  }

  // Copy with method
  User copyWith({
    String? id,
    String? name,
    String? email,
    String? phoneNumber,
    String? role,
    String? department,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isActive,
    String? profileImagePath,
    String? organizationId,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      role: role ?? this.role,
      department: department ?? this.department,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isActive: isActive ?? this.isActive,
      profileImagePath: profileImagePath ?? this.profileImagePath,
      organizationId: organizationId ?? this.organizationId,
    );
  }
}

