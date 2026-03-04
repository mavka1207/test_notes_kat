import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note/note.dart'; // локальный пакет ../package/note

String formatNoteDate(String isoString) {
  final dateTime = DateTime.parse(isoString);
  final now = DateTime.now();

  final isSameDay =
      dateTime.year == now.year &&
      dateTime.month == now.month &&
      dateTime.day == now.day;

  if (isSameDay) {
    return DateFormat.Hm().format(dateTime); // 14:38
  } else {
    return DateFormat('yyyy-MM-dd').format(dateTime); // 2026-03-04
  }
}

void main() {
  
  runApp(const SecureNotesMiniApp());
}

class SecureNotesMiniApp extends StatelessWidget {
  const SecureNotesMiniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Secure Notes Mini',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const NotesListScreen(),
    );
  }
}

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  final NotesDatabase _db = NotesDatabase();
  List<Note> _notes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _db.database; // init database
    await _loadNotes();
  }

  Future<void> _loadNotes() async {
    final notes = await _db.getAllNotes();
    setState(() {
      _notes = notes;
      _isLoading = false;
    });
  }

  Future<void> _addOrEditNote({Note? existing}) async {
    final result = await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => EditNoteScreen(note: existing)));

    if (result == null) return;

    if (result == 'delete') {
      if (existing != null) {
        await _db.deleteNote(note: existing);
        await _loadNotes();
      }
      return;
    }

    if (result is Note) {
      if (existing == null) {
        await _db.addNote(note: result);
      } else {
        await _db.updateNote(oldNote: existing, newNote: result);
      }
      await _loadNotes();
    }
  }

  Future<void> _deleteAll() async {
    await _db.deleteAllNotes();
    await _loadNotes();
  }

  Future<void> _confirmDeleteAll() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete all notes?'),
        content: const Text('Do you want to remove all notes?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete all'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      await _deleteAll();
    }
  }

  @override
  Widget build(BuildContext context) {
  

    return Scaffold(
      appBar: AppBar(
        title: const Text('Secure Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _notes.isEmpty ? null : _confirmDeleteAll,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _notes.isEmpty
                ? const Center(child: Text('No notes yet'))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return ListTile(
                        title: Text(note.title),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              note.body,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              formatNoteDate(note.date),
                              style: Theme.of(context).textTheme.labelSmall
                                  ?.copyWith(color: Colors.grey),
                            ),
                          ],
                        ),
                        onTap: () => _addOrEditNote(existing: note),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addOrEditNote(),
        child: const Icon(Icons.add),
      ),
    );
  }

  @override
  void dispose() {
    _db.close();
    super.dispose();
  }
}

class EditNoteScreen extends StatefulWidget {
  final Note? note;

  const EditNoteScreen({super.key, this.note});

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _bodyController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title ?? '');
    _bodyController = TextEditingController(text: widget.note?.body ?? '');
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final note = Note(
      id: widget.note?.id,
      title: _titleController.text.trim(),
      body: _bodyController.text.trim(),
      date: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(note);
  }

  Future<void> _confirmDelete() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete note?'),
        content: const Text('Do you want to remove this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      Navigator.of(context).pop('delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.note != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit note' : 'Add note'),
        actions: [
          if (isEditing)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _confirmDelete,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _bodyController,
                  decoration: const InputDecoration(labelText: 'Body'),
                  maxLines: null,
                  expands: true,
                  keyboardType: TextInputType.multiline,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Body is required';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: 200,
                child: ElevatedButton(
                  onPressed: _save,
                  child: Text(isEditing ? 'Save changes' : 'Add note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }
}
