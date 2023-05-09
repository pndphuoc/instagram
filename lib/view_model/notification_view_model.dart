import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:instagram/repository/notification_repository.dart';
import '../models/notification.dart' as model;

class NotificationViewModel extends ChangeNotifier {
  bool isLoading = false;
  List<model.Notification> _notifications = [];
  late Stream<List<model.Notification>> _notificationsStream;

  List<model.Notification> get notifications => _notifications;

  NotificationViewModel({required String userId}) {
    isLoading = true;
    notifyListeners();

    _notificationsStream =
        NotificationRepository.getNotifications(userId);

    isLoading = false;
    notifyListeners();

    _notificationsStream.listen((notifications) {
      _notifications = notifications;
      notifyListeners();
    });
  }

  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
      //NotificationRepository.updateNotification(notification);
    }
    notifyListeners();
  }

  static Future<void> addFollowNotification({
    required String receiverId,
    required String followUsername,
    required String followUserAvatarUrl,
}) async {
    model.Notification notification = model.Notification(
      interactiveUserId: FirebaseAuth.instance.currentUser!.uid,
      type: model.NotificationType.follow,
      userId: receiverId,
      interactiveUserAvatarUrl: followUserAvatarUrl,
      interactiveUsername: followUsername,
      isRead: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      title: model.NotificationMessages.getTitle('follow'),
      message: model.NotificationMessages.getMessage('follow', followUsername)
    );

    await NotificationRepository.addNotification(
        notification: notification);
  }

  static Future<void> addInteractiveNotification(
      {required String interactiveUserAvatarUrl,
        required String receiverId,
        required String interactiveUsername,
        required model.NotificationType notificationType,
        required String postId, required String firstImage}) async {

    model.Notification notification = model.Notification(
      userId: receiverId,
        interactiveUserId: FirebaseAuth.instance.currentUser!.uid,
        title: model.NotificationMessages.getTitle(notificationType.name),
        interactiveUsername: interactiveUsername,
        message: model.NotificationMessages.getMessage(
            notificationType.name, interactiveUsername),
        postId: postId,
        interactiveUserAvatarUrl: interactiveUserAvatarUrl,
        firstImage: firstImage,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        isRead: false,
        type: notificationType);

    await NotificationRepository.addNotification(
        notification: notification);
  }
}