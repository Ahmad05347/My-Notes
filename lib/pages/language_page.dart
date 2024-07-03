import 'package:flutter/material.dart';
import 'package:flutter_localization/flutter_localization.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:my_notes/localization/locals.dart';

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late FlutterLocalization _flutterLocalization;
  late String _currentLocale;

  @override
  void initState() {
    super.initState();
    _flutterLocalization = FlutterLocalization.instance;
    _currentLocale = _flutterLocalization.currentLocale!.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          LocalData.title.getString(
            context,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "English",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                  ),
                ),
                Checkbox(
                  value: _currentLocale == 'en',
                  onChanged: (value) {
                    if (value == true) {
                      _setLocale('en');
                    }
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "عربي",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                  ),
                ),
                Checkbox(
                  value: _currentLocale == 'ar',
                  onChanged: (value) {
                    if (value == true) {
                      _setLocale('ar');
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _setLocale(String value) {
    _flutterLocalization.translate(value);
    setState(() {
      _currentLocale = value;
    });
  }
}
