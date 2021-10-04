import 'dart:math';
import 'package:flutter/material.dart';
import 'package:studybuddy/route/route.dart' as route;
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:google_fonts/google_fonts.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  bool toggle = false;
  var currentUser = FirebaseAuth.instance.currentUser;
  late AnimationController _controller;
  late Animation _animation;
  setBottomBarIndex(index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 350),
        reverseDuration: const Duration(milliseconds: 275));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Alignment alignment1 = const Alignment(0.0, -1.3);
  Alignment alignment2 = const Alignment(0.0, -1.3);
  double size1 = 50;
  double size2 = 50;
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
              top: 50,
              left: 5,
              child: Container(
                  padding: const EdgeInsets.all(25),
                  child: Column(children: [
                    Text('Welcome back,',
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(fontSize: 24))),
                    Text(currentUser!.displayName ?? "anonymous",
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(fontSize: 24)))
                  ]))),
          Positioned(
            bottom: 0,
            left: 0,
            child: Container(
              width: size.width,
              height: 80,
              child: Stack(
                overflow: Overflow.visible,
                children: [
                  CustomPaint(
                    size: Size(size.width, 80),
                    painter: BNBCustomPainter(),
                  ),
                  Stack(alignment: const Alignment(0, -1.4), children: [
                    AnimatedAlign(
                        duration: toggle
                            ? const Duration(milliseconds: 275)
                            : const Duration(milliseconds: 850),
                        alignment: alignment1,
                        curve: toggle ? Curves.easeIn : Curves.easeOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 275),
                          curve: toggle ? Curves.easeIn : Curves.easeOut,
                          height: size1,
                          width: size1,
                          decoration: BoxDecoration(
                            color: const Color(0xff2a9d8f),
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          child: const Icon(Icons.mic_rounded,
                              color: Colors.white),
                        )),
                    AnimatedAlign(
                        duration: toggle
                            ? const Duration(milliseconds: 275)
                            : const Duration(milliseconds: 850),
                        alignment: alignment2,
                        curve: toggle ? Curves.easeIn : Curves.easeOut,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 275),
                          curve: toggle ? Curves.easeIn : Curves.easeOut,
                          height: size2,
                          width: size2,
                          decoration: BoxDecoration(
                            color: const Color(0xff2a9d8f),
                            borderRadius: BorderRadius.circular(40.0),
                          ),
                          child: const Icon(Icons.my_library_add_rounded,
                              color: Colors.white),
                        )),
                    Transform.rotate(
                      angle: _animation.value * pi * (3 / 4),
                      child: FloatingActionButton(
                          backgroundColor: Colors.blue,
                          child: const Icon(Icons.add_rounded,
                              color: Colors.white),
                          elevation: 0.1,
                          onPressed: () {
                            setState(() {
                              if (!toggle) {
                                toggle = !toggle;
                                _controller.forward();
                                Future.delayed(const Duration(milliseconds: 10),
                                    () {
                                  alignment1 = const Alignment(-0.35, -3.5);
                                });
                                Future.delayed(const Duration(milliseconds: 10),
                                    () {
                                  alignment2 = const Alignment(0.35, -3.5);
                                });
                              } else {
                                toggle = !toggle;
                                _controller.reverse();
                                alignment1 = const Alignment(0, -1.3);
                                alignment2 = const Alignment(0, -1.3);
                              }
                            });
                          }),
                    ),
                  ]),
                  Container(
                    width: size.width,
                    height: 80,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.home,
                            color: currentIndex == 0
                                ? Colors.blue
                                : Colors.grey.shade400,
                          ),
                          onPressed: () {
                            setBottomBarIndex(0);
                          },
                          splashColor: Colors.white,
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.menu_book_rounded,
                              color: currentIndex == 1
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(1);
                            }),
                        Container(
                          width: size.width * 0.20,
                        ),
                        IconButton(
                            icon: Icon(
                              Icons.bookmark,
                              color: currentIndex == 2
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(2);
                            }),
                        IconButton(
                            icon: Icon(
                              Icons.notifications,
                              color: currentIndex == 3
                                  ? Colors.blue
                                  : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setBottomBarIndex(3);
                            }),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}

class BNBCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = new Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    Path path = Path();
    path.moveTo(0, 20); // Start
    path.quadraticBezierTo(size.width * 0.20, 0, size.width * 0.35, 0);
    path.quadraticBezierTo(size.width * 0.40, 0, size.width * 0.40, 20);
    path.arcToPoint(Offset(size.width * 0.60, 20),
        radius: Radius.circular(20.0), clockwise: false);
    path.quadraticBezierTo(size.width * 0.60, 0, size.width * 0.65, 0);
    path.quadraticBezierTo(size.width * 0.80, 0, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.lineTo(0, 20);
    canvas.drawShadow(path, Colors.black, 5, true);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
