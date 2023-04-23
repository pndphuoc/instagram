import 'dart:async';

import 'package:instagram/services/message_details_services.dart';

class MessageDetailsViewModel {
  final String _conversationId;
  final String _messageId;
  MessageDetailsViewModel(this._conversationId, this._messageId) {
    listenToMessageStatus();
  }

  final MessageDetailsService _messageDetailsService = MessageDetailsService();
  late StreamSubscription<String> _messagesStatusSubscription;
  final _statusController = StreamController<String>();
  Stream<String> get statusStream => _statusController.stream;

  void listenToMessageStatus() {
    _messagesStatusSubscription = _messageDetailsService.getMessageStatus(conversationId: _conversationId, messageId: _messageId).listen((status) {
      _statusController.sink.add(status);
    });
  }

  Stream<String> getMessageStatus() {
    return _messageDetailsService.getMessageStatus(conversationId: _conversationId, messageId: _messageId);
  }
}