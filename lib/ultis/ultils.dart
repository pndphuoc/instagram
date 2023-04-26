import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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
  if (timePassed.inDays > 7) {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    final String formatted = formatter.format(startTime);
    return formatted;
  } else if (timePassed.inDays > 0) {
    return '${timePassed.inDays} days';
  } else if (timePassed.inHours > 0) {
    return '${timePassed.inHours} hours';
  } else if (timePassed.inMinutes > 0) {
    return '${timePassed.inMinutes} minutes';
  } else {
    return '${timePassed.inSeconds} seconds';
  }
}

bool scrollEvent(scrollNotification, viewModel, double threshold) {
  final double extentAfter =
      scrollNotification.metrics.extentAfter;
  final double maxScrollExtent =
      scrollNotification.metrics.maxScrollExtent;

  if (viewModel.hasMorePosts &&
      scrollNotification is ScrollEndNotification &&
      extentAfter / maxScrollExtent < threshold) {
    viewModel.getPosts();
  }
  return true;
}

SlideTransition buildSlideTransition(
    Animation<double> animation, Widget child,
    {Offset offset = const Offset(1.0, 0.0)}) {
  return SlideTransition(
    position: Tween<Offset>(
      begin: offset,
      end: Offset.zero,
    ).animate(animation),
    child: child,
  );
}

double calculateItemHeight(
    {required BuildContext context,
    required double crossAxisSpacing,
    required double mainAxisSpacing,
    required int gridViewCrossAxisCount,
    required double childAspectRatio}) {
  double screenWidth = MediaQuery.of(context).size.width;
  double itemWidth =
      (screenWidth - crossAxisSpacing * (gridViewCrossAxisCount - 1)) /
          gridViewCrossAxisCount;
  double itemHeight = itemWidth / childAspectRatio + mainAxisSpacing;
  return itemHeight;
}
