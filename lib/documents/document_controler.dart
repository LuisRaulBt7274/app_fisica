import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'document_service.dart';
import 'document_model.dart';
import 'physics_ai_service.dart'; // NUEVO: Servicio de IA para física

class DocumentController extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();
  final PhysicsAIService _aiService = PhysicsAIService(); // NUEVO

  List<Document> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;
  bool _isGeneratingContent = false; // NUEVO
  String? _error;
  String _searchQuery = '';

  // NUEVO: Getters específicos para física
  List<Document> get physicsDocuments =>
      _documents
          .where(
            (doc) =>
                doc.tags.any((tag) => _isPhysicsTag(tag)) ||
                _containsPhysicsContent(doc.extractedText ?? ''),
          )
          .toList();

  List<Document> get problemSets =>
      _documents
          .where(
            (doc) =>
                doc.tags.contains('problemas') ||
                doc.tags.contains('ejercicios'),
          )
          .toList();

  List<Document> get theoryDocuments =>
      _documents
          .where(
            (doc) =>
                doc.tags.contains('teoria') || doc.tags.contains('conceptos'),
          )
          .toList();

  // NUEVO: Generar contenido de física con IA
  Future<String?> generatePhysicsExercises({
    required String topic,
    required String difficulty,
    int quantity = 5,
  }) async {
    _setGeneratingContent(true);
    _clearError();

    try {
      final exercises = await _aiService.generateExercises(
        topic: topic,
        difficulty: difficulty,
        quantity: quantity,
      );

      if (exercises != null) {
        // Crear documento con ejercicios generados
        await _createAIGeneratedDocument(
          title: 'Ejercicios de $topic - $difficulty',
          content: exercises,
          tags: ['ejercicios', topic.toLowerCase(), difficulty, 'ia-generado'],
        );
      }

      return exercises;
    } catch (e) {
      _setError('Error generando ejercicios: $e');
      return null;
    } finally {
      _setGeneratingContent(false);
    }
  }
  // Continuación del archivo document_controller.dart

  Future<String?> generatePhysicsTheory({
    required String topic,
    required String level,
  }) async {
    _setGeneratingContent(true);
    _clearError();

    try {
      final theory = await _aiService.generateTheory(
        topic: topic,
        level: level,
      );

      if (theory != null) {
        await _createAIGeneratedDocument(
          title: 'Teoría de $topic - $level',
          content: theory,
          tags: ['teoria', topic.toLowerCase(), level, 'ia-generado'],
        );
      }

      return theory;
    } catch (e) {
      _setError('Error generando teoría: $e');
      return null;
    } finally {
      _setGeneratingContent(false);
    }
  }

  // Crear documento generado por IA
  Future<void> _createAIGeneratedDocument({
    required String title,
    required String content,
    required List<String> tags,
  }) async {
    try {
      // Crear archivo temporal
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/ai_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(content);

      // Subir documento
      final result = await _documentService.uploadDocument(file);
      if (result.success && result.document != null) {
        await _documentService.updateDocument(result.document!.id, {
          'title': title,
          'tags': tags,
          'extractedText': content,
        });

        await loadDocuments(); // Recargar lista
      }
    } catch (e) {
      _setError('Error creando documento: $e');
    }
  }

  // Getters
  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  bool get isGeneratingContent => _isGeneratingContent;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Métodos públicos
  Future<void> loadDocuments() async {
    _setLoading(true);
    _clearError();

    try {
      _documents = await _documentService.getDocuments();
      notifyListeners();
    } catch (e) {
      _setError('Error cargando documentos: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> searchDocuments(String query) async {
    _searchQuery = query;
    _setLoading(true);
    _clearError();

    try {
      if (query.trim().isEmpty) {
        _documents = await _documentService.getDocuments();
      } else {
        _documents = await _documentService.searchDocuments(query);
      }
      notifyListeners();
    } catch (e) {
      _setError('Error en búsqueda: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> deleteDocument(String id) async {
    try {
      final success = await _documentService.deleteDocument(id);
      if (success) {
        _documents.removeWhere((doc) => doc.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error eliminando documento: $e');
      return false;
    }
  }

  // Métodos de utilidad para física
  bool _isPhysicsTag(String tag) {
    const physicsTags = [
      'fisica',
      'mecanica',
      'termodinamica',
      'electromagnetismo',
      'optica',
      'ondas',
      'cuantica',
      'relatividad',
      'nuclear',
    ];
    return physicsTags.any(
      (physicsTag) => tag.toLowerCase().contains(physicsTag),
    );
  }

  bool _containsPhysicsContent(String text) {
    const physicsKeywords = [
      'fuerza',
      'energia',
      'velocidad',
      'aceleracion',
      'masa',
      'temperatura',
      'calor',
      'corriente',
      'voltaje',
      'onda',
      'frecuencia',
      'newton',
      'joule',
      'watt',
      'hertz',
    ];
    final lowerText = text.toLowerCase();
    return physicsKeywords.any((keyword) => lowerText.contains(keyword));
  }

  // Métodos privados para gestión de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setGeneratingContent(bool generating) {
    _isGeneratingContent = generating;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    if (_error != null) notifyListeners();
  }
}
