import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes/data/services/notes_services.dart';
import 'notes/data/repositories/notes_repository.dart';
import 'notes/logic/bloc/notes_bloc.dart';
import 'notes/logic/bloc/notes_event.dart';
import 'notes/presentation/screens/note_list.dart';

void main() {
  final repository = NotesRepository(NotesService());
  runApp(MyApp(repository: repository));
}

class MyApp extends StatelessWidget {
  final NotesRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: BlocProvider(
        create: (_) => NotesBloc(repository)..add(const FetchNotesEvent()),
        child: const NoteList(),
      ),
    );
  }
}
