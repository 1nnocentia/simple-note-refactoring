import '../../data/models/notes_model.dart';
import '../../data/models/pending_operation.dart';

class NotesState {
  final List<Notes> notes;
  final bool isLoading;
  final String? error;
  final bool isSelectionMode;
  final Set<Notes> selectedNotes;
  final List<PendingOperation> pendingOperations;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
    this.isSelectionMode = false,
    this.selectedNotes = const {},
    this.pendingOperations = const [],
  });

  NotesState copyWith({
    List<Notes>? notes,
    bool? isLoading,
    String? error,
    bool? isSelectionMode,
    Set<Notes>? selectedNotes,
    List<PendingOperation>? pendingOperations,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedNotes: selectedNotes ?? this.selectedNotes,
      pendingOperations: pendingOperations ?? this.pendingOperations,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is NotesState &&
        other.notes == notes &&
        other.isLoading == isLoading &&
        other.error == error &&
        other.isSelectionMode == isSelectionMode &&
        other.selectedNotes == selectedNotes;
  }

  @override
  int get hashCode => notes.hashCode ^ 
      isLoading.hashCode ^ 
      error.hashCode ^ 
      isSelectionMode.hashCode ^ 
      selectedNotes.hashCode;

  @override
  String toString() => 'NotesState(notes: $notes, isLoading: $isLoading, error: $error, isSelectionMode: $isSelectionMode, selectedNotes: $selectedNotes)';

  Map<String, dynamic> toJson() {
    return {
      'notes': notes.map((note) => note.toJson()).toList(),
      'isLoading': isLoading,
      'error': error,
      'isSelectionMode': isSelectionMode,
      'selectedNotes': selectedNotes.map((note) => note.toJson()).toList(),
      'pendingOperations': pendingOperations.map((op) => op.toJson()).toList(),
    };
  }

  static NotesState fromJson(Map<String, dynamic> json) {
    return NotesState(
      notes: (json['notes'] as List<dynamic>?)
          ?.map((noteJson) => Notes.fromJson(noteJson as Map<String, dynamic>))
          .toList() ?? [],
      isLoading: json['isLoading'] as bool? ?? false,
      error: json['error'] as String?,
      isSelectionMode: json['isSelectionMode'] as bool? ?? false,
      selectedNotes: (json['selectedNotes'] as List<dynamic>?)
          ?.map((noteJson) => Notes.fromJson(noteJson as Map<String, dynamic>))
          .toSet() ?? {},
      pendingOperations: (json['pendingOperations'] as List<dynamic>?)
          ?.map((opJson) => PendingOperation.fromJson(opJson as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}
