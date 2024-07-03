import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:my_notes/database/dabase_handler.dart';
import 'package:my_notes/models/notes_models.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class EditNotePage extends StatefulWidget {
  final NotesModel notesModel;

  const EditNotePage({
    super.key,
    required this.notesModel,
  });

  @override
  State<EditNotePage> createState() => _EditNotePageState();
}

class _EditNotePageState extends State<EditNotePage> {
  TextEditingController? _titleController;
  TextEditingController? _engTextController;
  bool _isNoteEditing = false;

  @override
  void initState() {
    _titleController = TextEditingController(
      text: widget.notesModel.title,
    );
    _engTextController = TextEditingController(
      text: widget.notesModel.body,
    );
    super.initState();
  }

  @override
  void dispose() {
    _titleController!.dispose();
    _engTextController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _editNote();
          Navigator.pop(context);
        },
        backgroundColor: Colors.grey.shade700,
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isNoteEditing,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _isNoteEditing
                ? const Icon(
                    Icons.hourglass_empty,
                    size: 40,
                  )
                : Container(),
            ListView(
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.location_on),
                          onPressed: () {},
                        ),
                        const SizedBox(width: 2),
                        IconButton(
                          icon: const Icon(Icons.share),
                          onPressed: () async {
                            String title = _titleController!.text;
                            String text = _engTextController!.text;
                            List<String>? imageUrls =
                                widget.notesModel.imageUrls;

                            // Build the content to be shared
                            StringBuffer content = StringBuffer();
                            if (title.isNotEmpty) {
                              content.writeln("Title: $title\n");
                            }
                            if (text.isNotEmpty) {
                              content.writeln("Text: $text\n");
                            }
                            if (imageUrls != null && imageUrls.isNotEmpty) {
                              content.writeln("Images:\n");
                              for (String url in imageUrls) {
                                content.writeln(url);
                              }
                            }

                            // Share the content
                            await Share.share(content.toString());
                          },
                        ),
                        const SizedBox(width: 20),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15),
                      child: TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          hintText: "Title",
                          hintStyle: TextStyle(fontSize: 30),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: TextField(
                        controller: _engTextController,
                        maxLines: 6,
                        decoration: const InputDecoration(
                          hintText: "Start Typing...",
                          hintStyle: TextStyle(fontSize: 20),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Photos"),
                          const SizedBox(height: 5),
                          if (widget.notesModel.imageUrls!.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: widget.notesModel.imageUrls!.length,
                              itemBuilder: (context, index) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    widget.notesModel.imageUrls![index],
                                    height: 190,
                                    width: 140,
                                    fit: BoxFit.fill,
                                  ),
                                );
                              },
                            ),
                          const SizedBox(height: 15),
                          const Text("Videos"),
                          const SizedBox(height: 10),
                          if (widget.notesModel.videoUrls != null &&
                              widget.notesModel.videoUrls!.isNotEmpty)
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemCount: widget.notesModel.videoUrls!.length,
                              itemBuilder: (context, index) {
                                return VideoPlayerWidget(
                                  videoUrl: widget.notesModel.videoUrls![index],
                                );
                              },
                            ),
                          const SizedBox(height: 15),
                          const Text("Audio"),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.mic),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.mic),
                                onPressed: () {},
                              ),
                              IconButton(
                                icon: const Icon(Icons.mic),
                                onPressed: () {},
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _editNote() {
    setState(() {
      _isNoteEditing = true;
    });
    Future.delayed(const Duration(milliseconds: 1000)).then((value) {
      if (_titleController!.text.isEmpty) {
        Fluttertoast.showToast(msg: "Enter Title");
        setState(() {
          _isNoteEditing = false;
        });
        return;
      }
      if (_engTextController!.text.isEmpty) {
        Fluttertoast.showToast(msg: "Try Something");
        setState(() {
          _isNoteEditing = false;
        });
        return;
      }
      DatabaseHandler.updateNote(
        NotesModel(
          id: widget.notesModel.id,
          title: _titleController!.text,
          body: _engTextController!.text,
          category: widget.notesModel.category,
          imageUrls: widget.notesModel.imageUrls,
          videoUrls: widget.notesModel.videoUrls,
        ),
      ).then((value) {
        setState(() {
          _isNoteEditing = false;
        });
        Navigator.pop(context);
      });
    });
  }
}

class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _controller.value.isInitialized
        ? AspectRatio(
            aspectRatio: _controller.value.aspectRatio,
            child: VideoPlayer(_controller),
          )
        : const Center(child: CircularProgressIndicator());
  }
}
