import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'notes/data/services/notes_services.dart';
import 'notes/data/repositories/hybrid_notes_repository.dart';
import 'notes/logic/bloc/notes_bloc.dart';
import 'notes/logic/bloc/notes_event.dart';
import 'notes/presentation/screens/note_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final storageDirectory = kIsWeb 
      ? Directory.systemTemp.createTempSync('notes')
      : await getApplicationDocumentsDirectory();
  
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: storageDirectory,
  );

  final notesBloc = NotesBloc(HybridNotesRepository(NotesService()));
  notesBloc.add(const FetchNotesEvent());

  runApp(BlocProvider.value(
    value: notesBloc,
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const NoteList(),
    );
  }
}
