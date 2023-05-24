import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/models/post.dart';
import 'package:instagram/repository/dall_e_repository.dart';
import 'package:instagram/repository/firebase_storage_repository.dart';
import 'package:instagram/repository/post_repository.dart';
import 'package:instagram/ultis/global_variables.dart';
import 'package:instagram/view_model/current_user_view_model.dart';
import 'package:provider/provider.dart';

import '../models/media.dart';
import '../repository/user_repository.dart';

class AddAIPostViewModel extends ChangeNotifier {
  final TextEditingController _textEditingController = TextEditingController();
  static List<Map<String, dynamic>> sizes = [
    {
      'value': 1.0,
      'size': '256x256',
    },
    {
      'value': 2.0,
      'size': '512x512',
    },
    {
      'value': 3.0,
      'size': '1024x1024',
    }
  ];

  String _label = sizes[1]['size'];
  double _sliderValue = sizes[1]['value'];

  String get label => _label;

  double get sliderValue => _sliderValue;

  double _numberOfPhotos = 2;

  double get numberOfPhotos => _numberOfPhotos;

  List<String> _generatedPhotos = [];

  List<String> get generatedPhotos => _generatedPhotos;

  List<String> _selectedPhotos = [];

  List<String> get selectedPhotos => _selectedPhotos;

  TextEditingController get textEditingController => _textEditingController;

  bool _isShareToAISpace = true;

  bool get isShareToAISpace => _isShareToAISpace;

  void onSizeSliderChanged(double value) {
    for (var element in sizes) {
      if (element['value'] == value) {
        _label = element['size'];
        _sliderValue = element['value'];
        notifyListeners();
        break;
      }
    }
  }

  void onNumberOfPhotosSliderChanged(double value) {
    _numberOfPhotos = value;
    notifyListeners();
  }

  bool _isGenerating = false;

  bool get isGenerating => _isGenerating;

  bool _isUploading = false;

  bool get isUploading => _isUploading;

  Future<void> onGenerateButtonTap() async {
    if (_isUploading) {
      return;
    }
    if (_textEditingController.text.isEmpty) {
      Fluttertoast.showToast(msg: 'Please enter the prompt');
      return;
    }
    _generatedPhotos = [];
    _isGenerating = true;
    notifyListeners();

    _generatedPhotos = await AISpaceRepository.generateImagesFromDallE(
        prompt: _textEditingController.text,
        size: _label,
        quantity: _numberOfPhotos.toInt());

    _isGenerating = false;
    notifyListeners();
  }

  void onPhotoTap(String url) {
    if (_selectedPhotos.contains(url)) {
      _selectedPhotos =
          _selectedPhotos.where((element) => element != url).toList();
      notifyListeners();
      return;
    }
    _selectedPhotos = [..._selectedPhotos, url];
    notifyListeners();
  }

  void onShareToAISpaceChanged(bool value) {
    _isShareToAISpace = value;
    notifyListeners();
  }

  Future<Post?> onShareButtonTap(String username, String avatarUrl) async {
    if (_selectedPhotos.isEmpty) {
      return null;
    }
    _isUploading = true;
    Fluttertoast.showToast(msg: 'Uploading...');
    notifyListeners();

    List<Media> medias = [];
    for (final url in _selectedPhotos) {
      medias.add(Media(
          url: await FireBaseStorageRepository
              .uploadImageFromUrlToFirebaseStorage(url, postsPhotosPath),
          type: 'image'));
    }

    AIPost post = AIPost(
        isShareToAISpace: _isShareToAISpace,
        isAIPost: true,
        uid: '',
        caption: _textEditingController.text,
        commentListId: 'commentListId',
        commentCount: 0,
        likedListId: '',
        likeCount: 0,
        viewedListId: '',
        medias: medias,
        userId: FirebaseAuth.instance.currentUser!.uid,
        username: username,
        avatarUrl: avatarUrl,
        createAt: DateTime.now(),
        updateAt: DateTime.now(),
        isDeleted: false,
        isArchived: false);

    final postId = await PostRepository.addAIPost(post);

    await UserRepository.updatePostInformation(postId);

    _isUploading = false;
    notifyListeners();

    return await PostRepository.getPost(postId);
  }
}
