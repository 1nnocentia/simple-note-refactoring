import '../models/notes_model.dart';
import '../services/notes_services.dart';

class NotesRepository {
  final NotesService service;
  NotesRepository(this.service);

  Future<List<Notes>> getNotes() => service.fetchNotes();
  Future<void> add(String title, String body) => service.addNote(title, body);
  Future<void> update(int id, String title, String body) => service.updateNote(id, title, body);
  Future<void> delete(int id) => service.deleteNote(id);
}
