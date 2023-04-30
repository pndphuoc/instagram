import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../post_screens/camera_preview_screen.dart';

class MessagingCameraPreviewScreen extends StatefulWidget {
  final String username;

  const MessagingCameraPreviewScreen({Key? key, required this.username})
      : super(key: key);

  @override
  State<MessagingCameraPreviewScreen> createState() =>
      _MessagingCameraPreviewScreenState();
}

class _MessagingCameraPreviewScreenState
    extends State<MessagingCameraPreviewScreen> {
  late Future _initializeCameras;

  @override
  void initState() {
    _initializeCameras = availableCameras();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder(
          future: _initializeCameras,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            } else {
              return Stack(
                children: [
                  Positioned.fill(
                      child: CameraPreviewScreen(
                    isOnlyTakePhoto: false,
                    cameras: snapshot.data!,
                    isSendMessage: true,
                  )),
                  Positioned(
                      top: 10,
                      right: 0,
                      left: 0,
                      child: _buildReplyingText(context)),
                ],
              );
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
              widget.username,
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
}
