import 'dart:async';
import 'package:google_cloud_translation/google_cloud_translation.dart';

import '../secrets/secret_keys.dart';

class TranslateByGoogleServer {
  late Translation _translation;

  initializeTranslateByGoogleServer() {
    _translation = Translation(apiKey: GoogleTranslationApiKey);
  }

  Future<String?> textTranslate(String inputStr, String to) async {
    try {
      final translationModel = await _translation.translate(text: inputStr, to: to);
      return translationModel.translatedText;
    } on Exception catch (e) {
      print('Translation error: $e');
      return null;

    }
  }
}
