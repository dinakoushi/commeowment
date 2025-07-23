// import 'package:flutter/material.dart';
// import 'landing_page.dart';

// void main() {
//   runApp(MyApp());
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'My Commeowment',
//       theme: ThemeData(
//         primarySwatch: Colors.pink,
//         visualDensity: VisualDensity.adaptivePlatformDensity,
//       ),
//       home: SplashScreen(),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'landing_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My Commeowment',
      home: SplashScreen(), // ✅ Should point to SplashScreen
    );
  }
}
