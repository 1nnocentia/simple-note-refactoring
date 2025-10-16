import 'package:flutter/material.dart';
import '../../data/models/notes_model.dart';
import '../widgets/note_form_widget.dart';

class UpdateNoteScreen extends StatelessWidget {
  final Notes note;
  const UpdateNoteScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return NoteFormWidget(note: note); 
  }
}
