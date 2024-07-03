import 'package:cloud_firestore/cloud_firestore.dart';

class NotesModel {
  final String? id;
  final String title;
  final String body;
  final String? category; // Raw category string
  final String? displayCategory; // Display name of the category
  final List<String>? imageUrls;
  final List<String>? videoUrls;

  NotesModel({
    this.id,
    required this.title,
    required this.body,
    this.category,
    this.displayCategory, // Updated constructor
    this.imageUrls,
    this.videoUrls,
  });

  factory NotesModel.fromSnapshot(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NotesModel(
      id: doc.id,
      title: data['title'] as String,
      body: data['body'] as String,
      category: data['category'] as String?,
      displayCategory:
          data['displayCategory'] as String?, // Fetch display category
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrls: List<String>.from(data['videoUrls'] ?? []),
    );
  }

  Map<String, dynamic> toDocument() {
    return {
      'title': title,
      'body': body,
      'category': category,
      'displayCategory': displayCategory, // Store display category in Firestore
      'imageUrls': imageUrls,
      'videoUrls': videoUrls,
    };
  }
}
