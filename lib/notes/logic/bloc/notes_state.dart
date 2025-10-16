import '../../data/models/notes_model.dart';

class NotesState {
  final List<Notes> notes;
  final bool isLoading;
  final String? error;
  final bool isSelectionMode;
  final Set<Notes> selectedNotes;

  const NotesState({
    this.notes = const [],
    this.isLoading = false,
    this.error,
    this.isSelectionMode = false,
    this.selectedNotes = const {},
  });

  NotesState copyWith({
    List<Notes>? notes,
    bool? isLoading,
    String? error,
    bool? isSelectionMode,
    Set<Notes>? selectedNotes,
  }) {
    return NotesState(
      notes: notes ?? this.notes,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      isSelectionMode: isSelectionMode ?? this.isSelectionMode,
      selectedNotes: selectedNotes ?? this.selectedNotes,
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
}
