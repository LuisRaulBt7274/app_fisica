import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'document_model.dart';
import 'document_parser.dart';
import '../app/constants.dart';

class DocumentService {
  static const String _baseUrl = AppConstants.supabaseUrl;
  final DocumentParser _parser = DocumentParser();

  // Obtener lista de documentos
  Future<List<Document>> getDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/documents'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception('Error al obtener documentos: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Subir documento
  Future<DocumentUploadResult> uploadDocument(File file) async {
    try {
      // Validar archivo
      final validation = _validateFile(file);
      if (!validation.isValid) {
        return DocumentUploadResult(success: false, error: validation.error);
      }

      // Crear multipart request
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$_baseUrl/documents/upload'),
      );

      request.headers.addAll(_getHeaders());
      request.files.add(
        await http.MultipartFile.fromPath('document', file.path),
      );

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(responseBody);
        final document = Document.fromJson(data);

        // Procesar documento localmente para extracción de texto
        await _processDocumentLocally(document, file);

        return DocumentUploadResult(
          success: true,
          documentId: document.id,
          document: document,
        );
      } else {
        return DocumentUploadResult(
          success: false,
          error: 'Error al subir documento: ${response.statusCode}',
        );
      }
    } catch (e) {
      return DocumentUploadResult(
        success: false,
        error: 'Error de conexión: $e',
      );
    }
  }

  // Seleccionar archivo desde dispositivo
  Future<File?> pickDocument() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'jpg', 'jpeg', 'png'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        return File(result.files.single.path!);
      }
      return null;
    } catch (e) {
      throw Exception('Error al seleccionar archivo: $e');
    }
  }

  // Obtener documento por ID
  Future<Document?> getDocument(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/documents/$id'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener documento: $e');
    }
  }

  // Eliminar documento
  Future<bool> deleteDocument(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/documents/$id'),
        headers: _getHeaders(),
      );

      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      throw Exception('Error al eliminar documento: $e');
    }
  }

  // Buscar documentos
  Future<List<Document>> searchDocuments(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/documents/search?q=${Uri.encodeComponent(query)}'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((doc) => Document.fromJson(doc)).toList();
      } else {
        throw Exception('Error en búsqueda: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar documento
  Future<Document?> updateDocument(
    String id,
    Map<String, dynamic> updates,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/documents/$id'),
        headers: _getHeaders(),
        body: json.encode(updates),
      );

      if (response.statusCode == 200) {
        return Document.fromJson(json.decode(response.body));
      }
      return null;
    } catch (e) {
      throw Exception('Error al actualizar documento: $e');
    }
  }

  // Generar resumen con AI
  Future<String?> generateSummary(String documentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/documents/$documentId/summary'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['summary'];
      }
      return null;
    } catch (e) {
      throw Exception('Error al generar resumen: $e');
    }
  }

  // Extraer texto de documento
  Future<String?> extractText(String documentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/documents/$documentId/extract-text'),
        headers: _getHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['text'];
      }
      return null;
    } catch (e) {
      throw Exception('Error al extraer texto: $e');
    }
  }

  // Validar archivo
  FileValidationResult _validateFile(File file) {
    final fileName = file.path.split('/').last;
    final extension = fileName.split('.').last.toLowerCase();
    final fileSize = file.lengthSync();

    // Validar extensión
    const allowedExtensions = [
      'pdf',
      'doc',
      'docx',
      'txt',
      'jpg',
      'jpeg',
      'png',
    ];
    if (!allowedExtensions.contains(extension)) {
      return FileValidationResult(
        isValid: false,
        error:
            'Tipo de archivo no permitido. Formatos válidos: ${allowedExtensions.join(', ')}',
      );
    }

    // Validar tamaño (máximo 10MB)
    const maxSize = 10 * 1024 * 1024;
    if (fileSize > maxSize) {
      return FileValidationResult(
        isValid: false,
        error: 'El archivo es demasiado grande. Tamaño máximo: 10MB',
      );
    }

    return FileValidationResult(isValid: true);
  }

  // Procesar documento localmente
  Future<void> _processDocumentLocally(Document document, File file) async {
    try {
      final extractedText = await _parser.extractText(file);
      if (extractedText != null) {
        // Aquí podrías actualizar el documento con el texto extraído
        await updateDocument(document.id, {
          'extractedText': extractedText,
          'status': 'processed',
        });
      }
    } catch (e) {
      print('Error procesando documento localmente: $e');
    }
  }

  // Headers para las requests
  Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      // Agregar token de autenticación si es necesario
      // 'Authorization': 'Bearer $token',
    };
  }
}

class FileValidationResult {
  final bool isValid;
  final String? error;

  FileValidationResult({required this.isValid, this.error});
}
