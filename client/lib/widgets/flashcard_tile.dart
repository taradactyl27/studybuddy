import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FlashCardTile extends StatelessWidget {
  const FlashCardTile({Key? key, required this.name}) : super(key: key);

  final String name;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 5, right: 5),
      child: Material(
        color: MediaQuery.of(context).platformBrightness == Brightness.light
            ? null
            : const Color(0xFF424242),
        elevation: 5,
        child: SizedBox(
          height: 150,
          width: 150,
          child: Column(
            verticalDirection: VerticalDirection.up,
            children: [
              Container(
                height: 10,
                decoration: BoxDecoration(
                    gradient: LinearGradient(colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary
                ])),
              ),
              Center(
                child: Container(
                  padding: const EdgeInsets.only(top: 10, bottom: 10),
                  child: Text(name,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.nunito(
                        textStyle: const TextStyle(fontSize: 16),
                      )),
                ),
              ),
              Icon(Icons.my_library_books,
                  size: 54,
                  color:
                      Theme.of(context).colorScheme.secondary.withOpacity(0.7))
            ],
          ),
        ),
      ),
    );
  }
}
