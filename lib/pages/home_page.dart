import 'package:anim_search_bar/anim_search_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:my_notes/components/my_button.dart';
import 'package:my_notes/components/my_drawer.dart';
import 'package:my_notes/components/my_sliver_app_bar.dart';
import 'package:my_notes/database/dabase_handler.dart';
import 'package:my_notes/localization/locals.dart';
import 'package:my_notes/models/notes_models.dart';
import 'package:my_notes/pages/edit_note_page.dart';
import 'package:my_notes/pages/notes_page.dart';
import 'package:permission_handler/permission_handler.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<NotesModel> notes = [];
  late String formattedDate;
  TextEditingController searchController = TextEditingController();
  List<NotesModel> selectedNotes = []; // Track selected notes

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    formattedDate = DateFormat('yMd').format(now);
    requestPermissions();
    // Fetch initial notes
    fetchNotes();
  }

  Future<void> requestPermissions() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      status = await Permission.storage.request();
      if (!status.isGranted) {
        print('Storage permission is not granted');
      }
    }
  }

  Future<void> fetchNotes() async {
    DatabaseHandler.getNotes().listen((snapshot) {
      setState(() {
        notes = snapshot;
      });
    });
  }

  void _onTap(NotesModel note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditNotePage(notesModel: note),
      ),
    );
  }

  void searchNotes(String query) {
    if (query.isNotEmpty) {
      setState(() {
        notes = notes
            .where((note) =>
                note.title.toLowerCase().contains(query.toLowerCase()))
            .toList();
      });
    } else {
      fetchNotes(); // Reset to all notes if query is empty
    }
  }

  void _deleteSelectedNotes() async {
    for (var note in selectedNotes) {
      await DatabaseHandler.deleteNote(note.id!);
      notes.remove(note);
    }
    setState(() {
      selectedNotes.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: const MyDrawer(),
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          MySliverAppBar(
            title: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 5),
                    child: AnimSearchBar(
                      boxShadow: false,
                      width: 200,
                      textController: searchController,
                      onSuffixTap: () {
                        searchNotes(searchController.text);
                      },
                      onSubmitted: (value) {
                        searchNotes(value);
                      },
                    ),
                  ),
                  Text(
                    LocalData.title.getString(context),
                    style: const TextStyle(color: Colors.black),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 35.0),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotesPage(),
                          ),
                        );
                      },
                      child: const Icon(Icons.add),
                    ),
                  ),
                ],
              ),
            ),
            child: const Text(""),
          ),
        ],
        body: Column(
          children: [
            Flexible(
              child: notes.isEmpty
                  ? _noNotesWidget()
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        columns: _buildColumns(context),
                        rows: _buildRows(notes),
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: selectedNotes.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: _deleteSelectedNotes,
              icon: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
              label: Text(
                'Delete Selected',
                style: GoogleFonts.poppins(
                  color: Colors.white,
                ),
              ),
              backgroundColor: const Color.fromARGB(255, 21, 8, 52),
            )
          : null,
    );
  }

  Widget _noNotesWidget() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.note,
            size: 60,
            color: Colors.white,
          ),
          SizedBox(height: 20),
          Text(
            "No notes found",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn> _buildColumns(BuildContext context) {
    return [
      DataColumn(
        label: Text(
          LocalData.category.getString(context),
          style: GoogleFonts.poppins(),
        ),
      ),
      DataColumn(
          label: Text(LocalData.title.getString(context),
              style: GoogleFonts.poppins())),
      DataColumn(
          label: Text(LocalData.note.getString(context),
              style: GoogleFonts.poppins())),
      DataColumn(
          label: Text(LocalData.image.getString(context),
              style: GoogleFonts.poppins())),
      DataColumn(
          label: Text(LocalData.date.getString(context),
              style: GoogleFonts.poppins())),
    ];
  }

  List<DataRow> _buildRows(List<NotesModel> notes) {
    return notes.map((note) {
      final isSelected = selectedNotes.contains(note);
      return DataRow(
        selected: isSelected,
        onSelectChanged: (isSelected) {
          _onTap(note);
        },
        cells: [
          _buildDataCell(note.displayCategory ?? ''), // Display category here
          _buildDataCell(note.title ?? ''),
          _buildDataCell(note.body ?? ''),
          DataCell(
            note.imageUrls != null && note.imageUrls!.isNotEmpty
                ? Image.network(
                    note.imageUrls!.first,
                    width: 100,
                    height: 50,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) {
                      return progress == null
                          ? child
                          : const CircularProgressIndicator();
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  )
                : const Text('No Image'),
          ),
          _buildDataCell(formattedDate),
        ],
        onLongPress: () {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              backgroundColor: Colors.white,
              title: Text(
                LocalData.deleteConfirmation.getString(context),
                style: GoogleFonts.poppins(),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    myButton(
                      LocalData.no.getString(context),
                      Colors.white,
                      () {
                        Navigator.pop(context);
                      },
                      Colors.black,
                    ),
                    myButton(
                      LocalData.yes.getString(context),
                      const Color(0xFF150035),
                      () async {
                        await DatabaseHandler.deleteNote(note.id!);
                        setState(() {
                          notes.remove(note);
                          selectedNotes.remove(note);
                        });
                        Navigator.pop(context);
                      },
                      Colors.white,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      );
    }).toList();
  }

  DataCell _buildDataCell(String text) {
    return DataCell(
      Container(
        alignment: Alignment.centerLeft,
        width: 80, // Adjust width as per your requirement
        child: Text(
          text,
          style: GoogleFonts.poppins(),
          textAlign: TextAlign.left,
          overflow: TextOverflow.ellipsis,
          maxLines: 2, // Limit to 2 lines and use ellipsis for overflow
        ),
      ),
    );
  }
}
