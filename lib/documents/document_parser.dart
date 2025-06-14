import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;

class DocumentParser {
  // Extraer texto de diferentes tipos de archivo
  Future<String?> extractText(File file) async {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();

    try {
      switch (extension) {
        case 'txt':
          return await _extractTextFromTxt(file);
        case 'pdf':
          return await _extractTextFromPdf(file);
        case 'doc':
        case 'docx':
          return await _extractTextFromWord(file);
        case 'jpg':
        case 'jpeg':
        case 'png':
          return await _extractTextFromImage(file);
        default:
          return null;
      }
    } catch (e) {
      print('Error extrayendo texto: $e');
      return null;
    }
  }

  // Extraer metadatos del documento
  Future<Map<String, dynamic>?> extractMetadata(File file) async {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final fileSize = file.lengthSync();
    final lastModified = file.lastModifiedSync();

    Map<String, dynamic> metadata = {
      'fileName': fileName,
      'fileSize': fileSize,
      'extension': extension,
      'lastModified': lastModified.toIso8601String(),
      'mimeType': _getMimeType(extension),
    };

    try {
      switch (extension) {
        case 'pdf':
          final pdfMetadata = await _extractPdfMetadata(file);
          metadata.addAll(pdfMetadata ?? {});
          break;
        case 'jpg':
        case 'jpeg':
        case 'png':
          final imageMetadata = await _extractImageMetadata(file);
          metadata.addAll(imageMetadata ?? {});
          break;
        default:
          break;
      }
    } catch (e) {
      print('Error extrayendo metadatos: $e');
    }

    return metadata;
  }

  // Extraer texto de archivo TXT
  Future<String> _extractTextFromTxt(File file) async {
    return await file.readAsString();
  }

  // Extraer texto de PDF (simulado - necesitarías una librería como pdf_text)
  Future<String?> _extractTextFromPdf(File file) async {
    try {
      // Para PDF real, usar: import 'package:pdf_text/pdf_text.dart';
      // PDFDoc doc = await PDFDoc.fromFile(file);
      // String text = await doc.text;
      // return text;

      // Simulación para propósitos de ejemplo
      return 'Texto extraído del PDF: ${file.path.split('/').last}\n\nEste es contenido simulado del PDF. En una implementación real, aquí estaría el texto extraído del documento PDF.';
    } catch (e) {
      print('Error extrayendo texto de PDF: $e');
      return null;
    }
  }

  // Extraer texto de Word (simulado - necesitarías una librería específica)
  Future<String?> _extractTextFromWord(File file) async {
    try {
      // Para Word real, necesitarías una librería como docx_to_text o similar
      // Implementación simulada
      return 'Texto extraído del documento Word: ${file.path.split('/').last}\n\nEste es contenido simulado del documento Word. En una implementación real, aquí estaría el texto extraído del documento.';
    } catch (e) {
      print('Error extrayendo texto de Word: $e');
      return null;
    }
  }

  // Extraer texto de imagen usando OCR (simulado)
  Future<String?> _extractTextFromImage(File file) async {
    try {
      // Para OCR real, usar: import 'package:google_ml_kit/google_ml_kit.dart';
      // final inputImage = InputImage.fromFile(file);
      // final textRecognizer = GoogleMlKit.vision.textRecognizer();
      // final RecognizedText recognizedText = await textRecognizer.processImage(inputImage);
      // return recognizedText.text;

      // Simulación para propósitos de ejemplo
      return 'Texto extraído de la imagen mediante OCR: ${file.path.split('/').last}\n\nEste es contenido simulado extraído de la imagen. En una implementación real, aquí estaría el texto reconocido por OCR.';
    } catch (e) {
      print('Error extrayendo texto de imagen: $e');
      return null;
    }
  }

  // Extraer metadatos de PDF
  Future<Map<String, dynamic>?> _extractPdfMetadata(File file) async {
    try {
      // Implementación simulada
      return {
        'pages': 10,
        'author': 'Autor del documento',
        'title': 'Título del PDF',
        'creator': 'Aplicación creadora',
        'creationDate':
            DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
      };
    } catch (e) {
      print('Error extrayendo metadatos de PDF: $e');
      return null;
    }
  }

  // Extraer metadatos de imagen
  Future<Map<String, dynamic>?> _extractImageMetadata(File file) async {
    try {
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image != null) {
        return {
          'width': image.width,
          'height': image.height,
          'channels': image.numChannels,
          'format': 'RGB',
          'hasAlpha': image.numChannels == 4,
        };
      }
      return null;
    } catch (e) {
      print('Error extrayendo metadatos de imagen: $e');
      return null;
    }
  }

  // Obtener tipo MIME basado en extensión
  String _getMimeType(String extension) {
    switch (extension.toLowerCase()) {
      case 'pdf':
        return 'application/pdf';
      case 'doc':
        return 'application/msword';
      case 'docx':
        return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
      case 'txt':
        return 'text/plain';
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      default:
        return 'application/octet-stream';
    }
  }

  // Dividir texto en chunks para procesamiento
  List<String> splitTextIntoChunks(
    String text, {
    int maxChunkSize = 1000,
    int overlap = 100,
  }) {
    if (text.length <= maxChunkSize) {
      return [text];
    }

    List<String> chunks = [];
    int start = 0;

    while (start < text.length) {
      int end = start + maxChunkSize;

      if (end >= text.length) {
        chunks.add(text.substring(start));
        break;
      }

      // Buscar un punto de división natural (espacio, punto, etc.)
      int lastSpace = text.lastIndexOf(' ', end);
      int lastPeriod = text.lastIndexOf('.', end);
      int lastNewline = text.lastIndexOf('\n', end);

      int splitPoint = [lastSpace, lastPeriod, lastNewline]
          .where((i) => i > start + maxChunkSize ~/ 2)
          .fold(end, (prev, curr) => curr > prev ? curr : prev);

      chunks.add(text.substring(start, splitPoint + 1).trim());
      start = splitPoint + 1 - overlap;

      if (start < 0) start = 0;
    }

    return chunks.where((chunk) => chunk.isNotEmpty).toList();
  }

  // Limpiar texto extraído
  String cleanExtractedText(String text) {
    // Remover caracteres especiales y espacios extra
    String cleaned =
        text
            .replaceAll(RegExp(r'\s+'), ' ') // Múltiples espacios a uno
            .replaceAll(RegExp(r'\n+'), '\n') // Múltiples saltos de línea a uno
            .replaceAll(
              RegExp(r'[^\w\s\.\,\;\:\!\?\-\(\)]'),
              '',
            ) // Mantener solo caracteres básicos
            .trim();

    return cleaned;
  }

  // Extraer palabras clave del texto
  List<String> extractKeywords(String text, {int maxKeywords = 10}) {
    // Palabras comunes a ignorar
    const stopWords = {
      'el',
      'la',
      'de',
      'que',
      'y',
      'a',
      'en',
      'un',
      'es',
      'se',
      'no',
      'te',
      'lo',
      'le',
      'da',
      'su',
      'por',
      'son',
      'con',
      'para',
      'al',
      'del',
      'los',
      'las',
      'una',
      'pero',
      'sus',
      'me',
      'este',
      'si',
      'o',
      'como',
      'ya',
      'todo',
      'esta',
      'fue',
      'muy',
      'tiene',
      'the',
      'and',
      'or',
      'but',
      'in',
      'on',
      'at',
      'to',
      'for',
      'of',
      'with',
      'by',
      'is',
      'are',
    };

    // Dividir en palabras y limpiar
    List<String> words =
        text
            .toLowerCase()
            .replaceAll(RegExp(r'[^\w\s]'), '')
            .split(' ')
            .where((word) => word.length > 3 && !stopWords.contains(word))
            .toList();

    // Contar frecuencias
    Map<String, int> wordCount = {};
    for (String word in words) {
      wordCount[word] = (wordCount[word] ?? 0) + 1;
    }

    // Ordenar por frecuencia y tomar las más comunes
    List<MapEntry<String, int>> sortedWords =
        wordCount.entries.toList()..sort((a, b) => b.value.compareTo(a.value));

    return sortedWords.take(maxKeywords).map((entry) => entry.key).toList();
  }
}
