import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/services/conversation_services.dart';
import 'package:instagram/services/message_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:instagram/ultis/ultils.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

import '../models/user_summary_information.dart';
import '../models/message.dart';
import '../services/asset_services.dart';
import '../services/firebase_storage_services.dart';

class MessageViewModel extends ChangeNotifier {
  MessageViewModel(List<UserSummaryInformation> users) {
    _users = users;
    createConversationIdFromUsers();
    getLastSeenMessageTime();
    fetchLastSeenMessageTimeStream();
    loadOldMessages().whenComplete(() {
      listenToMessages();
    });
  }

  final ConversationService _conversationService = ConversationService();
  final MessageServices _messageServices = MessageServices();
  final StreamController<String> _writingMessageController =
      StreamController<String>();

  Stream<String> get writingMessageStream => _writingMessageController.stream;

  int page = 1;

  List<Message> _messages = [];

  List<Message> get messages => _messages;

  set messages(List<Message> value) {
    _messages = value;
  }

  late String _conversationId;

  DocumentSnapshot? _lastDocument;

  String get conversationId => _conversationId;

  List<UserSummaryInformation> _users = [];

  List<UserSummaryInformation> get users => _users;

  set users(List<UserSummaryInformation> value) {
    _users = value;
  } //final _messagesController = StreamController<List<Message>>();

  //Stream<List<Message>> get messagesStream => _messagesController.stream;

  final _sendingMessageController = StreamController<List<AssetEntity>>();

  Stream<List<AssetEntity>> get sendingMessageStream =>
      _sendingMessageController.stream;

  final StreamController<List<UserSummaryInformation>> _usersList =
      StreamController<List<UserSummaryInformation>>();

  Stream<List<UserSummaryInformation>> get usersStream => _usersList.stream;

  final AssetService _assetService = AssetService();
  final FireBaseStorageService _fireBaseStorageService =
      FireBaseStorageService();

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

  final _lastSeenMessageTimeController = StreamController<DateTime?>.broadcast();
  Stream<DateTime?> get lastSeenMessageTimeStream => _lastSeenMessageTimeController.stream;

  void onChange(String value) {
    _writingMessageController.sink.add(value);
  }

  Future<void> setLastSeenMessageTime(DateTime lastSeenMessageTime) async {
    await _messageServices.setLastSeenMessage(
        conversationId: _conversationId,
        userId: FirebaseAuth.instance.currentUser!.uid,
        lastSeenMessageTime: lastSeenMessageTime.toIso8601String());
  }

  Future<DateTime?> getLastSeenMessageTime() async {
    final userId = _users.where((user) => user.userId != FirebaseAuth.instance.currentUser!.uid).first.userId;
    return await _messageServices.getLastSeenMessageTime(conversationId: _conversationId, userId: userId);
  }

  late StreamSubscription<DateTime?> _lastSeenMessageTimeSubscription;

  void fetchLastSeenMessageTimeStream() {
    print("fetchLastSeenMessageTimeStream");
    final userId = _users.where((user) => user.userId != FirebaseAuth.instance.currentUser!.uid).first.userId;
    _lastSeenMessageTimeSubscription = _messageServices.fetchLastSeenMessageTimeStream(
        conversationId: _conversationId,
        userId: userId).listen((time) {
          _lastSeenMessageTimeController.sink.add(time);
    });
  }

  void createConversationIdFromUsers() {
    _users.sort(
      (a, b) => a.userId.compareTo(b.userId),
    );
    List<String> uid = _users.map((e) => e.userId).toList();
    _conversationId = uid.join("_");
  }

  Future<void> sendTextMessage(
      {required String senderId,
      required String messageType,
      required String messageContent,
      required DateTime timestamp}) async {
    if (await _conversationService
            .isExistsConversation(_users.map((e) => e.userId).toList()) ==
        false) {
      await _conversationService.createConversation(
          users: _users,
          conversationId: _conversationId,
          messageContent: messageContent,
          messageTime: timestamp);
    }
    await _messageServices.sendTextMessage(
        conversationId: _conversationId,
        senderId: senderId,
        messageContent: messageContent,
        timestamp: timestamp);
    await _conversationService.updateLastMessageOfConversation(
        conversationId: _conversationId,
        content: messageContent,
        type: messageType,
        timestamp: timestamp);
  }

  final _messageController = StreamController<List<Message>>.broadcast();

  Stream<List<Message>> get messagesStream => _messageController.stream;
  late StreamSubscription<Message?> _messagesSubscription;
  final ScrollController _scrollController = ScrollController();

  ScrollController get scrollController => _scrollController;
  bool _hasMoreMessages = false;
  bool _loadingOldMessages = false;
  DateTime? _oldestMessageTimestamp;

  void listenToMessages() {
    _messagesSubscription = _messageServices
        .getNewMessage(
            conversationId: _conversationId,
            lastMessageTimestamp: _messages.first.timestamp)
        .listen((message) {
      if (message == null) {
        _messageController.sink.add([]);
        return;
      }
      _messages.insert(0, message);
      if (message.senderId != FirebaseAuth.instance.currentUser!.uid) {
        setLastSeenMessageTime(message.timestamp);
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

    final oldMessages = await _messageServices.getOldMessages(
        conversationId: _conversationId,
        lastMessageTimestamp: _oldestMessageTimestamp,
        limit: 20);

    if (oldMessages.isNotEmpty) {
      _messages.addAll(oldMessages);
      _messageController.sink.add([]);
    } else {
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
      _paths = await _assetService.loadAssetPathList();

      notifyListeners();
    } catch (e) {
      debugPrint(e.toString());
      _paths = [];
    }
  }

  Future<void> loadAssetsOfPath({int sizePerPage = 50}) async {
    _entities.addAll(await _assetService.loadAssetsOfPath(_selectedPath,
        page: page, sizePerPage: sizePerPage));

    entitiesCount = await _selectedPath.assetCountAsync;
    _hasMoreToLoad = _entities.length < entitiesCount;
    notifyListeners();
  }

  Future<bool> firstLoading() async {
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

  void onTapSendImageMessages() async {
    if (await _conversationService
            .isExistsConversation(_users.map((e) => e.userId).toList()) ==
        false) {
      await _conversationService.createConversation(
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
        url = await _fireBaseStorageService.uploadFile(
          file,
          'messages/$conversationId/photos',
        );
        type = "image";
        lastMessageContent = "Sent a image";
      } else if (entity.type == AssetType.video) {
        url = await _fireBaseStorageService
            .uploadFile(file, 'messages/$conversationId/videos', isVideo: true);
        type = "video";
        lastMessageContent = "Sent a video";
      }
      DateTime time = DateTime.now();

      if (type == "image") {
        _messageServices.sendImageMessage(
            conversationId: conversationId,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            messageContent: url,
            timestamp: time);
      } else {
        _messageServices.sendVideoMessage(
            conversationId: conversationId,
            senderId: FirebaseAuth.instance.currentUser!.uid,
            messageContent: url,
            timestamp: time);
      }
      _conversationService.updateLastMessageOfConversation(
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
    return _fireBaseStorageService.downloadFile(url);
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
    _lastSeenMessageTimeController.close();
    _lastSeenMessageTimeSubscription.cancel();
    //_messagesController.close();
    _usersList.close();
    _sendingMessageController.close();
    super.dispose();
  }
}
