import 'package:flutter/material.dart';// ...existing code...


import 'package:karvaan/screens/EventDetailsPage.dart';
// In the _buildEventCard method, add navigation
Widget _buildEventCard(Event event, BuildContext context) {
  return Card(
















// ...existing code...}  );    ),      ),        // ...existing code...      child: Column(      },        );          ),            builder: (context) => EventDetailsPage(eventId: event.id),          MaterialPageRoute(          context,        Navigator.push(      onTap: () {    // ...existing code...
    child: InkWell(