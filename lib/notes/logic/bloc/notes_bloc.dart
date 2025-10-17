import 'dart:async';

import 'package:hydrated_bloc/hydrated_bloc.dart';
import '../../data/repositories/hybrid_notes_repository.dart';
import '../../data/models/notes_model.dart';
import 'notes_event.dart';
import 'notes_state.dart';
import '../../data/models/pending_operation.dart';

class NotesBloc extends HydratedBloc<NotesEvent, NotesState> {
  final HybridNotesRepository repository;
  Timer? _retryTimer;
  bool _isProcessing = false;

  NotesBloc(this.repository) : super(const NotesState()) {
    on<FetchNotesEvent>(_onFetchNotes);
    on<AddNoteEvent>(_onAddNote);
    on<UpdateNoteEvent>(_onUpdateNote);
    on<DeleteSelectedEvent>(_onDeleteSelected);
    on<ProcessPendingQueueEvent>(_onProcessPendingQueue);
    on<ToggleSelectionModeEvent>(_onToggleSelectionMode);
    on<SelectAllNotesEvent>(_onSelectAllNotes);
    on<ToggleNoteSelectionEvent>(_onToggleNoteSelection);

    _retryTimer = Timer.periodic(const Duration(seconds: 10), (_) async {
      try {
        if (_isProcessing) return;
        if (state.pendingOperations.isEmpty) return;
        _isProcessing = true;
        final available = await repository.isBackendAvailable();
        if (available) {
          add(const ProcessPendingQueueEvent());
        }
      } finally {
        _isProcessing = false;
      }
    });
  }

  @override
  Future<void> close() {
    _retryTimer?.cancel();
    return super.close();
  }

  Future<void> _onFetchNotes(FetchNotesEvent event, Emitter<NotesState> emit) async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final notes = await repository.getNotes();
  final merged = _mergeServerAndLocal(notes, state.notes);
  emit(state.copyWith(notes: merged, isLoading: false));
      add(const ProcessPendingQueueEvent());
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: 'Using offline mode'));
    }
  }

  Future<void> _onAddNote(AddNoteEvent event, Emitter<NotesState> emit) async {
    final newNote = repository.createNote(event.title, event.body);
    final updatedNotes = [...state.notes, newNote];
    emit(state.copyWith(notes: updatedNotes));

    try {
      final created = await repository.addNote(event.title, event.body);
      if (created != null) {
        // replace temp note with server-created note
        final replaced = updatedNotes.map((n) => n.id == newNote.id ? created : n).toList();
        emit(state.copyWith(notes: replaced));
      }
    } catch (e) {
      final op = PendingOperation(type: 'add', note: newNote.toJson());
      final pending = [...state.pendingOperations, op];
      emit(state.copyWith(error: 'Note saved locally (offline mode)', pendingOperations: pending));
    }
  }

  Future<void> _onUpdateNote(UpdateNoteEvent event, Emitter<NotesState> emit) async {
    final updatedNotes = state.notes.map((note) {
      if (note.id == event.id) {
        return note.copyWith(title: event.title, body: event.body);
      }
      return note;
    }).toList();
    emit(state.copyWith(notes: updatedNotes));

    try {
      await repository.update(event.id, event.title, event.body);
    } catch (e) {
      final updatedNote = updatedNotes.firstWhere((n) => n.id == event.id);
      final op = PendingOperation(type: 'update', note: updatedNote.toJson());
      final pending = [...state.pendingOperations, op];
      emit(state.copyWith(error: 'Note updated locally (offline mode)', pendingOperations: pending));
    }
  }

  Future<void> _onDeleteSelected(DeleteSelectedEvent event, Emitter<NotesState> emit) async {
    final remainingNotes = state.notes.where((note) => 
        !event.selectedNotes.contains(note)).toList();
    emit(state.copyWith(
      notes: remainingNotes,
      selectedNotes: const {},
      isSelectionMode: false,
    ));

    try {
      for (var note in event.selectedNotes) {
        await repository.delete(note.id);
      }
    } catch (e) {
      final deletes = event.selectedNotes.map((n) => PendingOperation(type: 'delete', note: n.toJson()));
      final pending = [...state.pendingOperations, ...deletes];
      emit(state.copyWith(error: 'Notes deleted locally (offline mode)', pendingOperations: pending));
    }
  }

  Future<void> _onProcessPendingQueue(ProcessPendingQueueEvent event, Emitter<NotesState> emit) async {
    if (state.pendingOperations.isEmpty) return;

    final remaining = <PendingOperation>[];
    var notesMutable = List<Notes>.from(state.notes);

    for (var op in state.pendingOperations) {
      try {
        final noteJson = op.note;
        if (op.type == 'add') {
          final created = await repository.addNote(noteJson['title'] as String, noteJson['body'] as String);
          if (created != null) {
            final tempId = noteJson['id'] as int;
            // replace temp id with server id in local notes
            notesMutable = notesMutable.map((n) => n.id == tempId ? created : n).toList();
            // update any pending operations (in-place) that reference the temp id
            for (var p in state.pendingOperations) {
              if (p.note['id'] == tempId) p.note['id'] = created.id;
            }
          }
        } else if (op.type == 'update') {
          await repository.update(noteJson['id'] as int, noteJson['title'] as String, noteJson['body'] as String);
        } else if (op.type == 'delete') {
          await repository.delete(noteJson['id'] as int);
        }
      } catch (e) {
        remaining.add(op);
      }
    }

    // emit once with updated notes and pending queue
    if (remaining.length != state.pendingOperations.length || notesMutable != state.notes) {
      emit(state.copyWith(notes: notesMutable, pendingOperations: remaining, error: remaining.isEmpty ? null : state.error));
    }
  }

  List<Notes> _mergeServerAndLocal(List<Notes> server, List<Notes> local) {
    final Map<int, Notes> map = {for (var n in server) n.id: n};
    for (var n in local) {
      if (!map.containsKey(n.id)) map[n.id] = n;
    }
    return map.values.toList();
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

  @override
  NotesState? fromJson(Map<String, dynamic> json) {
    try {
      return NotesState.fromJson(json);
    } catch (e) {
      return const NotesState();
    }
  }

  @override
  Map<String, dynamic>? toJson(NotesState state) {
    try {
      return state.toJson();
    } catch (e) {
      return null;
    }
  }
}