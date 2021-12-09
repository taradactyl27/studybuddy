import 'package:flutter/material.dart';
import 'package:studybuddy/screens/course.dart';
import '../widgets/side_menu.dart';
import '../screens/main_courses.dart';
import '../responsive.dart';

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    // It provide us the width and height
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Responsive(
        // Let's work on our mobile part
        mobile: HomePage(),
        tablet: Row(
          children: [
            Expanded(
              flex: 6,
              child: HomePage(),
            ),
            Expanded(
              flex: 9,
              child: CoursePage(),
            ),
          ],
        ),
        desktop: Row(
          children: [
            // Once our width is less then 1300 then it start showing errors
            // Now there is no error if our width is less then 1340
            Expanded(
              flex: _size.width > 1340 ? 3 : 5,
              child: SideMenu(),
            ),
            Expanded(
              flex: _size.width > 1340 ? 4 : 6,
              child: HomePage(),
            ),
            Expanded(
              flex: _size.width > 1340 ? 6 : 8,
              child: CoursePage(),
            ),
          ],
        ),
      ),
    );
  }
}
