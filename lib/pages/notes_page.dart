import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:my_notes/components/app_bar_components.dart';
import 'package:my_notes/database/dabase_handler.dart';
import 'package:my_notes/localization/locals.dart';
import 'package:my_notes/models/notes_models.dart';
import 'package:my_notes/preview/photos_preview.dart';
import 'package:my_notes/preview/video_preview.dart';
import 'package:my_notes/widgets/common_widgets.dart';
import 'package:my_notes/widgets/forms_widget.dart';
import 'package:record/record.dart';
import 'package:video_player/video_player.dart';

class NotesPage extends StatefulWidget {
  const NotesPage({
    super.key,
  });

  @override
  State<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends State<NotesPage> {
  String? _videoURL;
  String? _videoURL2;
  String? _videoURL3;
  String? _videoURL4;
  String? _videoURL5;

  VideoPlayerController? _videoPlayerController;
  VideoPlayerController? _videoPlayerController2;
  VideoPlayerController? _videoPlayerController3;
  VideoPlayerController? _videoPlayerController4;
  VideoPlayerController? _videoPlayerController5;
  Duration duration = const Duration();
  Duration position = const Duration();
  bool isPlaying = false;
  bool isLoading = false;
  bool isPause = false;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _engTextController = TextEditingController();

  bool _isNoteCreating = false;

  XFile? video;
  XFile? video2;
  XFile? video3;
  XFile? video4;
  XFile? video5;
  XFile? image;
  XFile? image2;
  XFile? image3;
  XFile? image4;
  XFile? image5;
  List<XFile?> videos = [null, null, null, null, null];
  List<VideoPlayerController?> videoControllers = [
    null,
    null,
    null,
    null,
    null
  ];
  List<String?> videoURLs = [null, null, null, null, null];

  late AudioRecorder audioRecord;
  late AudioPlayer audioPlayer;
  bool isRecording = false;

  @override
  void initState() {
    super.initState();
    audioPlayer = AudioPlayer();
    audioRecord = AudioRecorder();
  }

  // Method to upload video and get URL

  @override
  void dispose() {
    audioPlayer.dispose();
    audioRecord.dispose();
    _videoPlayerController?.dispose();
    _videoPlayerController2?.dispose();
    _videoPlayerController3?.dispose();
    _videoPlayerController4?.dispose();
    _videoPlayerController5?.dispose();
    _titleController.dispose();
    _engTextController.dispose();
    super.dispose();
  }

  // Modify the _createNote method to upload videos and save URLs
  _createNote() async {
    setState(() {
      _isNoteCreating = true;
    });

    List<String> videoUrls = [];
    if (_videoURL != null) videoUrls.add(_videoURL!);
    if (_videoURL2 != null) videoUrls.add(_videoURL2!);
    if (_videoURL3 != null) videoUrls.add(_videoURL3!);
    if (_videoURL4 != null) videoUrls.add(_videoURL4!);
    if (_videoURL5 != null) videoUrls.add(_videoURL5!);

    // Ensure all videos are uploaded and URLs are obtained before proceeding
    if (videoUrls.any((url) => url.isEmpty)) {
      Fluttertoast.showToast(msg: "Error uploading videos");
      setState(() {
        _isNoteCreating = false;
      });
      return;
    }

    if (_titleController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Enter Title");
      setState(() {
        _isNoteCreating = false;
      });
      return;
    }

    if (_engTextController.text.isEmpty) {
      Fluttertoast.showToast(msg: "Try Something");
      setState(() {
        _isNoteCreating = false;
      });
      return;
    }

    DatabaseHandler.createNotes(
      NotesModel(
        title: _titleController.text,
        body: _engTextController.text,
        videoUrls: videoUrls,
      ),
    ).then((value) {
      setState(() {
        _isNoteCreating = false;
      });
      Navigator.pop(context);
    });
  }

  // Function to pick image from gallery
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (pickedImage != null) {
        setState(() {
          if (image == null) {
            image = pickedImage;
          } else if (image2 == null) {
            image2 = pickedImage;
          } else if (image3 == null) {
            image3 = pickedImage;
          } else if (image4 == null) {
            image4 = pickedImage;
          } else if (image5 == null) {
            image5 = pickedImage;
          }
        });
      }
    } catch (e) {
      print('Error picking image from gallery: $e');
    }
  }

  // Function to pick image from camera
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage != null) {
        setState(() {
          if (image == null) {
            image = pickedImage;
          } else if (image2 == null) {
            image2 = pickedImage;
          } else if (image3 == null) {
            image3 = pickedImage;
          } else if (image4 == null) {
            image4 = pickedImage;
          } else if (image5 == null) {
            image5 = pickedImage;
          }
        });
      }
    } catch (e) {
      print('Error picking image from camera: $e');
    }
  }

  Future<String?> pickVideo(ImageSource source) async {
    final video = await ImagePicker().pickVideo(source: source);
    return video?.path;
  }

  Future<String> _uploadVideo(XFile video) async {
    try {
      FirebaseStorage storage = FirebaseStorage.instance;
      Reference ref = storage
          .ref()
          .child("notes_videos/${DateTime.now().millisecondsSinceEpoch}.mp4");

      UploadTask uploadTask = ref.putFile(File(video.path));
      TaskSnapshot taskSnapshot = await uploadTask;
      String downloadURL = await taskSnapshot.ref.getDownloadURL();
      return downloadURL;
    } catch (e) {
      print('Error uploading video: $e');
      return '';
    }
  }

  Future<void> _pickVideo(int index, ImageSource source) async {
    final pickedVideo = await ImagePicker()
        .pickVideo(source: source, maxDuration: const Duration(seconds: 10));
    if (pickedVideo != null) {
      setState(() {
        videos[index] = pickedVideo;
        _initializeVideoPlayer(index);
      });
      String url = await _uploadVideo(pickedVideo);
      setState(() {
        videoURLs[index] = url;
      });
    }
  }

  void _initializeVideoPlayer(int index) {
    VideoPlayerController controller =
        VideoPlayerController.file(File(videos[index]!.path));
    videoControllers[index] = controller;
    controller.initialize().then((_) {
      setState(() {});
      controller.play();
    });
  }

  void _navigateToPreview(String videoURL) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPreview(
          videoUrl: videoURL,
        ),
      ),
    );
  }

  Widget _videoPlayerPreview(
      VideoPlayerController? controller, String? videoUrl) {
    if (controller != null && videoUrl != null) {
      return GestureDetector(
        onTap: () => _navigateToPreview(videoUrl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            height: 160,
            width: 140,
            child: VideoPlayer(controller),
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Future<void> startRecording() async {
    try {
      if (await audioRecord.hasPermission()) {
        await audioRecord.start(
          const RecordConfig(),
          path: "",
        );
        setState(() {
          isRecording = true;
        });
        final path = await audioRecord.stop();
        await audioRecord.cancel();

        audioRecord.dispose();
      }
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    int totalItems = [
      image,
      image2,
      image3,
      image4,
      image5,
      _videoURL,
      _videoURL2,
      _videoURL3,
      _videoURL4,
      _videoURL5
    ].where((item) => item != null).length;

    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: _createNote,
        backgroundColor: Colors.grey.shade700,
        child: const Icon(
          Icons.check_rounded,
          color: Colors.white,
        ),
      ),
      body: AbsorbPointer(
        absorbing: _isNoteCreating,
        child: Stack(
          alignment: Alignment.center,
          children: [
            _isNoteCreating
                ? const Icon(
                    FluentIcons.circle_half_fill_24_regular,
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
                      child: AppbarButtons(
                        icon: Icons.arrow_back_ios_rounded,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                    ),
                    const Text(
                      "Location Credentials",
                    ),
                    Row(
                      children: [
                        AppbarButtons(
                          icon: FluentIcons.location_48_regular,
                          onTap: () {},
                        ),
                        const SizedBox(width: 2),
                      ],
                    ),
                  ],
                ),
                Column(
                  children: [
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(top: 10, left: 15),
                      child: FormWidget(
                        controller: _titleController,
                        hintText: LocalData.title.getString(context),
                        fontSize: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: FormWidget(
                        controller: _engTextController,
                        hintText: LocalData.body.getString(context),
                        maxLines: 6,
                        fontSize: 20,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              reuseableText(
                                LocalData.gallery.getString(context),
                              ),
                              reuseableText(
                                LocalData.camera.getString(context),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.photo_camera_back_outlined,
                                ),
                                onPressed: _pickImageFromGallery,
                              ),
                              IconButton(
                                icon: const Icon(
                                  FluentIcons.camera_28_regular,
                                ),
                                onPressed: _pickImageFromCamera,
                              ),
                            ],
                          ),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Image 1
                                if (image == null)
                                  GestureDetector(
                                    onTap: () async {
                                      if (totalItems < 10) {
                                        final picture =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picture != null) {
                                          setState(() {
                                            image = picture;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoPreviewScreen(
                                            imagePath: image!.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(image!.path),
                                        height: 160,
                                        width: 140,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 5),
                                // Image 2
                                if (image2 == null)
                                  GestureDetector(
                                    onTap: () async {
                                      if (totalItems < 10) {
                                        final picture =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picture != null) {
                                          setState(() {
                                            image2 = picture;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoPreviewScreen(
                                            imagePath: image2!.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(image2!.path),
                                        height: 160,
                                        width: 140,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 5),
                                // Image 3
                                if (image3 == null)
                                  GestureDetector(
                                    onTap: () async {
                                      if (totalItems < 10) {
                                        final picture =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picture != null) {
                                          setState(() {
                                            image3 = picture;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoPreviewScreen(
                                            imagePath: image3!.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(image3!.path),
                                        height: 160,
                                        width: 140,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 5),
                                // Image 4
                                if (image4 == null)
                                  GestureDetector(
                                    onTap: () async {
                                      if (totalItems < 10) {
                                        final picture =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picture != null) {
                                          setState(() {
                                            image4 = picture;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoPreviewScreen(
                                            imagePath: image4!.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(image4!.path),
                                        height: 160,
                                        width: 140,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                const SizedBox(width: 5),
                                // Image 5
                                if (image5 == null)
                                  GestureDetector(
                                    onTap: () async {
                                      if (totalItems < 10) {
                                        final picture =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (picture != null) {
                                          setState(() {
                                            image5 = picture;
                                          });
                                        }
                                      }
                                    },
                                    child: Container(),
                                  )
                                else
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              PhotoPreviewScreen(
                                            imagePath: image5!.path,
                                          ),
                                        ),
                                      );
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.file(
                                        File(image5!.path),
                                        height: 160,
                                        width: 140,
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  reuseableText(
                                    LocalData.galleryVideo.getString(context),
                                  ),
                                  reuseableText(
                                    LocalData.cameraVideo.getString(context),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      IconButton(
                                        icon: const Icon(
                                            Icons.photo_camera_back_outlined),
                                        onPressed: () {
                                          for (int i = 0;
                                              i < videos.length;
                                              i++) {
                                            if (videos[i] == null) {
                                              _pickVideo(
                                                  i, ImageSource.gallery);
                                              break;
                                            }
                                          }
                                        },
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                            FluentIcons.video_32_regular),
                                        onPressed: () {
                                          for (int i = 0;
                                              i < videos.length;
                                              i++) {
                                            if (videos[i] == null) {
                                              _pickVideo(i, ImageSource.camera);
                                              break;
                                            }
                                          }
                                        },
                                      ),
                                    ],
                                  ),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: List.generate(5, (index) {
                                        return Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: _videoPlayerPreview(
                                              videoControllers[index],
                                              videos[index]?.path),
                                        );
                                      }),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          reuseableText("Audio"),
                          const SizedBox(height: 10),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              GestureDetector(
                                onTap: startRecording,
                                child: const Icon(
                                  FluentIcons.mic_16_regular,
                                ),
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
}
