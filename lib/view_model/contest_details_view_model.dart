import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:instagram/repository/contest_repository.dart';
import 'package:instagram/repository/firebase_storage_repository.dart';
import 'package:instagram/repository/post_repository.dart';
import 'package:instagram/repository/user_repository.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:mime/mime.dart';

import '../models/contest.dart';
import '../models/media.dart';
import '../models/post.dart';
import '../models/prize.dart';
import '../models/user.dart';

class ContestDetailsViewModel extends ChangeNotifier {
  late String contestId;
  Contest? contestDetails;
  late User _ownerUser;

  User get ownerUser => _ownerUser;

  ContestDetailsViewModel({required this.contestId}) {
    getContestDetails().whenComplete(() => getOwnerUser(contestDetails!.ownerId));
  }

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  List<Post> _top10PostOfContest = [];

  List<Post> get top10PostOfContest => _top10PostOfContest;

  List<Prize> get prizes => contestDetails!.prizes;

  List<Post> winningPosts = [];

  Future<void> getContestDetails() async {
    _isLoading = true;
    notifyListeners();
    contestDetails = await ContestRepository.getContestDetail(contestId);
  }

  Future<void> getTop10PostOfContest() async {
    _top10PostOfContest = await ContestRepository.getTop10PostOfContest(contestId);
  }

  void chooseWinner({required Post post, required Prize prize}) {
    final index = contestDetails!.prizes.indexWhere((element) => element.name == prize.name);
    contestDetails!.prizes[index].winnerId = post.uid;

    if (winningPosts.length > index) {
      winningPosts[index] = post;
    } else {
      winningPosts.add(post);
    }

    notifyListeners();
  }

  Future<void> getOwnerUser(String userId) async {
    _ownerUser = await UserRepository.getUserDetails(userId);
    _isLoading = false;
    notifyListeners();
  }

  Future<List<File>> onJoinContestTap() async {
    final ImagePicker picker = ImagePicker();
    List<XFile> images = await picker.pickMultiImage();
    if (images.isEmpty) return [];
    return images.map((e) => File(e.path)).toList();
  }
  bool isUpdateAward = false;
  Future<void> updateAward() async {
    isUpdateAward = true;
    notifyListeners();

    await ContestRepository.updatePrizes(contestId: contestId, prizes: contestDetails!.prizes);

    isUpdateAward = false;
    notifyListeners();
  }

  bool isHaveResult() {
    for(final winner in contestDetails!.prizes) {
      if (winner.winnerId == null) {
        return false;
      }
    }
    return true;
  }

  Future<String> onUploadPostOfContest({required String caption, required List<File> files, required User currentUser}) async {
    List<Media> medias = await uploadFileHandle(files);
    ContestPost post = ContestPost(
        caption: caption,
        userId: currentUser.uid,
        username: currentUser.username,
        avatarUrl: currentUser.avatarUrl,
        likeCount: 0,
        commentCount: 0,
        createAt: DateTime.now(),
        medias: medias,
        uid: '',
        commentListId: '',
        isDeleted: false,
        likedListId: '',
        updateAt: DateTime.now(),
        isArchived: false,
        isContestPost: true,
        viewedListId: '', contestId: contestId);

    String postId = await PostRepository.addContestPost(post);

    return postId;
  }

  Future<List<Media>> uploadFileHandle(List<File> files) async {
    List<Media> medias = [];
    for (var file in files) {
      String? mimeType = lookupMimeType(file.path);
      if (mimeType != null) {
        if (mimeType.startsWith('image/')) {
          String url = await FireBaseStorageRepository.uploadFile(
              file, contestPostPath.replaceAll('%id', contestId), isVideo: false);
          medias.add(Media(url: url, type: 'image'));
        } else if (mimeType.startsWith('video/')) {
          String url = await FireBaseStorageRepository.uploadFile(
              file, contestPostPath.replaceAll('%id', contestId), isVideo: true);
          medias.add(Media(url: url, type: 'video'));
        } else {
          print('Unsupported format');
        }
      } else {
        print('File type cannot be determined');
      }
    }
    return medias;
  }

}