

import 'package:flutter/material.dart';
import 'package:google_cloud_translation/google_cloud_translation.dart';
import 'package:chatus/managers/translate_by_googleserver.dart';

class TmpPage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<TmpPage> {
  late Translation _translation;
  final String _text =
      'Toda persona tiene derecho a la educación. La educación debe ser gratuita, al menos en lo concerniente a la instrucción elemental y fundamental. La instrucción elemental será obligatoria. La instrucción técnica y profesional habrá de ser generalizada; el acceso a los estudios superiores será igual para todos, en función de los méritos respectivos.';
  TranslationModel _translated = TranslationModel(translatedText: '', detectedSourceLanguage: '');
  TranslationModel _detected = TranslationModel(translatedText: '', detectedSourceLanguage: '');

  TranslateByGoogleServer translateByGoogleServer = TranslateByGoogleServer();
  late final String? testText;
  @override
  void initState() {
    translateByGoogleServer.initializeTranslateByGoogleServer();
    test();
    super.initState();
  }
  test() async{
    testText = await translateByGoogleServer.textTranslate("Hello I am a bag", 'ko');
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Translate demo'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Initial text',
              ),
              Text(_text),
              SizedBox(height: 30),
              Text('Translated text'),
              Text(_translated.translatedText),
              Text('Detected language - ${_translated.detectedSourceLanguage}', style: TextStyle(color: Colors.red)),
              const SizedBox(height: 20),
              Text('Language detected with detectLang, without translation - ${_detected.detectedSourceLanguage}',
                  style: TextStyle(color: Colors.red)),
              Text(testText!),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          _translated = await _translation.translate(text: _text, to: 'en');
          _detected = await _translation.detectLang(text: _text);
          setState(() {});
        },
        tooltip: 'Translate',
        child: Icon(Icons.language),
      ),
    );
  }
}