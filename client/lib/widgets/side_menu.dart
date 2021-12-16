import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/color_constants.dart';
import 'package:studybuddy/routes/routes.dart' as routes;
import 'package:flutter/foundation.dart' show kIsWeb;

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: MediaQuery.of(context).platformBrightness == Brightness.light
                ? kBgLightColor
                : kBgDarkColor),
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        child: ListView(
          padding: const EdgeInsets.only(top: 30),
          children: [
            Center(
              child: Container(
                height: kIsWeb && MediaQuery.of(context).size.width > 1100
                    ? 150
                    : 125,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fitHeight,
                    image: MediaQuery.of(context).platformBrightness ==
                            Brightness.light
                        ? const AssetImage("theme/sbuddy.png")
                        : const AssetImage("theme/sbuddy_dark.png"),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: kIsWeb ? 25.0 : 10.0),
              child: Divider(
                height: 20,
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(routes.homePage);
                },
                child: ListTile(
                    hoverColor: const Color(0xFF424242),
                    leading: const Icon(
                      Icons.home,
                    ),
                    title: Text("Home",
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        )))),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(routes.favoritesPage);
                },
                child: ListTile(
                    hoverColor: const Color(0xFF424242),
                    leading: const Icon(Icons.star),
                    title: Text("Favorites",
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        )))),
              ),
            ),
            Material(
              type: MaterialType.transparency,
              child: InkWell(
                onTap: () {
                  Navigator.of(context).pushNamed(routes.settingsPage);
                },
                child: ListTile(
                    leading: const Icon(Icons.settings),
                    title: Text("Settings",
                        style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        )))),
              ),
            ),
          ],
        ));
  }
}
