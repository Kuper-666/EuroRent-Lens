import 'dart:io';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<OcrResult> recognizeText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognized = await _textRecognizer.processImage(inputImage);

    final text = recognized.text;
    final blocks = recognized.blocks.map((block) => OcrBlock(
      text: block.text,
      boundingBox: block.boundingBox,
    )).toList();

    return OcrResult(
      fullText: text,
      blocks: blocks,
      confidence: text.length > 50 ? 0.85 : 0.5,
    );
  }

  void dispose() {
    _textRecognizer.close();
  }
}

class OcrResult {
  final String fullText;
  final List<OcrBlock> blocks;
  final double confidence;

  OcrResult({
    required this.fullText,
    required this.blocks,
    required this.confidence,
  });

  bool get isConfident => confidence >= 0.7;
}

class OcrBlock {
  final String text;
  final dynamic boundingBox;

  OcrBlock({required this.text, this.boundingBox});
}
