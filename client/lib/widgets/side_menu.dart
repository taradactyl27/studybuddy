import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/routes/routes.dart' as routes;

class SideMenu extends StatelessWidget {
  const SideMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: const BoxDecoration(color: Colors.white),
        padding: const EdgeInsets.all(20),
        height: double.infinity,
        child: ListView(
          padding: const EdgeInsets.only(top:20),
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
              onTap: (){
                Navigator.of(context).pushNamedAndRemoveUntil(
                        routes.homePage, (route) => false);
              },
              child: ListTile(
                leading: const Icon(Icons.home,color: Colors.black),
                title: Text("Home", style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        )))
              ),
            ),
            InkWell(
              child: ListTile(
                leading: const Icon(Icons.account_circle,color: Colors.black),
                title: Text("Profile", style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        )))
              ),
            ),
            InkWell(
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                        routes.settingsPage, (route) => false);
              },
              child: ListTile(
                leading: const Icon(Icons.settings, color: Colors.black),
                title: Text("Settings", style: GoogleFonts.nunito(
                            textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        )))
              ),
            ),
          ],
        ));
  }
}
