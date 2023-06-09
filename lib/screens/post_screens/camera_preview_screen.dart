import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/editing_photo_screen.dart';
import 'package:instagram/screens/post_screens/media_preview_screen.dart';
import 'package:instagram/view_model/camera_view_model.dart';

import '../../ultis/ultils.dart';

class CameraPreviewScreen extends StatefulWidget {
  final bool isOnlyTakePhoto;
  final bool isSendMessage;
  final String? username;
  final List<CameraDescription> cameras;
  const CameraPreviewScreen({Key? key, required this.cameras, required this.isOnlyTakePhoto, this.isSendMessage = false, this.username})
      : super(key: key);

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late CameraViewModel _cameraViewModel;
  late Future<void> _initializeControllerFuture;
  int selectedCamera = 0;

  @override
  void initState() {
    super.initState();
    _controller =
        CameraController(widget.cameras[selectedCamera], ResolutionPreset.max);
    _initializeControllerFuture = _controller.initialize();

    _cameraViewModel = CameraViewModel(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.connectionState == ConnectionState.done) {
              return _buildPreviewCamera(context);
            } else {
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
    );
  }

  Widget _buildReplyingText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(children: [
        WidgetSpan(
            child: Text(
              "Replying ",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            )),
        WidgetSpan(
            child: Text(
              widget.username ?? "",
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            )),
      ]),
    );
  }

  Widget _buildPreviewCamera(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: CameraPreview(_controller)),
            Positioned.fill(
                child: Align(
                  alignment: Alignment.center,
                  child: Column(
                    children: [
                      widget.isSendMessage ? Container(width: MediaQuery.of(context).size.width, height: 35, color: Colors.black54, child: _buildReplyingText(context),) : Container(),
                      Expanded(
                          child: Container(
                            color: widget.isSendMessage ? Colors.transparent : Colors.black54,
                            child: Padding(
                              padding:
                              const EdgeInsets.only(
                                  left: 10, right: 10, top: 10),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment
                                    .spaceBetween,
                                children: const [
                                  Icon(
                                    Icons.settings_rounded,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.flash_auto,
                                    size: 30,
                                  ),
                                  Icon(
                                    Icons.close,
                                    size: 30,
                                  )
                                ],
                              ),
                            ),
                          )),
                      widget.isSendMessage ? Container() : SizedBox(
                        width: MediaQuery
                            .of(context)
                            .size
                            .width,
                        height: MediaQuery
                            .of(context)
                            .size
                            .width,
                        child: GridView.count(
                          crossAxisCount: 3, // số cột
                          physics: const NeverScrollableScrollPhysics(),
                          children: List.generate(9, (index) {
                            return Container(
                              decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  border:
                                  Border.all(color: Colors.white, width: 0.5)),
                            );
                          }),
                        ),
                      ),
                      Expanded(
                          child: Container(
                            color: widget.isSendMessage ? Colors.transparent : Colors.black54,
                          )),
                    ],
                  ),
                )),
            Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: StreamBuilder(
                  stream: _cameraViewModel.videoStream,
                  initialData: 'stop',
                  builder: (context, snapshot) {
                    return Row(
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              Expanded(child: Container()),
                              Expanded(
                                child: widget.isOnlyTakePhoto ? Container() :  GestureDetector(
                                  onTap: () {
                                    if (snapshot.data! == 'stop') {
                                      _cameraViewModel.startRecording();
                                    } else if (snapshot.data! == 'recording') {
                                      _cameraViewModel.pauseRecording();
                                    } else if (snapshot.data! == 'pause') {
                                      _cameraViewModel.resumeRecording();
                                    }

                                  },
                                  child: AnimatedContainer(
                                    alignment: Alignment.centerRight,
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: snapshot.data! != 'stop'
                                          ? Colors.white
                                          : Colors.red,
                                    ),
                                    duration:
                                    const Duration(milliseconds: 250),
                                    child: snapshot.data! == 'recording'
                                        ? _buildPauseRecordingButton(context)
                                        : snapshot.data! == 'stop' ? Container() : _buildResumeRecordingButton(context)                                    ,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                         GestureDetector(
                          onTap: () {
                            if (snapshot.data! == 'recording' || snapshot.data! == 'pause') {
                              _cameraViewModel.stopRecording().then((video) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) =>
                                        MediaPreviewScreen.video(video: video, isSendMessage: widget.isSendMessage),
                                    transitionsBuilder: (context,
                                        animation,
                                        secondaryAnimation,
                                        child) {
                                      return buildSlideTransition(
                                          animation, child);
                                    },
                                    transitionDuration:
                                    const Duration(milliseconds: 150),
                                    reverseTransitionDuration:
                                    const Duration(milliseconds: 150),
                                  ),
                                ).then((value) => Navigator.pop(context, value));
                              });
                            } else if (snapshot.data! == 'stop') {
                              _cameraViewModel
                                  .takePicture(isSendMessage: widget.isSendMessage)
                                  .then((photo) {
                                Navigator.push(
                                  context,
                                  PageRouteBuilder(
                                    pageBuilder: (context, animation,
                                        secondaryAnimation) => widget.isSendMessage ? MediaPreviewScreen.image(image: photo, isSendMessage: widget.isSendMessage) :
                                        EditingPhotoScreen(photo: photo, isOnlyTakePhoto: widget.isOnlyTakePhoto),
                                    transitionsBuilder: (context,
                                        animation,
                                        secondaryAnimation,
                                        child) {
                                      return buildSlideTransition(
                                          animation, child);
                                    },
                                    transitionDuration:
                                    const Duration(milliseconds: 150),
                                    reverseTransitionDuration:
                                    const Duration(milliseconds: 150),
                                  ),
                                ).then((value) => Navigator.pop(context, value));
                              });
                            }
                          },
                          child: AnimatedContainer(
                            width: 80,
                            height: 80,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                            ),
                            duration: const Duration(milliseconds: 250),
                            child: snapshot.data! == 'recording' || snapshot.data! == 'pause'
                                ? _buildStopRecordingButton(context)
                                : Container(),
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    );
                  }
                )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Icon(
                Icons.image_outlined,
                size: 35,
              ),
              GestureDetector(
                  onTap: _onSwitchCamera,
                  child: const Icon(
                    Icons.flip_camera_android_rounded,
                    size: 35,
                  ))
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStartRecordingButton(BuildContext context) {
    return Container();
  }

  Widget _buildCapturePictureButton(BuildContext context) {
    return Container();
  }

  Widget _buildPauseRecordingButton(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.pause,
        color: Colors.black,
      ),
    )
    ;
  }

  Widget _buildResumeRecordingButton(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.play_arrow_rounded,
        color: Colors.black,
      ),
    )
    ;
  }

  Widget _buildStopRecordingButton(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.stop,
        size: 40,
        color: Colors.red,
      ),
    )
    ;
  }

  _onSwitchCamera() {
    setState(() {
      selectedCamera = selectedCamera == 0 ? 1 : 0;
    });

    _controller =
        CameraController(widget.cameras[selectedCamera], ResolutionPreset.max);

    _initializeControllerFuture = _controller.initialize();

    _cameraViewModel = CameraViewModel(_controller);
  }
}
