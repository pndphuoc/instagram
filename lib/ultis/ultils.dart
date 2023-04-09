import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

pickImage(ImageSource source) async {
  final ImagePicker _imagePicker = ImagePicker();

  XFile? _file = await _imagePicker.pickImage(source: source);

  if(_file != null) {
    return await _file.readAsBytes();
  }
  print("No image selected");
}

void showSnackBar(BuildContext context, String text) {
  final snackBar = SnackBar(
    content: Text(text),
    duration: const Duration(seconds: 3),
  );
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}


String getElapsedTime(DateTime startTime) {
  Duration timePassed = DateTime.now().difference(startTime);
  if (timePassed.inDays > 30) {
    return '${timePassed.inDays}';
  } else if (timePassed.inDays > 0) {
    return '${timePassed.inDays} days ago';
  } else if (timePassed.inHours > 0) {
    return '${timePassed.inHours} hours ago';
  } else if (timePassed.inMinutes > 0) {
    return '${timePassed.inMinutes} minutes ago';
  } else {
    return '${timePassed.inSeconds} seconds ago';
  }
}
