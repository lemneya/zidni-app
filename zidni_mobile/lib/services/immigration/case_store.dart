import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../../models/immigration/uscis_case.dart';

/// Local storage service for USCIS case tracking.
/// 
/// Stores case information locally and provides case status checking.
class CaseStore {
  CaseStore._();
  static final CaseStore instance = CaseStore._();

  static const _uuid = Uuid();
  static const _storageKey = 'uscis_cases';

  SharedPreferences? _prefs;
  List<USCISCase> _cases = [];

  /// Initialize the store
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    await _loadCases();
  }

  /// Get all tracked cases
  List<USCISCase> get cases => List.unmodifiable(_cases);

  /// Get case by ID
  USCISCase? getCaseById(String id) {
    try {
      return _cases.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get case by receipt number
  USCISCase? getCaseByReceiptNumber(String receiptNumber) {
    final normalized = receiptNumber.toUpperCase().replaceAll(' ', '');
    try {
      return _cases.firstWhere(
        (c) => c.receiptNumber.toUpperCase() == normalized,
      );
    } catch (e) {
      return null;
    }
  }

  /// Add a new case to track
  Future<USCISCase> addCase({
    required String receiptNumber,
    required USCISFormType formType,
    String? label,
    DateTime? filedDate,
    String? notes,
  }) async {
    // Validate receipt number
    if (!USCISCase.isValidReceiptNumber(receiptNumber)) {
      throw ArgumentError('Invalid receipt number format');
    }

    // Check for duplicates
    if (getCaseByReceiptNumber(receiptNumber) != null) {
      throw StateError('Case with this receipt number already exists');
    }

    final newCase = USCISCase(
      id: _uuid.v4(),
      receiptNumber: receiptNumber.toUpperCase().replaceAll(' ', ''),
      formType: formType,
      status: CaseStatus.received,
      label: label,
      filedDate: filedDate,
      notes: notes,
      addedAt: DateTime.now(),
    );

    _cases.add(newCase);
    await _saveCases();

    debugPrint('CaseStore: Added case ${newCase.receiptNumber}');
    return newCase;
  }

  /// Update a case
  Future<void> updateCase(USCISCase updatedCase) async {
    final index = _cases.indexWhere((c) => c.id == updatedCase.id);
    if (index == -1) {
      throw StateError('Case not found');
    }

    _cases[index] = updatedCase;
    await _saveCases();

    debugPrint('CaseStore: Updated case ${updatedCase.receiptNumber}');
  }

  /// Remove a case
  Future<void> removeCase(String id) async {
    _cases.removeWhere((c) => c.id == id);
    await _saveCases();

    debugPrint('CaseStore: Removed case $id');
  }

  /// Check case status (mock implementation)
  /// 
  /// In production, this would call the USCIS API or scrape the website
  Future<CaseStatusResult> checkCaseStatus(String receiptNumber) async {
    // Simulate API call
    await Future.delayed(const Duration(seconds: 2));

    // Mock response
    return CaseStatusResult(
      success: true,
      status: CaseStatus.processing,
      lastUpdated: DateTime.now(),
      description: 'Your case is currently being processed.',
      descriptionArabic: 'طلبك قيد المعالجة حالياً.',
    );
  }

  /// Refresh status for all tracked cases
  Future<void> refreshAllCases() async {
    for (var i = 0; i < _cases.length; i++) {
      final result = await checkCaseStatus(_cases[i].receiptNumber);
      if (result.success) {
        final updatedCase = _cases[i].copyWith(
          status: result.status,
          lastUpdated: result.lastUpdated,
          statusHistory: [
            ..._cases[i].statusHistory,
            CaseStatusUpdate(
              status: result.status!,
              date: result.lastUpdated!,
              description: result.description,
            ),
          ],
        );
        _cases[i] = updatedCase;
      }
    }
    await _saveCases();
  }

  /// Load cases from storage
  Future<void> _loadCases() async {
    final jsonString = _prefs?.getString(_storageKey);
    if (jsonString == null) {
      _cases = [];
      return;
    }

    try {
      final jsonList = json.decode(jsonString) as List<dynamic>;
      _cases = jsonList
          .map((j) => USCISCase.fromJson(j as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('CaseStore: Error loading cases: $e');
      _cases = [];
    }
  }

  /// Save cases to storage
  Future<void> _saveCases() async {
    final jsonList = _cases.map((c) => c.toJson()).toList();
    await _prefs?.setString(_storageKey, json.encode(jsonList));
  }

  /// Clear all cases
  Future<void> clear() async {
    _cases = [];
    await _prefs?.remove(_storageKey);
  }
}

/// Result of a case status check
class CaseStatusResult {
  final bool success;
  final CaseStatus? status;
  final DateTime? lastUpdated;
  final String? description;
  final String? descriptionArabic;
  final String? errorMessage;

  const CaseStatusResult({
    required this.success,
    this.status,
    this.lastUpdated,
    this.description,
    this.descriptionArabic,
    this.errorMessage,
  });

  String? getLocalizedDescription(String locale) {
    if (locale.startsWith('ar') && descriptionArabic != null) {
      return descriptionArabic;
    }
    return description;
  }
}
