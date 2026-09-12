import 'dart:convert';

import 'package:flutter/widgets.dart';

class OnlineItem {
  final int id;
  final String title;
  final String content;
  final int userId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const OnlineItem({
    required this.id,
    required this.title,
    required this.content,
    required this.userId,
    this.createdAt,
    this.updatedAt,
  });

  factory OnlineItem.fromMap(Map<String, dynamic> map) {
    return OnlineItem(
      id: (map['id'] as num?)?.toInt() ?? 0,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      userId: (map['user_id'] as num?)?.toInt() ?? 0,
      createdAt: map['created_at'] != null
          ? DateTime.tryParse(map['created_at'].toString())
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.tryParse(map['updated_at'].toString())
          : null,
    );
  }

  OnlineItem copyWith({
    int? id,
    String? title,
    String? content,
    int? userId,
    ValueGetter<DateTime?>? createdAt,
    ValueGetter<DateTime?>? updatedAt,
  }) {
    return OnlineItem(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      userId: userId ?? this.userId,
      createdAt: createdAt != null ? createdAt() : this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'user_id': userId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  String toJson() => jsonEncode(toMap());

  factory OnlineItem.fromJson(String source) {
    return OnlineItem.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }

  @override
  String toString() {
    return 'OnlineItem('
        'id: $id, '
        'title: $title, '
        'content: $content, '
        'userId: $userId, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt'
        ')';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is OnlineItem &&
        other.id == id &&
        other.title == title &&
        other.content == content &&
        other.userId == userId &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(id, title, content, userId, createdAt, updatedAt);
  }
}
