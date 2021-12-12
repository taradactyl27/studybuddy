import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/routes/routes.dart' as routes;

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: kBgLightColor),
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        child: ListView(
          padding: const EdgeInsets.only(top: 20),
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
            ),
            Divider(),
            InkWell(
              onTap: () {
                Navigator.of(context)
                    .pushNamedAndRemoveUntil(routes.homePage, (route) => false);
              },
              child: ListTile(
                  leading: const Icon(Icons.home, color: kLightModeIcon),
                  title: Text("Home",
                      style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      )))),
            ),
            InkWell(
              child: ListTile(
                  leading: const Icon(Icons.star, color: kLightModeIcon),
                  title: Text("Favorites",
                      style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      )))),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                    routes.settingsPage, (route) => false);
              },
              child: ListTile(
                  leading: const Icon(Icons.settings, color: kLightModeIcon),
                  title: Text("Settings",
                      style: GoogleFonts.nunito(
                          textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      )))),
            ),
          ],
        ));
  }
}
