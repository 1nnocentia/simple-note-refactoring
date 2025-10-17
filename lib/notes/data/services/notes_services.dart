import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/notes_model.dart';

class NotesService {
  final String baseUrl = 'http://localhost:8080/notes';

  Future<List<Notes>> fetchNotes() async {
    final response = await http.get(Uri.parse(baseUrl));
    if (response.statusCode == 200) {
      List<dynamic> json = jsonDecode(response.body);
      return json.map((note) => Notes(
        id: note['id'],
        title: note['title'],
        body: note['body'],
      )).toList();
    } else {
      throw Exception('Failed to load notes');
    }
  }

  /// Attempts to create a note on the server.
  /// Returns the created [Notes] if the server responds with the created object.
  /// Returns null if the server responded without a body but the request succeeded.
  Future<Notes?> addNote(String title, String body) async {
    final response = await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'body': body}),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      if (response.body.isNotEmpty) {
        final note = jsonDecode(response.body);
        return Notes(id: note['id'], title: note['title'], body: note['body']);
      }
      return null;
    }

    throw Exception('Failed to create note (status: ${response.statusCode})');
  }

  Future<void> updateNote(int id, String title, String body) async {
    await http.put(
      Uri.parse('$baseUrl/$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'id': id, 'title': title, 'body': body}),
    );
  }

  Future<void> deleteNote(int id) async {
    await http.delete(Uri.parse('$baseUrl/$id'));
  }
}