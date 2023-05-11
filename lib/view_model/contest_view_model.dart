import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/models/contest.dart';
import 'package:instagram/repository/contest_repository.dart';
import 'package:instagram/repository/firebase_storage_repository.dart';

import '../models/post.dart';
import '../models/prize.dart';

class CreateContestViewModel extends ChangeNotifier {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController topicController = TextEditingController();
  final TextEditingController contentController = TextEditingController();
  final TextEditingController rulesController = TextEditingController();
  final TextEditingController newPrizeName = TextEditingController();
  final TextEditingController newPrizeAward = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  List<TextEditingController> prizeControllers = [];
  final List<Prize> prizes = [];
  bool _isCreating = false;

  bool get isCreating => _isCreating;
  File? _banner;

  File? get banner => _banner;

  void imagePicker() async {
    final ImagePicker picker = ImagePicker();
    try {
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      _banner = File(image.path);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  void createPrize(Prize prize) {
    prizes.add(prize);
    newPrizeName.clear();
    newPrizeAward.clear();
    notifyListeners();
  }

  Future<bool> createContest() async {
    _isCreating = true;
    notifyListeners();

    final bannerUrl =
        await FireBaseStorageRepository.uploadFile(_banner!, "contest/banner");

    if (bannerUrl.isEmpty) {
      _isCreating = false;
      return false;
    }

    Contest newContest = Contest(
        name: nameController.text,
        banner: bannerUrl,
        description: contentController.text,
        startTime: startDate!,
        endTime: endDate!,
        prizes: prizes,
        ownerId: FirebaseAuth.instance.currentUser!.uid,
        rules: rulesController.text,
        topic: topicController.text,
        status: 'upcoming');
    await ContestRepository.addContest(newContest);

    _isCreating = false;
    notifyListeners();
    return true;
  }

  Future<void> onStartDateTap(BuildContext context) async {
    startDate = await showDatePicker(
        context: context,
        initialDate: startDate != null
            ? startDate!
            : DateTime.now().add(const Duration(days: 1)),
        firstDate: DateTime.now().add(const Duration(days: 1)),
        lastDate: endDate != null
            ? endDate!
            : DateTime.now().add(const Duration(days: 120)));
    if (startDate == null) return;
    notifyListeners();
  }

  Future<void> onEndDateTap(BuildContext context) async {
    endDate = await showDatePicker(
        context: context,
        initialDate: endDate != null
            ? endDate!
            : startDate != null
                ? startDate!.add(const Duration(days: 1))
                : DateTime.now().add(const Duration(days: 1)),
        firstDate: startDate != null
            ? startDate!
            : DateTime.now().add(const Duration(days: 1)),
        lastDate: DateTime.now().add(const Duration(days: 120)));
    if (endDate == null) return;
    notifyListeners();
  }

}
