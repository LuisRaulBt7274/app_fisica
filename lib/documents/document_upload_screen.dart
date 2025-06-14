import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'document_service.dart';
import 'document_model.dart';
import 'document_parser.dart';
import 'physics_ai_service.dart';
import '../app/constants.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  // Servicios
  final DocumentService _documentService = DocumentService();
  final PhysicsAIService _aiService = PhysicsAIService();
  final DocumentParser _parser = DocumentParser();

  // Controladores
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  // Estado
  List<Document> _documents = [];
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  String _searchQuery = '';
  File? _selectedFile;

  // Tema de física seleccionado
  String? _selectedPhysicsTopic;

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  // MÉTODOS PRINCIPALES

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documents = await _documentService.getDocuments();
      setState(() {
        _documents = documents;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await _documentService.pickDocument();
      setState(() {
        _selectedFile = file;
      });
    } catch (e) {
      _showError('Error seleccionando archivo: $e');
    }
  }

  Future<void> _uploadDocument() async {
    if (_selectedFile == null) {
      _showError('Por favor selecciona un archivo');
      return;
    }

    if (_titleController.text.trim().isEmpty) {
      _showError('Por favor ingresa un título');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      // Subir documento
      final result = await _documentService.uploadDocument(_selectedFile!);

      if (result.success && result.document != null) {
        // Analizar contenido de física
        String? extractedText;
        try {
          extractedText = await _parser.extractText(_selectedFile!);
        } catch (e) {
          print('Error extrayendo texto: $e');
        }

        // Preparar tags
        final tags =
            _tagsController.text
                .split(',')
                .map((tag) => tag.trim())
                .where((tag) => tag.isNotEmpty)
                .toList();

        // Agregar tema de física seleccionado como tag
        if (_selectedPhysicsTopic != null) {
          tags.add(_selectedPhysicsTopic!.toLowerCase());
        }

        // Análisis con IA de física
        Map<String, dynamic>? physicsAnalysis;
        if (extractedText != null && extractedText.isNotEmpty) {
          try {
            physicsAnalysis = await _aiService.analyzePhysicsDocument(
              extractedText,
            );

            // Agregar tags sugeridos de física
            if (physicsAnalysis != null &&
                physicsAnalysis['suggestedTags'] != null) {
              final suggestedTags = List<String>.from(
                physicsAnalysis['suggestedTags'],
              );
              tags.addAll(suggestedTags);
            }
          } catch (e) {
            print('Error en análisis de IA: $e');
          }
        }

        // Actualizar documento con metadatos de física
        await _documentService.updateDocument(result.document!.id, {
          'title': _titleController.text.trim(),
          'tags': tags.toSet().toList(), // Eliminar duplicados
          'extractedText': extractedText,
          'physicsAnalysis': physicsAnalysis,
          'physicsTopic': _selectedPhysicsTopic,
        });

        _showSuccess('Documento de física subido exitosamente');
        _clearForm();
        _loadDocuments();
      } else {
        _showError(result.error ?? 'Error desconocido');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedFile = null;
      _titleController.clear();
      _tagsController.clear();
      _selectedPhysicsTopic = null;
    });
  }

  Future<void> _searchDocuments() async {
    if (_searchQuery.trim().isEmpty) {
      _loadDocuments();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final documents = await _documentService.searchDocuments(_searchQuery);
      setState(() {
        _documents = documents;
      });
    } catch (e) {
      _showError('Error en búsqueda: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteDocument(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: const Text(
              '¿Estás seguro de que quieres eliminar este documento?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirm == true) {
      try {
        final success = await _documentService.deleteDocument(id);
        if (success) {
          _showSuccess('Documento eliminado');
          _loadDocuments();
        } else {
          _showError('Error eliminando documento');
        }
      } catch (e) {
        _showError('Error: $e');
      }
    }
  }

  // MÉTODOS DE IA PARA FÍSICA

  Future<void> _generateExercises() async {
    if (_selectedPhysicsTopic == null) {
      _showError('Por favor selecciona un tema de física');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final exercises = await _aiService.generateExercises(
        topic: _selectedPhysicsTopic!,
        difficulty: 'intermedio',
        quantity: 5,
      );

      if (exercises != null) {
        _showAIContentDialog('Ejercicios de $_selectedPhysicsTopic', exercises);
      } else {
        _showError('Error generando ejercicios');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  Future<void> _generateTheory() async {
    if (_selectedPhysicsTopic == null) {
      _showError('Por favor selecciona un tema de física');
      return;
    }

    setState(() {
      _isUploading = true;
    });

    try {
      final theory = await _aiService.generateTheory(
        topic: _selectedPhysicsTopic!,
        level: 'intermedio',
      );

      if (theory != null) {
        _showAIContentDialog('Teoría de $_selectedPhysicsTopic', theory);
      } else {
        _showError('Error generando teoría');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  // Guardar contenido generado por IA
  Future<void> _saveAIContent(String title, String content) async {
    try {
      // Crear archivo temporal con el contenido
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/ai_generated_${DateTime.now().millisecondsSinceEpoch}.txt',
      );
      await file.writeAsString(content);

      // Subir como documento
      final result = await _documentService.uploadDocument(file);
      if (result.success && result.document != null) {
        await _documentService.updateDocument(result.document!.id, {
          'title': title,
          'tags': [
            'ia-generado',
            'fisica',
            _selectedPhysicsTopic?.toLowerCase() ?? 'general',
          ],
          'extractedText': content,
        });
        _showSuccess('Contenido guardado como documento');
        _loadDocuments();
      }
    } catch (e) {
      _showError('Error guardando contenido: $e');
    }
  }

  // MÉTODOS DE ANÁLISIS DE DOCUMENTOS

  Future<void> _generateSummary(Document document) async {
    try {
      _showSuccess('Generando resumen...');
      final summary = await _documentService.generateSummary(document.id);
      if (summary != null) {
        _showDocumentDialog('Resumen - ${document.title}', summary);
      } else {
        _showError('Error al generar resumen');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  Future<void> _extractText(Document document) async {
    try {
      _showSuccess('Extrayendo texto...');
      final text = await _documentService.extractText(document.id);
      if (text != null) {
        _showDocumentDialog('Texto extraído - ${document.title}', text);
      } else {
        _showError('Error al extraer texto');
      }
    } catch (e) {
      _showError('Error: $e');
    }
  }

  // MÉTODOS DE UI

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showAIContentDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child: SingleChildScrollView(child: Text(content)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveAIContent(title, content);
                },
                child: const Text('Guardar'),
              ),
            ],
          ),
    );
  }

  void _showDocumentDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SizedBox(
              width: double.maxFinite,
              height: 300,
              child: SingleChildScrollView(child: Text(content)),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

  // BUILD METHOD

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos de Física'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDocuments,
          ),
        ],
      ),
      body: Column(
        children: [
          // Sección de subida
          Card(
            margin: const EdgeInsets.all(16),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Subir nuevo documento',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Selector de archivo
                  InkWell(
                    onTap: _pickFile,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: Colors.blue.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile == null
                                ? 'Toca para seleccionar archivo'
                                : _selectedFile!.path.split('/').last,
                            style: TextStyle(
                              color:
                                  _selectedFile == null
                                      ? Colors.grey.shade600
                                      : Colors.blue.shade700,
                              fontSize: 16,
                              fontWeight:
                                  _selectedFile != null
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                            ),
                          ),
                          if (_selectedFile != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Tamaño: ${(_selectedFile!.lengthSync() / 1024 / 1024).toStringAsFixed(2)} MB',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de título
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: 'Título del documento',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.title),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Selector de tema de física
                  DropdownButtonFormField<String>(
                    value: _selectedPhysicsTopic,
                    decoration: const InputDecoration(
                      labelText: 'Tema de Física',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.science),
                    ),
                    items:
                        AppConstants.physicsTopics.map((topic) {
                          return DropdownMenuItem(
                            value: topic,
                            child: Text(topic),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPhysicsTopic = value;
                      });
                    },
                  ),

                  const SizedBox(height: 16),

                  // Campo de tags
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (separados por comas)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.tag),
                      helperText: 'Ej: problemas, termodinámica, nivel-básico',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botones de acción
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _isUploading ? null : _uploadDocument,
                          icon:
                              _isUploading
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.upload_file),
                          label: Text(
                            _isUploading ? 'Subiendo...' : 'Subir documento',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Sección de generación con IA
                  const Divider(height: 32),
                  const Text(
                    'Generar contenido con IA',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _selectedPhysicsTopic == null || _isUploading
                                  ? null
                                  : _generateExercises,
                          icon: const Icon(Icons.quiz),
                          label: const Text('Ejercicios'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed:
                              _selectedPhysicsTopic == null || _isUploading
                                  ? null
                                  : _generateTheory,
                          icon: const Icon(Icons.book),
                          label: const Text('Teoría'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Buscar documentos de física...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                suffixIcon:
                    _searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                            _loadDocuments();
                          },
                        )
                        : null,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              onSubmitted: (_) => _searchDocuments(),
            ),
          ),

          const SizedBox(height: 16),

          // Lista de documentos
          Expanded(child: _buildDocumentsList()),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar documentos',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadDocuments,
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }

    if (_documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron documentos'
                  : 'No hay documentos',
              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
            ),
            if (_searchQuery.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Intenta con otros términos de búsqueda',
                style: TextStyle(color: Colors.grey.shade500),
              ),
            ],
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDocuments,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          final document = _documents[index];
          return _buildDocumentCard(document);
        },
      ),
    );
  }

  Widget _buildDocumentCard(Document document) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getFileTypeColor(document.fileType),
          child: Icon(_getFileTypeIcon(document.fileType), color: Colors.white),
        ),
        title: Text(
          document.title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(document.fileName),
            const SizedBox(height: 4),
            Row(
              children: [
                Text(
                  document.formattedFileSize,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(document.status),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    _getStatusText(document.status),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
            if (document.tags.isNotEmpty) ...[
              const SizedBox(height: 4),
              Wrap(
                spacing: 4,
                runSpacing: 2,
                children:
                    document.tags.take(3).map((tag) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade100,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ],
            const SizedBox(height: 4),
            Text(
              'Subido: ${_formatDate(document.uploadDate)}',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'delete':
                _deleteDocument(document.id);
                break;
              case 'summary':
                _generateSummary(document);
                break;
              case 'extract':
                _extractText(document);
                break;
            }
          },
          itemBuilder:
              (context) => [
                const PopupMenuItem(
                  value: 'summary',
                  child: ListTile(
                    leading: Icon(Icons.summarize),
                    title: Text('Generar resumen'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'extract',
                  child: ListTile(
                    leading: Icon(Icons.text_fields),
                    title: Text('Extraer texto'),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text(
                      'Eliminar',
                      style: TextStyle(color: Colors.red),
                    ),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ],
        ),
        onTap: () => _showDocumentDetails(document),
      ),
    );
  }

  void _showDocumentDetails(Document document) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            maxChildSize: 0.9,
            minChildSize: 0.5,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: _getFileTypeColor(document.fileType),
                          child: Icon(
                            _getFileTypeIcon(document.fileType),
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                document.title,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                document.fileName,
                                style: TextStyle(color: Colors.grey.shade600),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDetailRow(
                              'Tamaño',
                              document.formattedFileSize,
                            ),
                            _buildDetailRow(
                              'Tipo',
                              document.fileType.toUpperCase(),
                            ),
                            _buildDetailRow(
                              'Estado',
                              _getStatusText(document.status),
                            ),
                            _buildDetailRow(
                              'Subido',
                              _formatDate(document.uploadDate),
                            ),
                            if (document.tags.isNotEmpty)
                              _buildDetailRow('Tags', document.tags.join(', ')),
                            if (document.summary != null) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Resumen:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(document.summary!),
                            ],
                            if (document.extractedText != null) ...[
                              const SizedBox(height: 16),
                              const Text(
                                'Texto extraído:',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                document.extractedText!,
                                maxLines: 10,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  // MÉTODOS DE UTILIDAD

  Color _getFileTypeColor(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Colors.red;
      case 'doc':
      case 'docx':
        return Colors.blue;
      case 'txt':
        return Colors.grey;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Colors.green;
      default:
        return Colors.orange;
    }
  }

  IconData _getFileTypeIcon(String fileType) {
    switch (fileType.toLowerCase()) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'txt':
        return Icons.text_snippet;
      case 'jpg':
      case 'jpeg':
      case 'png':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getStatusColor(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.processing:
        return Colors.orange;
      case DocumentStatus.processed:
        return Colors.green;
      case DocumentStatus.error:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(DocumentStatus status) {
    switch (status) {
      case DocumentStatus.processing:
        return 'Procesando';
      case DocumentStatus.processed:
        return 'Procesado';
      case DocumentStatus.error:
        return 'Error';
      default:
        return 'Desconocido';
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays >= 1) {
      return '${date.day}/${date.month}/${date.year}';
    } else if (difference.inHours >= 1) {
      return '${difference.inHours} horas atrás';
    } else if (difference.inMinutes >= 1) {
      return '${difference.inMinutes} minutos atrás';
    } else {
      return 'hace unos segundos';
    }
  }
}
