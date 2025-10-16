import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../logic/bloc/notes_bloc.dart';
import '../../logic/bloc/notes_event.dart';
import '../../logic/bloc/notes_state.dart';
import 'add_note.dart';
import 'note_detail.dart';

class NoteList extends StatelessWidget {
  const NoteList({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotesBloc, NotesState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Note List'),
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
          body: ListView.builder(
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
    );
  }
}
