import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:my_notes/models/notes_models.dart';

class DatabaseHandler {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static String getUserId() {
    return _auth.currentUser!.uid;
  }

  static CollectionReference getUserNotesCollection() {
    return _firestore.collection('users').doc(getUserId()).collection('notes');
  }

  static CollectionReference getUserCategoriesCollection() {
    return _firestore
        .collection('users')
        .doc(getUserId())
        .collection('categories');
  }

  // Method to create a new note in Firestore
  static Future<void> createNotes(NotesModel note) async {
    final id = getUserNotesCollection().doc().id;
    final newNote = NotesModel(
      id: id,
      title: note.title,
      body: note.body,
      category: note.category,
      imageUrls: note.imageUrls,
      videoUrls: note.videoUrls,
    ).toDocument();

    try {
      await getUserNotesCollection().doc(id).set(newNote);
    } catch (e) {
      print("Error creating note: $e");
    }
  }

  // Method to update an existing note in Firestore
  static Future<void> updateNote(NotesModel note) async {
    try {
      await getUserNotesCollection().doc(note.id).update(note.toDocument());
    } catch (e) {
      print("Error updating note: $e");
    }
  }

  // Method to fetch all notes from Firestore as a stream
  static Stream<List<NotesModel>> getNotes() {
    return getUserNotesCollection().snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) {
        return NotesModel.fromSnapshot(doc);
      }).toList();
    });
  }

  // Method to delete a note from Firestore
  static Future<void> deleteNote(String id) async {
    try {
      await getUserNotesCollection().doc(id).delete();
    } catch (e) {
      print("Error deleting note: $e");
    }
  }

  // Method to upload categories to Firestore
  static Future<void> uploadCategories(List<String> categories) async {
    try {
      final batch = _firestore.batch();
      for (String category in categories) {
        final categoryDocRef =
            getUserCategoriesCollection().doc(category.toLowerCase());
        batch.set(categoryDocRef, {'name': category});
      }
      await batch.commit();
      print('Categories uploaded successfully.');
    } catch (e) {
      print('Error uploading categories: $e');
    }
  }

  // Method to fetch categories from Firestore
  static Stream<List<String>> getCategories() {
    return getUserCategoriesCollection().snapshots().map((querySnapshot) {
      return querySnapshot.docs.map((doc) => doc['name'] as String).toList();
    });
  }
}
