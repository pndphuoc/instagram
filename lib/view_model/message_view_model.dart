import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/repository/conversation_repository.dart';
import 'package:instagram/repository/message_details_repository.dart';
import 'package:instagram/repository/message_repository.dart';
import 'package:instagram/repository/notification_repository.dart';
import 'package:instagram/repository/user_repository.dart';
import 'package:instagram/ultis/ultils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_summary_information.dart';
import '../models/message.dart';
import '../repository/asset_repository.dart';
import '../repository/firebase_storage_repository.dart';

class MessageViewModel extends ChangeNotifier {
  MessageViewModel(List<UserSummaryInformation> users) {
    getAssets();
    _users = users;
    _restUser = _users.firstWhere(
        (user) => user.userId != FirebaseAuth.instance.currentUser!.uid);
    _currentUser = _users.firstWhere(
        (user) => user.userId == FirebaseAuth.instance.currentUser!.uid);
    createConversationIdFromUsers();
    MessageDetailsRepository.updateStatus(
        conversationId: _conversationId,
        senderId: _users
            .where((element) =>
                element.userId != FirebaseAuth.instance.currentUser!.uid)
            .first
            .userId);
    getRestUserTokens().whenComplete(() => loadOldMessages().whenComplete(() {
      listenToNotificationSettingOfRestUser();
          listenToMessages();
        }));
  }

  late UserSummaryInformation _restUser;
  late UserSummaryInformation _currentUser;
  final StreamController<bool> _writingMessageController =
      StreamController<bool>();
  late List<String> _restUserTokens = [];
  bool _isRestUserTurnOffNotification = false;

  Stream<bool> get writingMessageStream => _writingMessageController.stream;

  int page = 0;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  set messages(List<Message> value) {
    _messages = value;
  }

  late String _conversationId;

  String get conversationId => _conversationId;

  List<UserSummaryInformation> _users = [];

  List<UserSummaryInformation> get users => _users;

  set users(List<UserSummaryInformation> value) {
    _users = value;
  }

  final _sendingMessageController = StreamController<List<AssetEntity>>();

  Stream<List<AssetEntity>> get sendingMessageStream =>
      _sendingMessageController.stream;

  final StreamController<List<UserSummaryInformation>> _usersList =
      StreamController<List<UserSummaryInformation>>();

  Stream<List<UserSummaryInformation>> get usersStream => _usersList.stream;

  final AssetRepository _assetService = AssetRepository();

  List<AssetEntity> _selectedEntities = [];

  List<AssetEntity> get selectedEntities => _selectedEntities;

  set selectedEntities(List<AssetEntity> value) {
    _selectedEntities = value;
  }

  List<AssetEntity> _entities = [];

  List<AssetEntity> get entities => _entities;

  set entities(List<AssetEntity> value) {
    _entities = value;
  }

  List<AssetPathEntity> _paths = [];
  late AssetPathEntity _selectedPath;

  AssetPathEntity get selectedPath => _selectedPath;

  set selectedPath(AssetPathEntity value) {
    _selectedPath = value;
  }

  late int entitiesCount;
  bool _hasMoreToLoad = false;

  bool get hasMoreToLoad => _hasMoreToLoad;

  set hasMoreToLoad(bool value) {
    _hasMoreToLoad = value;
  }

  List<String> firstMessageInGroup = [];
  List<String> lastMessageInGroup = [];

  void groupMessage() {
    firstMessageInGroup = [];
    lastMessageInGroup = [];
    lastMessageInGroup.add(_messages[0].id);
    firstMessageInGroup.add(_messages.last.id);

    for (int index = 0; index < _messages.length - 1; index++) {
      bool isDifferentSender =
          _messages[index].senderId != _messages[index + 1].senderId;
      bool isMoreThan30s = _messages[index]
              .timestamp
              .difference(_messages[index + 1].timestamp)
              .inSeconds >=
          30;

      if (isDifferentSender) {
        lastMessageInGroup.add(_messages[index + 1].id);
        firstMessageInGroup.add(_messages[index].id);
      } else if (isMoreThan30s) {
        lastMessageInGroup.add(_messages[index + 1].id);
        firstMessageInGroup.add(_messages[index].id);
      }
    }
  }

  Future<void> getRestUserTokens() async {
    _restUserTokens = await UserRepository.getFcmTokens(_restUser.userId);
  }

  void onChange(String value) {
    if (value.length > 1) return;
    _writingMessageController.sink.add(value.isEmpty ? true : false);
  }

  void createConversationIdFromUsers() {
    _users.sort(
      (a, b) => a.userId.compareTo(b.userId),
    );
    List<String> uid = _users.map((e) => e.userId).toList();
    _conversationId = uid.join("_");
  }

  void listenToNotificationSettingOfRestUser() {
    MessageRepository.isTurnOffNotification(userId: _restUser.userId, conversationId: _conversationId).listen((conversationSnapshot) {
      _isRestUserTurnOffNotification = conversationSnapshot;
    });
  }

  Future<void> sendTextMessage(
      {required String senderId,
      required String messageType,
      required String messageContent,
      required DateTime timestamp}) async {
    _writingMessageController.sink.add(true);
    if (await ConversationRepository
            .isExistsConversation(_users.map((e) => e.userId).toList()) ==
        false) {
      await ConversationRepository.createConversation(
          users: _users,
          conversationId: _conversationId,
          messageContent: messageContent,
          messageTime: timestamp);
    }
    await MessageRepository.sendTextMessage(
        conversationId: _conversationId,
        senderId: senderId,
        messageContent: messageContent,
        timestamp: timestamp);
    await ConversationRepository.updateLastMessageOfConversation(
        conversationId: _conversationId,
        content: messageContent,
        type: messageType,
        timestamp: timestamp);

    if (_isRestUserTurnOffNotification) return;

    final jsonData = notificationJsonDataMaker(
        registrationIds: _restUserTokens,
        title: _currentUser.displayName.isNotEmpty
            ? _currentUser.displayName
            : _currentUser.username,
        senderName: _currentUser.username,
        body: messageContent,
        channelKey: _conversationId,
        notificationLayout: 'Messaging',
        conversationId: _conversationId,
        avatarUrl: _currentUser.avatarUrl);

    await NotificationRepository.sendMessageNotification(jsonData);
  }

  final _messageController = StreamController<List<Message>>.broadcast();

  Stream<List<Message>> get messagesStream => _messageController.stream;
  late StreamSubscription<List<Message>?> _messagesSubscription;

  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;
  bool _hasMoreMessages = false;
  bool _loadingOldMessages = false;
  DateTime? _oldestMessageTimestamp;

  AppLifecycleState _appLifecycleState = AppLifecycleState.resumed;

  set appLifecycleState(AppLifecycleState value) {
    _appLifecycleState = value;
  }

  void listenToMessages() {
    _messagesSubscription = MessageRepository
        .getNewMessage(
            conversationId: _conversationId,
            lastMessageTimestamp:
                _messages.isNotEmpty ? _messages.first.timestamp : null)
        .listen((List<Message>? messages) {
      if (messages == null) {
        _messageController.sink.add([]);
        return;
      }

      for (Message message in messages) {
        final index =
            _messages.indexWhere((element) => element.id == message.id);
        if (index == -1) {
          _messages.insert(0, message);
          groupMessage();
        } else {
          _messages[index] = message;
        }
      }
      if (_appLifecycleState == AppLifecycleState.resumed) {
        updateSeenStatus();
      }

      _messageController.sink.add([]);
    });

    _scrollController.addListener(() {
      if (_scrollController.position.pixels /
              _scrollController.position.maxScrollExtent <
          0.8) {
        loadOldMessages();
      }
    });
  }

  Future<void> updateSeenStatus() async {
    _messages
        .where((element) =>
            element.senderId == _restUser.userId && element.status == 'sent')
        .map((e) => e.status = 'seen');

    await MessageDetailsRepository.updateStatus(
        conversationId: _conversationId, senderId: _restUser.userId);
  }

  Future<void> loadOldMessages() async {
    if (_hasMoreMessages || _loadingOldMessages) {
      return;
    }

    _loadingOldMessages = true;

    if (_messages.isNotEmpty) {
      _oldestMessageTimestamp = _messages.last.timestamp;
    } else {
      _oldestMessageTimestamp = null;
    }

    final oldMessages = await MessageRepository.getOldMessages(
        conversationId: _conversationId,
        lastMessageTimestamp: _oldestMessageTimestamp,
        limit: 20);

    if (oldMessages.isNotEmpty) {
      _messages.addAll(oldMessages);
      groupMessage();
      _messageController.sink.add([]);
    } else {
      _messageController.sink.add([]);
      _hasMoreMessages = false;
    }

    _loadingOldMessages = false;
  }

  final StreamController<List<AssetEntity>> _selectedEntitiesController =
      BehaviorSubject();

  Stream<List<AssetEntity>> get selectedEntitiesStream =>
      _selectedEntitiesController.stream;

  Future<void> loadAssetPathList() async {
    try {
      _paths = await AssetRepository.loadAssetPathList();

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      _paths = [];
    }
  }

  Future<void> loadAssetsOfPath({int sizePerPage = 50}) async {
    _entities.addAll(await AssetRepository.loadAssetsOfPath(_selectedPath,
        page: page, sizePerPage: sizePerPage));

    entitiesCount = await _selectedPath.assetCountAsync;
    _hasMoreToLoad = _entities.length < entitiesCount;
    notifyListeners();
  }

  Future<bool> getAssets() async {
    try {
      await loadAssetPathList();
      _selectedPath = _paths.first;
      await loadAssetsOfPath();
      notifyListeners();
      return true;
    } catch (err) {
      return true;
    }
  }

  void onTapMedia(AssetEntity entity) {
    if (_selectedEntities.length > 10) return;
    if (_selectedEntities.contains(entity)) {
      _selectedEntities.remove(entity);
    } else {
      _selectedEntities.add(entity);
    }
    _selectedEntitiesController.sink.add(_selectedEntities);
  }

  static void onTapSendMediaFromCamera({required String conversationId, required File file, required bool isVideo}) async {
    late String lastMessageContent;
    late String url;
    DateTime time = DateTime.now();

    if (isVideo) {
      url = await FireBaseStorageRepository
          .uploadFile(file, 'messages/$conversationId/videos', isVideo: true);
      lastMessageContent = "Sent a video";

      MessageRepository.sendVideoMessage(
          conversationId: conversationId,
          senderId: FirebaseAuth.instance.currentUser!.uid,
          messageContent: url,
          timestamp: time);

    } else {
      url = await FireBaseStorageRepository
          .uploadFile(file, 'messages/$conversationId/videos', isVideo: false);
      lastMessageContent = "Sent a image";

      MessageRepository.sendImageMessage(
          conversationId: conversationId,
          senderId: FirebaseAuth.instance.currentUser!.uid,
          messageContent: url,
          timestamp: time);
    }

    ConversationRepository.updateLastMessageOfConversation(
        conversationId: conversationId,
        content: lastMessageContent,
        type: isVideo ? 'video' : 'image',
        timestamp: time);

  }

  void onTapSendImageMessages() async {
    if (await ConversationRepository
            .isExistsConversation(_users.map((e) => e.userId).toList()) ==
        false) {
      await ConversationRepository.createConversation(
          users: _users,
          conversationId: _conversationId,
          messageContent: '',
          messageTime: DateTime.now());
    }
    _sendingMessageController.sink.add(_selectedEntities);
    for (final entity in _selectedEntities) {
      late String lastMessageContent;
      late String url;
      late String type;
      final file = await entity.fileWithSubtype;
      if (file == null) {
        continue;
      }
      if (entity.type == AssetType.image) {
        url = await FireBaseStorageRepository.uploadFile(
          file,
          'messages/$conversationId/photos',
        );
        type = "image";
        lastMessageContent = "Sent a image";
      } else if (entity.type == AssetType.video) {
        url = await FireBaseStorageRepository
            .uploadFile(file, 'messages/$conversationId/videos', isVideo: true);
        type = "video";
        lastMessageContent = "Sent a video";
      }
      DateTime time = DateTime.now();

      if (type == "image") {
        MessageRepository.sendImageMessage(
            conversationId: conversationId,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            messageContent: url,
            timestamp: time);
      } else {
        MessageRepository.sendVideoMessage(
            conversationId: conversationId,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            messageContent: url,
            timestamp: time);
      }
      ConversationRepository.updateLastMessageOfConversation(
          conversationId: _conversationId,
          content: lastMessageContent,
          type: type,
          timestamp: time);
    }
    _sendingMessageController.sink.add([]);
    _selectedEntities = [];
  }

  Future<bool> onDownload(String url) async {
    var status = await Permission.storage.status;
    if (status == PermissionStatus.granted) {
      _requestPermission();
    }
    return FireBaseStorageRepository.downloadFile(url);
  }

  Future<bool> _requestPermission() async {
    final PermissionStatus status =
        await Permission.manageExternalStorage.request();
    if (status == PermissionStatus.denied) {
      Fluttertoast.showToast(
          msg: "Unable to download because permission is not granted");
      return false;
    } else if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

  @override
  void dispose() {
    _selectedEntitiesController.close();
    _writingMessageController.close();
    _scrollController.dispose();
    _messagesSubscription.cancel();
    _usersList.close();
    _sendingMessageController.close();
    super.dispose();
  }
}
