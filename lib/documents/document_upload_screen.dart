import 'dart:io';
import 'package:flutter/material.dart';
import 'document_service.dart';
import 'document_model.dart';
import '../widgets/custom_button.dart';
import '../widgets/loading_indicator.dart';

class DocumentUploadScreen extends StatefulWidget {
  const DocumentUploadScreen({Key? key}) : super(key: key);

  @override
  State<DocumentUploadScreen> createState() => _DocumentUploadScreenState();
}

class _DocumentUploadScreenState extends State<DocumentUploadScreen> {
  final DocumentService _documentService = DocumentService();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();

  List<Document> _documents = [];
  File? _selectedFile;
  bool _isLoading = false;
  bool _isUploading = false;
  String? _error;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final documents = await _documentService.getDocuments();
      setState(() {
        _documents = documents;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _pickFile() async {
    try {
      final file = await _documentService.pickDocument();
      if (file != null) {
        setState(() {
          _selectedFile = file;
          _titleController.text = file.path.split('/').last.split('.').first;
        });
      }
    } catch (e) {
      _showError('Error al seleccionar archivo: $e');
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
      _error = null;
    });

    try {
      final result = await _documentService.uploadDocument(_selectedFile!);

      if (result.success) {
        // Actualizar título y tags si es necesario
        if (result.document != null) {
          final tags =
              _tagsController.text
                  .split(',')
                  .map((tag) => tag.trim())
                  .where((tag) => tag.isNotEmpty)
                  .toList();

          if (_titleController.text.trim() != result.document!.fileName ||
              tags.isNotEmpty) {
            await _documentService.updateDocument(result.document!.id, {
              'title': _titleController.text.trim(),
              'tags': tags,
            });
          }
        }

        _showSuccess('Documento subido exitosamente');
        _clearForm();
        _loadDocuments();
      } else {
        _showError(result.error ?? 'Error al subir documento');
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      setState(() {
        _isUploading = false;
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
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
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
          _showError('Error al eliminar documento');
        }
      } catch (e) {
        _showError('Error: $e');
      }
    }
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
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _clearForm() {
    setState(() {
      _selectedFile = null;
      _titleController.clear();
      _tagsController.clear();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Documentos'),
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
                      ),
                      child: Column(
                        children: [
                          Icon(
                            Icons.cloud_upload,
                            size: 48,
                            color: Colors.grey.shade600,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _selectedFile == null
                                ? 'Toca para seleccionar archivo'
                                : _selectedFile!.path.split('/').last,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
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
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Campo de tags
                  TextField(
                    controller: _tagsController,
                    decoration: const InputDecoration(
                      labelText: 'Tags (separados por comas)',
                      border: OutlineInputBorder(),
                      helperText: 'Ej: física, matemáticas, ejercicios',
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Botón de subir
                  SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: _isUploading ? 'Subiendo...' : 'Subir documento',
                      onPressed: _isUploading ? null : _uploadDocument,
                      isLoading: _isUploading,
                    ),
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
                hintText: 'Buscar documentos...',
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
      return const Center(child: LoadingIndicator());
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

  void _showDocumentDialog(String title, String content) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: SingleChildScrollView(child: Text(content)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
    );
  }

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
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hoy';
    } else if (difference.inDays == 1) {
      return 'Ayer';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _tagsController.dispose();
    super.dispose();
  }
}
