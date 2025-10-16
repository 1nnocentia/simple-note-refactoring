import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/notes_model.dart';
import '../../logic/bloc/notes_bloc.dart';
import '../../logic/bloc/notes_event.dart';

class NoteFormWidget extends StatefulWidget {
  final Notes? note;
  const NoteFormWidget({super.key, this.note});

  @override
  State<NoteFormWidget> createState() => _NoteFormWidgetState();
}

class _NoteFormWidgetState extends State<NoteFormWidget> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _contentController = TextEditingController(text: widget.note?.body ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final body = _contentController.text.trim();

    if (title.isEmpty || body.isEmpty) return;

    if (widget.note == null) {
      context.read<NotesBloc>().add(AddNoteEvent(title: title, body: body));
    } else {
      context.read<NotesBloc>().add(UpdateNoteEvent(id: widget.note!.id, title: title, body: body));
    }
    
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isUpdate = widget.note != null;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isUpdate ? 'Edit Note' : 'Add Note'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(labelText: 'Content'),
              maxLines: null,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveNote,
              child: Text(isUpdate ? 'Save Changes' : 'Save Note'),
            ),
          ],
        ),
      ),
    );
  }
}