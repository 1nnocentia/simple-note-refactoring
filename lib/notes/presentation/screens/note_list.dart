import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/notes_bloc.dart';
import '../../logic/bloc/notes_event.dart';
import '../../logic/bloc/notes_state.dart';
import 'add_note.dart';
import 'note_detail.dart';

class NoteList extends StatefulWidget {
  const NoteList({super.key});

  @override
  State<NoteList> createState() => _NoteListState();
}

class _NoteListState extends State<NoteList> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<NotesBloc, NotesState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error!),
              backgroundColor: Colors.orange,
            ),
          );
        }
      },
      child: BlocBuilder<NotesBloc, NotesState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }

          return Scaffold(
            appBar: AppBar(
              title: const Text('Notes'),
              actions: [
                if (!state.isSelectionMode)
                  IconButton(
                    icon: const Icon(Icons.select_all),
                    onPressed: () {
                      context.read<NotesBloc>().add(const ToggleSelectionModeEvent());
                      context.read<NotesBloc>().add(const SelectAllNotesEvent());
                    },
                  ),
                if (state.isSelectionMode) ...[
                  IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      context.read<NotesBloc>().add(const ToggleSelectionModeEvent());
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: state.selectedNotes.isEmpty ? null : () {
                      context
                          .read<NotesBloc>()
                          .add(DeleteSelectedEvent(selectedNotes: state.selectedNotes));
                    },
                  ),
                ],
              ],
            ),
            body: state.notes.isEmpty
                ? const Center(
                    child: Text('No notes yet. Tap + to add one.'),
                  )
                : ListView.builder(
                    itemCount: state.notes.length,
                    itemBuilder: (context, index) {
                      final note = state.notes[index];
                      final selected = state.selectedNotes.contains(note);

                      return ListTile(
                        title: Text(note.title),
                        subtitle: Text(note.body),
                        onTap: () {
                          if (state.isSelectionMode) {
                            context.read<NotesBloc>().add(ToggleNoteSelectionEvent(note: note));
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => NoteDetail(note: note),
                              ),
                            );
                          }
                        },
                        leading: state.isSelectionMode
                            ? Checkbox(
                                value: selected,
                                onChanged: (value) {
                                  context.read<NotesBloc>().add(ToggleNoteSelectionEvent(note: note));
                                },
                              )
                            : null,
                      );
                    },
                  ),
            floatingActionButton: FloatingActionButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddNote()),
              ),
              child: const Icon(Icons.add),
            ),
        );
        },
      ),
    );
  }
}
