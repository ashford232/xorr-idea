import 'dart:convert';

class UserModel {
  final String email;
  final String? username;
  final String? photoUrl;
  final int? uid;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'email': email,
      'username': username,
      'photo_url': photoUrl,
      'uid': uid,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      email: map['email'] as String,
      username: map['username'] != null ? map['username'] as String : null,
      photoUrl: map['photo_url'] != null ? map['photo_url'] as String : null,
      uid: map['uid'] != null ? map['uid'] as int : null,
      createdAt: map['created_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int)
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source) as Map<String, dynamic>);

  new({
    required this.email,
    required this.username,
    required this.photoUrl,
    required this.uid,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  bool operator ==(covariant UserModel other) {
    if (identical(this, other)) return true;

    return other.email == email &&
        other.username == username &&
        other.photoUrl == photoUrl &&
        other.uid == uid &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return email.hashCode ^
        username.hashCode ^
        photoUrl.hashCode ^
        uid.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
