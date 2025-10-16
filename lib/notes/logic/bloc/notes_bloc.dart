import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/notes_repository.dart';
import '../../data/models/notes_model.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository repository;

  NotesBloc(this.repository) : super(const NotesState()) {
    on<FetchNotesEvent>(_onFetchNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteSelectedEvent>(_onDeleteSelected);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<SelectAllNotesEvent>(_onSelectAllNotes);
    on<ToggleNoteSelectionEvent>(_onToggleNoteSelection);
  }

  Future<void> _onFetchNotes(FetchNotesEvent event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final notes = await repository.getNotes();
      emit(state.copyWith(notes: notes, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await repository.add(event.title, event.body);
      add(const FetchNotesEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    try {
      await repository.update(event.id, event.title, event.body);
      add(const FetchNotesEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> _onDeleteSelected(DeleteSelectedEvent event, Emitter<NotesState> emit) async {
    try {
      for (var note in event.selectedNotes) {
        await repository.delete(note.id);
      }
      add(const FetchNotesEvent());
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  void _onToggleSelectionMode(ToggleSelectionModeEvent event, Emitter<NotesState> emit) {
    emit(state.copyWith(
      isSelectionMode: !state.isSelectionMode,
      selectedNotes: const {},
    ));
  }

  void _onSelectAllNotes(SelectAllNotesEvent event, Emitter<NotesState> emit) {
    if (state.isSelectionMode) {
      emit(state.copyWith(
        selectedNotes: Set<Notes>.from(state.notes),
      ));
    }
  }

  void _onToggleNoteSelection(ToggleNoteSelectionEvent event, Emitter<NotesState> emit) {
    if (!state.isSelectionMode) return;
    
    final currentSelection = Set<Notes>.from(state.selectedNotes);
    if (currentSelection.contains(event.note)) {
      currentSelection.remove(event.note);
    } else {
      currentSelection.add(event.note);
    }
    
    emit(state.copyWith(selectedNotes: currentSelection));
  }
}