import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:instagram/screens/post_screens/editing_photo_screen.dart';
import 'package:instagram/view_model/camera_view_model.dart';

import '../../ultis/ultils.dart';

class CameraPreviewScreen extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPreviewScreen({Key? key, required this.cameras})
      : super(key: key);

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen> {
  late CameraController _controller;
  late CameraViewModel _cameraViewModel;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(widget.cameras[1], ResolutionPreset.max);
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
              // If the Future is complete, display the preview.
              return _buildPreviewCamera(context);
            } else {
              // Otherwise, display a loading indicator.
              return const Center(child: CircularProgressIndicator());
            }
          },
        ),
      ),
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
                  Expanded(
                      child: Container(
                    color: Colors.black54,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10, right: 10, top: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: const [
                          Icon(
                            Icons.settings_rounded,
                            size: 35,
                          ),
                          Icon(
                            Icons.flash_auto,
                            size: 35,
                          ),
                          Icon(
                            Icons.close,
                            size: 35,
                          )
                        ],
                      ),
                    ),
                  )),
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.width,
                    child: GridView.count(
                      crossAxisCount: 3, // số cột
                      children: List.generate(9, (index) {
                        return Container(
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white, width: 0.5)),
                        );
                      }),
                    ),
                  ),
                  Expanded(
                      child: Container(
                    color: Colors.black54,
                  )),
                ],
              ),
            )),
            Positioned(
                bottom: 20,
                left: 0,
                right: 0,
                child: SizedBox(
                  height: 80,
                  width: 80,
                  child: ElevatedButton(
                    onPressed: () {
                      _cameraViewModel.takePicture().then((photo) {
                        Navigator.push(
                          context,
                          PageRouteBuilder(
                            pageBuilder:
                                (context, animation, secondaryAnimation) =>
                                EditingPhotoScreen(photo: photo),
                            transitionsBuilder: (context, animation,
                                secondaryAnimation, child) {
                              return buildSlideTransition(animation, child);
                            },
                            transitionDuration:
                            const Duration(milliseconds: 150),
                            reverseTransitionDuration:
                            const Duration(milliseconds: 150),
                          ),
                        );
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      backgroundColor: Colors.white,
                    ),
                    child: Container(),
                  ),
                ))
          ],
        ),
        Padding(
          padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Icon(Icons.image_outlined, size: 35,),
              Icon(Icons.flip_camera_android_rounded, size: 35,)
            ],
          ),
        )
      ],
    );
  }
}
