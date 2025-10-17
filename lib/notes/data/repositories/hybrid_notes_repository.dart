import '../models/notes_model.dart';
import '../services/notes_services.dart';

class HybridNotesRepository {
  final NotesService httpService;

  HybridNotesRepository(this.httpService);

  Future<List<Notes>> getNotes() async {
    try {
      return await httpService.fetchNotes();
    } catch (e) {
      // Let callers (the Bloc) decide how to handle fetch errors.
      // If we return an empty list here, the Bloc will overwrite any
      // previously persisted notes (HydratedBloc) with an empty list.
      // Rethrowing preserves the existing state and allows the UI to
      // fall back to the locally persisted notes.
      rethrow;
    }
  }

  Future<void> addNote(String title, String body) async {
    try {
      await httpService.addNote(title, body);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> update(int id, String title, String body) async {
    try {
      await httpService.updateNote(id, title, body);
    } catch (e) {
      rethrow;
    }
  }  Future<void> delete(int id) async {
    try {
      await httpService.deleteNote(id);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isBackendAvailable() async {
    try {
      await httpService.fetchNotes();
      return true;
    } catch (e) {
      return false;
    }
  }

  Notes createNote(String title, String body) {
    return Notes(
      id: DateTime.now().millisecondsSinceEpoch,
      title: title,
      body: body,
    );
  }
}
