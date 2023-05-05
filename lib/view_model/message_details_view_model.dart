import 'dart:async';

import 'package:instagram/repository/message_details_repository.dart';

class MessageDetailsViewModel {
  final String _conversationId;
  final String _messageId;
  MessageDetailsViewModel(this._conversationId, this._messageId) {
    listenToMessageStatus();
  }

  late StreamSubscription<String> _messagesStatusSubscription;
  final _statusController = StreamController<String>();
  Stream<String> get statusStream => _statusController.stream;

  void listenToMessageStatus() {
    _messagesStatusSubscription = MessageDetailsRepository.getMessageStatus(conversationId: _conversationId, messageId: _messageId).listen((status) {
      _statusController.sink.add(status);
    });
  }

  Stream<String> getMessageStatus() {
    return MessageDetailsRepository.getMessageStatus(conversationId: _conversationId, messageId: _messageId);
  }
}