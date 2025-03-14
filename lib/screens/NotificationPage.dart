import 'package:flutter/material.dart';// ...existing code...




import 'package:karvaan/screens/CommunityPostPage.dart';import 'package:karvaan/screens/EventDetailsPage.dart';import 'package:karvaan/screens/RideDetailsPage.dart';
























// ...existing code...}  );    // ...existing code...    },      }        );          MaterialPageRoute(builder: (context) => CommunityPostPage(postId: notification.referenceId))          context,         Navigator.push(      } else if (notification.type == NotificationType.community) {        );          MaterialPageRoute(builder: (context) => EventDetailsPage(eventId: notification.referenceId))          context,         Navigator.push(      } else if (notification.type == NotificationType.event) {        );          MaterialPageRoute(builder: (context) => RideDetailsPage(rideId: notification.referenceId))          context,         Navigator.push(      if (notification.type == NotificationType.ride) {      // Route to appropriate page based on notification type


    onTap: () {    // ...existing code...  return ListTile(Widget _buildNotificationItem(Notification notification) {// In the _buildNotificationItem method, update the onTap function