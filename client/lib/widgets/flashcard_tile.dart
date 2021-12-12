import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:studybuddy/color_constants.dart';

class FlashCardTile extends StatelessWidget {
  const FlashCardTile({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Material(
        elevation: 5,
        child: SizedBox(
          height: 150,
          width: 150,
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              Container(
                height: 10,
                decoration: const BoxDecoration(gradient: primaryGradient),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(
                            color: kDarkTextColor, fontSize: 16),
                      )),
                ),
              ),
              const Icon(Icons.my_library_books, size: 54)
            ],
          ),
        ),
      ),
    );
  }
}
