// // ignore_for_file: use_key_in_widget_constructors

// import 'package:flutter/material.dart';
// import 'commitment_homepage.dart';

// class UserSelectionPage extends StatelessWidget {
//   final List<User> users = [
//     User(
//       id: 'user1',
//       name: 'Koushi',
//       avatarPath: 'assets/images/profile.jpg', //profile pic
//       color: Colors.pink,
//     ),
//     User(
//       id: 'user2',
//       name: 'Kuwama',
//       avatarPath: 'assets/images/cries.jpg', //profile pic
//       color: Colors.purple,
//     ),
//   ];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey.shade900,
//       body: Container(
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             begin: Alignment.topCenter,
//             end: Alignment.bottomCenter,
//             colors: [
//               Colors.grey.shade900,
//               Colors.grey.shade800,
//             ],
//           ),
//         ),
//         child: SafeArea(
//           child: Column(
//             children: [
//               SizedBox(height: 60),

//               // Title
//               Text(
//                 'Who\'s tracking commitments?',
//                 style: TextStyle(
//                   fontSize: 32,
//                   fontWeight: FontWeight.bold,
//                   color: Colors.white,
//                   letterSpacing: 1.2,
//                 ),
//                 textAlign: TextAlign.center,
//               ),

//               SizedBox(height: 80),

//               // User Selection
//               Expanded(
//                 child: Center(
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: users
//                         .map((user) => _buildUserProfile(context, user))
//                         .toList(),
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildUserProfile(BuildContext context, User user) {
//     return GestureDetector(
//       onTap: () {
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (context) => CommitmentHomePage(selectedUser: user),
//           ),
//         );
//       },
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           // Avatar Container
//           Container(
//             width: 140,
//             height: 140,
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(20),
//               border: Border.all(
//                 color: Colors.transparent,
//                 width: 4,
//               ),
//               boxShadow: [
//                 BoxShadow(
//                   color: Colors.black.withOpacity(0.3),
//                   blurRadius: 10,
//                   offset: Offset(0, 5),
//                 ),
//               ],
//             ),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(16),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                     begin: Alignment.topLeft,
//                     end: Alignment.bottomRight,
//                     colors: [
//                       user.color.withOpacity(0.8),
//                       user.color,
//                     ],
//                   ),
//                 ),
//                 child: Center(
//                   child: Icon(
//                     user.id == 'user1' ? Icons.pets : Icons.favorite,
//                     size: 60,
//                     color: Colors.white,
//                   ),
//                 ),
//               ),
//             ),
//           ),

//           SizedBox(height: 20),

//           // User Name
//           Text(
//             user.name,
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//               color: Colors.white,
//               letterSpacing: 0.5,
//             ),
//             textAlign: TextAlign.center,
//           ),
//         ],
//       ),
//     );
//   }
// }

// class User {
//   final String id;
//   final String name;
//   final String avatarPath;
//   final Color color;

//   User({
//     required this.id,
//     required this.name,
//     required this.avatarPath,
//     required this.color,
//   });
// }
// ignore_for_file: use_key_in_widget_constructors, deprecated_member_use

import 'package:flutter/material.dart';
import 'commitment_homepage.dart';

class UserSelectionPage extends StatefulWidget {
  @override
  State<UserSelectionPage> createState() => _UserSelectionPageState();
}

class _UserSelectionPageState extends State<UserSelectionPage> {
  final List<User> users = [
    User(
      id: 'user1',
      name: 'Koushi',
      avatarPath: 'assets/images/profile.jpg',
      color: Colors.pink,
    ),
    User(
      id: 'user2',
      name: 'Unknown',
      avatarPath: 'assets/images/cries.jpg',
      color: Colors.purple,
    ),
  ];

  // Keep track of which user is being hovered
  String? hoveredUserId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade900,
              Colors.grey.shade800,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 60),
              Text(
                'Who\'s tracking commitments?',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.2,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 80),
              Expanded(
                child: Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: users
                        .map((user) => _buildUserProfile(context, user))
                        .toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserProfile(BuildContext context, User user) {
    final isHovered = hoveredUserId == user.id;

    return MouseRegion(
      onEnter: (_) => setState(() => hoveredUserId = user.id),
      onExit: (_) => setState(() => hoveredUserId = null),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CommitmentHomePage(selectedUser: user),
            ),
          );
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: Duration(milliseconds: 200),
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isHovered ? user.color : Colors.transparent,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isHovered
                        ? user.color.withOpacity(0.6)
                        : Colors.black.withOpacity(0.3),
                    blurRadius: isHovered ? 20 : 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  user.avatarPath,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 20),
            Text(
              user.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class User {
  final String id;
  final String name;
  final String avatarPath;
  final Color color;

  User({
    required this.id,
    required this.name,
    required this.avatarPath,
    required this.color,
  });
}
