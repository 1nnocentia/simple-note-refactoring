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

  Future<void> addNote(String title, String body) async {
    await http.post(
      Uri.parse(baseUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'title': title, 'body': body}),
    );
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