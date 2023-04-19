import 'package:flutter/material.dart';

class CommentTextFieldProvider extends ChangeNotifier {
  final TextEditingController textEditingController = TextEditingController();
  final FocusNode commentFocusNode = FocusNode();

  bool _isReplyingComment = false;

  bool get isReplyingComment => _isReplyingComment;

  set isReplyingComment(bool value) {
    _isReplyingComment = value;
  }

  String? _commentRepliedId;

  String get commentRepliedId => _commentRepliedId ?? "";
  int _replyCount = 0;
  bool _hasMoreReplyCount = true;
  String? username;




}