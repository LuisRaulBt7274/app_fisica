import 'dart:io';
import 'package:flutter/foundation.dart';
import 'document_service.dart';
import 'document_model.dart';

class DocumentController extends ChangeNotifier {
  final DocumentService _documentService = DocumentService();

  List<Document> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  String _searchQuery = '';

  // Getters
  List<Document> get documents => _documents;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get error => _error;
  String get searchQuery => _searchQuery;

  // Filtros y ordenamiento
  List<Document> get filteredDocuments {
    if (_searchQuery.isEmpty) return _documents;

    return _documents.where((doc) {
      final query = _searchQuery.toLowerCase();
      return doc.title.toLowerCase().contains(query) ||
          doc.fileName.toLowerCase().contains(query) ||
          doc.tags.any((tag) => tag.toLowerCase().contains(query)) ||
          (doc.extractedText?.toLowerCase().contains(query) ?? false);
    }).toList();
  }

  List<Document> get recentDocuments {
    final sortedDocs = List<Document>.from(_documents);
    sortedDocs.sort((a, b) => b.uploadDate.compareTo(a.uploadDate));
    return sortedDocs.take(5).toList();
  }

  Map<String, List<Document>> get documentsByType {
    final Map<String, List<Document>> grouped = {};
    for (final doc in _documents) {
      final type = doc.fileType.toUpperCase();
      grouped[type] = grouped[type] ?? [];
      grouped[type]!.add(doc);
    }
    return grouped;
  }

  // Estadísticas
  int get totalDocuments => _documents.length;
  int get processedDocuments => _documents.where((d) => d.isProcessed).length;
  int get processingDocuments => _documents.where((d) => d.isProcessing).length;
  int get errorDocuments => _documents.where((d) => d.hasError).length;

  double get totalSizeInMB {
    return _documents.fold(0, (sum, doc) => sum + doc.fileSize) / (1024 * 1024);
  }

  // Cargar documentos
  Future<void> loadDocuments() async {
    _setLoading(true);
    _clearError();

    try {
      _documents = await _documentService.getDocuments();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar documentos: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Subir documento
  Future<DocumentUploadResult> uploadDocument(
    File file, {
    String? title,
    List<String>? tags,
  }) async {
    _setUploading(true);
    _clearError();

    try {
      final result = await _documentService.uploadDocument(file);

      if (result.success && result.document != null) {
        // Actualizar con título y tags si se proporcionaron
        if (title != null || tags != null) {
          final updates = <String, dynamic>{};
          if (title != null) updates['title'] = title;
          if (tags != null) updates['tags'] = tags;

          if (updates.isNotEmpty) {
            await _documentService.updateDocument(result.document!.id, updates);
          }
        }

        // Recargar documentos
        await loadDocuments();
      }

      return result;
    } catch (e) {
      _setError('Error al subir documento: $e');
      return DocumentUploadResult(success: false, error: e.toString());
    } finally {
      _setUploading(false);
    }
  }

  // Eliminar documento
  Future<bool> deleteDocument(String id) async {
    _clearError();

    try {
      final success = await _documentService.deleteDocument(id);
      if (success) {
        _documents.removeWhere((doc) => doc.id == id);
        notifyListeners();
      }
      return success;
    } catch (e) {
      _setError('Error al eliminar documento: $e');
      return false;
    }
  }

  // Buscar documentos
  Future<void> searchDocuments(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      notifyListeners();
      return;
    }

    _setLoading(true);
    _clearError();

    try {
      _documents = await _documentService.searchDocuments(query);
      notifyListeners();
    } catch (e) {
      _setError('Error en búsqueda: $e');
    } finally {
      _setLoading(false);
    }
  }

  // Limpiar búsqueda
  void clearSearch() {
    _searchQuery = '';
    loadDocuments();
  }

  // Actualizar documento
  Future<Document?> updateDocument(
    String id,
    Map<String, dynamic> updates,
  ) async {
    _clearError();

    try {
      final updatedDoc = await _documentService.updateDocument(id, updates);
      if (updatedDoc != null) {
        final index = _documents.indexWhere((doc) => doc.id == id);
        if (index != -1) {
          _documents[index] = updatedDoc;
          notifyListeners();
        }
      }
      return updatedDoc;
    } catch (e) {
      _setError('Error al actualizar documento: $e');
      return null;
    }
  }

  // Generar resumen
  Future<String?> generateSummary(String documentId) async {
    _clearError();

    try {
      final summary = await _documentService.generateSummary(documentId);
      if (summary != null) {
        // Actualizar documento con el resumen
        await updateDocument(documentId, {'summary': summary});
      }
      return summary;
    } catch (e) {
      _setError('Error al generar resumen: $e');
      return null;
    }
  }

  // Extraer texto
  Future<String?> extractText(String documentId) async {
    _clearError();

    try {
      final text = await _documentService.extractText(documentId);
      if (text != null) {
        // Actualizar documento con el texto extraído
        await updateDocument(documentId, {
          'extractedText': text,
          'status': 'processed',
        });
      }
      return text;
    } catch (e) {
      _setError('Error al extraer texto: $e');
      return null;
    }
  }

  // Obtener documento por ID
  Document? getDocumentById(String id) {
    try {
      return _documents.firstWhere((doc) => doc.id == id);
    } catch (e) {
      return null;
    }
  }

  // Filtrar por tipo de archivo
  List<Document> getDocumentsByType(String fileType) {
    return _documents
        .where((doc) => doc.fileType.toLowerCase() == fileType.toLowerCase())
        .toList();
  }

  // Filtrar por estado
  List<Document> getDocumentsByStatus(DocumentStatus status) {
    return _documents.where((doc) => doc.status == status).toList();
  }

  // Filtrar por tags
  List<Document> getDocumentsByTag(String tag) {
    return _documents
        .where(
          (doc) => doc.tags.any((t) => t.toLowerCase() == tag.toLowerCase()),
        )
        .toList();
  }

  // Obtener todos los tags únicos
  List<String> getAllTags() {
    final Set<String> allTags = {};
    for (final doc in _documents) {
      allTags.addAll(doc.tags);
    }
    return allTags.toList()..sort();
  }

  // Obtener documentos por rango de fechas
  List<Document> getDocumentsByDateRange(DateTime start, DateTime end) {
    return _documents
        .where(
          (doc) =>
              doc.uploadDate.isAfter(start) && doc.uploadDate.isBefore(end),
        )
        .toList();
  }

  // Ordenar documentos
  void sortDocuments(DocumentSortType sortType, {bool ascending = true}) {
    switch (sortType) {
      case DocumentSortType.name:
        _documents.sort(
          (a, b) =>
              ascending
                  ? a.title.compareTo(b.title)
                  : b.title.compareTo(a.title),
        );
        break;
      case DocumentSortType.date:
        _documents.sort(
          (a, b) =>
              ascending
                  ? a.uploadDate.compareTo(b.uploadDate)
                  : b.uploadDate.compareTo(a.uploadDate),
        );
        break;
      case DocumentSortType.size:
        _documents.sort(
          (a, b) =>
              ascending
                  ? a.fileSize.compareTo(b.fileSize)
                  : b.fileSize.compareTo(a.fileSize),
        );
        break;
      case DocumentSortType.type:
        _documents.sort(
          (a, b) =>
              ascending
                  ? a.fileType.compareTo(b.fileType)
                  : b.fileType.compareTo(a.fileType),
        );
        break;
    }
    notifyListeners();
  }

  // Refrescar documentos
  Future<void> refresh() async {
    await loadDocuments();
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setUploading(bool uploading) {
    _isUploading = uploading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Limpiar estado
  void clear() {
    _documents.clear();
    _searchQuery = '';
    _isLoading = false;
    _isUploading = false;
    _error = null;
    notifyListeners();
  }
}

enum DocumentSortType { name, date, size, type }
