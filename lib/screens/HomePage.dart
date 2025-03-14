import 'package:flutter/material.dart';
import 'package:karvaan/screens/RequestRidePage.dart';
import 'package:karvaan/screens/OfferRidePage.dart';
import 'package:karvaan/screens/CommunityPage.dart';
import 'package:karvaan/screens/EventsPage.dart';

// Update the createBox method to route buttons to existing pages
Widget createBox(
  BuildContext context, IconData icon, String label, Color color, Function() onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(




}  );    ),      // ...existing code...
// In the build method, update the GridView's createBox calls
GridView.count(
  // ...existing code...
  children: [
    createBox(context, Icons.drive_eta, "Request Ride", Colors.green, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => RequestRidePage()));
    }),
    createBox(context, Icons.car_rental, "Offer Ride", Colors.blue, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => OfferRidePage()));
    }),
    createBox(context, Icons.people, "Community", Colors.orange, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityPage()));
    }),
    createBox(context, Icons.event, "Events", Colors.purple, () {
      Navigator.push(context, MaterialPageRoute(builder: (context) => EventsPage()));
    }),
    // ...existing code...
  ],
),
// ...existing code...
