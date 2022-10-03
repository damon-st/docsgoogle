import 'dart:convert';

// ignore_for_file: public_member_api_docs, sort_constructors_first
class DocumentModel {
  final String uid;
  final String title;
  final List content;
  final int createdAt;
  final String id;
  DocumentModel({
    required this.uid,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.id,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'title': title,
      'content': content,
      'createdAt': createdAt,
      'id': id,
    };
  }

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      uid: map['uid'] as String,
      title: map['title'] as String,
      content: List.from((map['content'] as List)),
      createdAt: map['createdAt'] as int,
      id: map['_id'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory DocumentModel.fromJson(String source) =>
      DocumentModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
