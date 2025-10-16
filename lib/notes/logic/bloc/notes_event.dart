import '../../data/models/notes_model.dart';

abstract class NotesEvent {
  const NotesEvent();
}

class FetchNotesEvent extends NotesEvent {
  const FetchNotesEvent();
}

class AddNoteEvent extends NotesEvent {
  final String title;
  final String body;
  
  const AddNoteEvent({required this.title, required this.body});
}

class UpdateNoteEvent extends NotesEvent {
  final int id;
  final String title;
  final String body;
  
  const UpdateNoteEvent({required this.id, required this.title, required this.body});
}

class DeleteSelectedEvent extends NotesEvent {
  final Set<Notes> selectedNotes;
  
  const DeleteSelectedEvent({required this.selectedNotes});
}

class ToggleSelectionModeEvent extends NotesEvent {
  const ToggleSelectionModeEvent();
}

class SelectAllNotesEvent extends NotesEvent {
  const SelectAllNotesEvent();
}

class ToggleNoteSelectionEvent extends NotesEvent {
  final Notes note;
  
  const ToggleNoteSelectionEvent({required this.note});
}
