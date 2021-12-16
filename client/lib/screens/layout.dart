import 'package:flutter/material.dart';
import 'package:studybuddy/screens/course.dart';
import '../widgets/side_menu.dart';
import '../screens/home.dart';
import '../responsive.dart';

class Layout extends StatefulWidget {
  const Layout({Key? key}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    Size _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Responsive(
        mobile: const HomePage(),
        tablet: Row(
          children: const [
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
            Expanded(
              flex: _size.width > 1340 ? 3 : 5,
              child: const SideMenu(),
            ),
            Expanded(
              flex: _size.width > 1340 ? 4 : 6,
              child: const HomePage(),
            ),
            Expanded(
              flex: _size.width > 1340 ? 6 : 8,
              child: const CoursePage(),
            ),
          ],
        ),
      ),
    );
  }
}
