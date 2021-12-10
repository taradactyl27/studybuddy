import 'package:flutter/material.dart';

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.only(left:20, right: 20, bottom:20, top: 45),
        height: double.infinity,
        child: Column(
          children: [
            Center(
              child: Container(
                height: 150,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: AssetImage("theme/sbuddy.png"),
                  ),
                ),
              ),
            )
          ],
        ));
  }
}
