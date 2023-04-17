import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:instagram/models/conversation.dart';
import 'package:instagram/services/message_services.dart';
import 'package:instagram/services/user_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:rxdart/rxdart.dart';

import '../models/chat_user.dart';
import '../models/message.dart';
import '../services/asset_services.dart';
import '../services/firestorage_services.dart';

class MessageViewModel extends ChangeNotifier {
  MessageViewModel() {
    createConversationIdFromUsers();
  }

  final UserService _userService = UserService();

  final MessageServices _messageServices = MessageServices();
  final StreamController<String> _writingMessageController =
      StreamController<String>();

  Stream<String> get writingMessageStream => _writingMessageController.stream;

  late String _conversationId;

  String get conversationId => _conversationId;
  List<ChatUser> _users = [];

  List<ChatUser> get users => _users;

  final _messagesController = StreamController<List<Message>>();

  Stream<List<Message>> get messagesStream => _messagesController.stream;

  final _sendingMessageController = StreamController<List<AssetEntity>>();

  Stream<List<AssetEntity>> get sendingMessageStream => _sendingMessageController.stream;

  final StreamController<List<ChatUser>> _usersList =
      StreamController<List<ChatUser>>();

  Stream<List<ChatUser>> get usersStream => _usersList.stream;

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

  void onChange(String value) {
    _writingMessageController.sink.add(value);
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
    if (await _messageServices
            .isExistsConversation(_users.map((e) => e.userId).toList()) ==
        false) {
      await _messageServices.createConversation(
          _users, _conversationId, messageContent, timestamp);
    }
    await _messageServices.sendTextMessage(
        conversationId: _conversationId,
        senderId: senderId,
        messageContent: messageContent,
        timestamp: timestamp);
    await updateLastMessageOfConversation(
        conversationId: _conversationId,
        content: messageContent,
        type: messageType,
        timestamp: timestamp);
  }

  Stream<List<Message>> getMessages(
      {int pageSize = 25, DocumentSnapshot? lastDocument}) {
    return _messageServices.getStreamMessages(
        conversationId: _conversationId,
        pageSize: pageSize,
        lastDocument: lastDocument);
  }

  Stream<Conversation> getConversationData(String conversationId) {
    return _messageServices.getStreamConversationData(conversationId).transform(
          StreamTransformer<DocumentSnapshot<Map<String, dynamic>>,
              Conversation>.fromHandlers(
            handleData: (snapshot, sink) async {
              if (snapshot.data() == null) {
                return;
              }

              sink.add(Conversation.fromJson(snapshot.data()!));
            },
            handleError: (error, stackTrace, sink) {
              // Xử lý lỗi nếu có
              print('Error: $error');
            },
          ),
        );
  }

  Stream<List<String>> getConversationIds(
      {required String userId,
      int pageSize = 20,
      DocumentSnapshot<Object?>? lastDocument}) {
    return _messageServices.getConversationIds(userId: userId);
  }

  Future<void> updateLastMessageOfConversation(
      {required String conversationId,
      required String content,
      required DateTime timestamp,
      required String type}) async {
    if (type == 'image') {
      content = 'Sent a image';
    } else if (type == 'video') {
      content = 'Sent a video';
    }
    _messageServices.updateLastMessageOfConversation(
        conversationId: conversationId,
        content: content,
        timestamp: timestamp,
        type: type);
  }

  Stream<String> getOnlineStatus(String userId) {
    return _userService.getLastOnlineTime(userId).transform(
        StreamTransformer.fromHandlers(handleData: (snapshot, sink) async {
      if (snapshot.isNaN) return;

      final lastOnline = DateTime.fromMillisecondsSinceEpoch(snapshot);
      final difference = DateTime.now().difference(lastOnline);
      String status = 'Online';
      if (difference.inMinutes < 2) {
        status = "Online";
      } else {
        status = "Online ${difference.inMinutes} minutes ago";
      }
      sink.add(status);
    }));
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
      print(e.toString());
      _paths = [];
    }
  }

  Future<void> loadAssetsOfPath({int page = 0, int sizePerPage = 50}) async {
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
    if (await _messageServices
            .isExistsConversation(_users.map((e) => e.userId).toList()) ==
        false) {
      await _messageServices.createConversation(
          _users, _conversationId, '', DateTime.now());
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
      updateLastMessageOfConversation(
          conversationId: _conversationId,
          content: lastMessageContent,
          type: type,
          timestamp: time);
    }_sendingMessageController.sink.add([]);
    _selectedEntities = [];

    //await _messageServices.sendTextMessage(conversationId: _conversationId, senderId: senderId, messageContent: messageContent, timestamp: timestamp);
    //await updateLastMessageOfConversation(conversationId: _conversationId, content: messageContent, type: messageType, timestamp: timestamp);
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
      Fluttertoast.showToast(msg: "Unable to download because permission is not granted");
      return false;
    } else if (status == PermissionStatus.granted) {
      return true;
    }
    return false;
  }

/*  Stream<List<Conversation>> getConversations() {
    return _messageServices.getConversations(userId: FirebaseAuth.instance.currentUser!.uid).transform(
      StreamTransformer<List<dynamic>, List<Conversation>>.fromHandlers(
        handleData: (snapshot, sink) async {
          if (snapshot.isEmpty) return;
          sink.add(await )
        }
      )
    );
  }*/
}
