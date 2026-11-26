import 'package:flutter/material.dart';

import 'health_record.dart';
import 'sync_status.dart';

/// The medical-category filters shown in the Documents library, matching
/// the design's `docFilters`. Each maps to one of the shared accent hues.
enum DocumentCategory {
  labReport('Lab report', Icons.science_outlined),
  prescription('Prescription', Icons.receipt_long_outlined),
  radiology('Imaging', Icons.image_outlined),
  bill('Bill', Icons.receipt_outlined),
  vaccineCertificate('Vaccine certificate', Icons.vaccines_outlined),
  insurance('Insurance', Icons.shield_outlined),
  other('Other', Icons.description_outlined);

  final String displayName;
  final IconData icon;
  const DocumentCategory(this.displayName, this.icon);
}

class Document extends HealthRecord {
  @override
  final int id;
  @override
  final int familyMemberId;
  final String title;
  final DocumentCategory category;

  /// Local file paths to each scanned/cropped page, in order. Empty for
  /// seed/mock documents that were never actually scanned on this device.
  final List<String> pagePaths;

  /// Raw on-device OCR text, recognised at scan time. Null for documents
  /// that were skipped past the OCR review step, or seeded mock data.
  final String? ocrText;

  final DateTime scannedDate;

  /// If the user chose "Save as <record>" after scanning, which module and
  /// record it created — lets the viewer link back to it.
  final String? linkedModuleKey;
  final int? linkedRecordId;

  final String? notes;

  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final SyncStatus syncStatus;
  @override
  final bool isDeleted;

  const Document({
    this.id = 0,
    required this.familyMemberId,
    required this.title,
    required this.category,
    this.pagePaths = const [],
    this.ocrText,
    required this.scannedDate,
    this.linkedModuleKey,
    this.linkedRecordId,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = SyncStatus.pending,
    this.isDeleted = false,
  });

  Document copyWith({
    String? title,
    DocumentCategory? category,
    List<String>? pagePaths,
    String? ocrText,
    String? linkedModuleKey,
    int? linkedRecordId,
    String? notes,
  }) {
    return Document(
      id: id,
      familyMemberId: familyMemberId,
      title: title ?? this.title,
      category: category ?? this.category,
      pagePaths: pagePaths ?? this.pagePaths,
      ocrText: ocrText ?? this.ocrText,
      scannedDate: scannedDate,
      linkedModuleKey: linkedModuleKey ?? this.linkedModuleKey,
      linkedRecordId: linkedRecordId ?? this.linkedRecordId,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      syncStatus: syncStatus,
      isDeleted: isDeleted,
    );
  }
}
