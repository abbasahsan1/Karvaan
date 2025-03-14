import 'package:flutter/material.dart';
import 'package:karvaan/screens/CommunityPostPage.dart';
import 'package:karvaan/screens/UserProfilePage.dart';



Widget _buildPostCard(Post post, BuildContext context) {// In the _buildPostCard method, add navigation to post details  return Card(
    // ...existing code...
    child: InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CommunityPostPage(postId: post.id),
          ),
        );
      },
      child: Column(
        // ...existing code...
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => UserProfilePage(userId: post.authorId),
                  ),
                );
              },
              child: CircleAvatar(
                // ...existing code...
              ),
            ),
            // ...existing code...
          ),
          // ...existing code...
        ],
      ),
    ),
  );
}
// ...existing code...
