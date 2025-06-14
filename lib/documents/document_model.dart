class Document {
  final String id;
  final String title;
  final String fileName;
  final String filePath;
  final String fileType;
  final int fileSize;
  final DateTime uploadDate;
  final String? summary;
  final List<String> tags;
  final DocumentStatus status;
  final String? extractedText;
  final Map<String, dynamic>? metadata;

  Document({
    required this.id,
    required this.title,
    required this.fileName,
    required this.filePath,
    required this.fileType,
    required this.fileSize,
    required this.uploadDate,
    this.summary,
    this.tags = const [],
    this.status = DocumentStatus.processing,
    this.extractedText,
    this.metadata,
  });

  factory Document.fromJson(Map<String, dynamic> json) {
    return Document(
      id: json['id'],
      title: json['title'],
      fileName: json['fileName'],
      filePath: json['filePath'],
      fileType: json['fileType'],
      fileSize: json['fileSize'],
      uploadDate: DateTime.parse(json['uploadDate']),
      summary: json['summary'],
      tags: List<String>.from(json['tags'] ?? []),
      status: DocumentStatus.values.firstWhere(
        (e) => e.toString() == 'DocumentStatus.${json['status']}',
        orElse: () => DocumentStatus.processing,
      ),
      extractedText: json['extractedText'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'fileName': fileName,
      'filePath': filePath,
      'fileType': fileType,
      'fileSize': fileSize,
      'uploadDate': uploadDate.toIso8601String(),
      'summary': summary,
      'tags': tags,
      'status': status.toString().split('.').last,
      'extractedText': extractedText,
      'metadata': metadata,
    };
  }

  Document copyWith({
    String? id,
    String? title,
    String? fileName,
    String? filePath,
    String? fileType,
    int? fileSize,
    DateTime? uploadDate,
    String? summary,
    List<String>? tags,
    DocumentStatus? status,
    String? extractedText,
    Map<String, dynamic>? metadata,
  }) {
    return Document(
      id: id ?? this.id,
      title: title ?? this.title,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      fileType: fileType ?? this.fileType,
      fileSize: fileSize ?? this.fileSize,
      uploadDate: uploadDate ?? this.uploadDate,
      summary: summary ?? this.summary,
      tags: tags ?? this.tags,
      status: status ?? this.status,
      extractedText: extractedText ?? this.extractedText,
      metadata: metadata ?? this.metadata,
    );
  }

  String get formattedFileSize {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024)
      return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  bool get isProcessed => status == DocumentStatus.processed;
  bool get hasError => status == DocumentStatus.error;
  bool get isProcessing => status == DocumentStatus.processing;
}

enum DocumentStatus { processing, processed, error }

class DocumentUploadResult {
  final bool success;
  final String? documentId;
  final String? error;
  final Document? document;

  DocumentUploadResult({
    required this.success,
    this.documentId,
    this.error,
    this.document,
  });
}
