/// Service Catalog
/// GATE ARCH-1: Service Architecture Docs + Dependency Contract
///
/// This file is the single source of truth for all services in the Zidni app.
/// It documents each service, its purpose, and its allowed dependencies.
///
/// IMPORTANT: This file must be kept in sync with docs/SERVICES.md.
/// When adding a new service, update both this file and the documentation.

// ignore_for_file: unused_element

/// Enum of all services in the Zidni app.
/// Used for dependency tracking and validation.
enum ZidniService {
  // ============================================
  // CONTEXT MODULE (lib/context)
  // ============================================
  
  /// Manages the user's active ContextPack.
  /// Dependencies: None
  contextService,
  
  // ============================================
  // EYES MODULE (lib/eyes)
  // ============================================
  
  /// Handles OCR text recognition from camera images.
  /// Dependencies: google_mlkit_text_recognition (external)
  ocrService,
  
  /// Stores Eyes scan results locally.
  /// Dependencies: None
  eyesHistoryService,
  
  /// Stores search attempts locally.
  /// Dependencies: None
  searchHistoryService,
  
  /// Builds search queries from OCR results.
  /// Dependencies: None
  queryBuilderService,
  
  /// Creates and manages DealRecords.
  /// Dependencies: eyesHistoryService, searchHistoryService
  dealService,
  
  /// Generates follow-up message templates.
  /// Dependencies: None
  followupKitService,
  
  // ============================================
  // BILLING MODULE (lib/billing)
  // ============================================
  
  /// Manages the user's subscription tier.
  /// Dependencies: None
  entitlementService,
  
  /// Centralized feature gating logic.
  /// Dependencies: entitlementService, usageMeterService
  featureGate,
  
  /// Checks for upgrade triggers based on user behavior.
  /// Dependencies: usageMeterService
  upgradeTriggerService,
  
  // ============================================
  // USAGE MODULE (lib/usage)
  // ============================================
  
  /// Tracks daily/monthly usage of features.
  /// Dependencies: None
  usageMeterService,
  
  // ============================================
  // KITS MODULE (lib/kits)
  // ============================================
  
  /// Manages installed and active OfflineKits.
  /// Dependencies: contextService
  kitService,
  
  /// Checks for and downloads remote kit updates.
  /// Dependencies: kitService
  kitUpdateService,
  
  // ============================================
  // OS MODULE (lib/os)
  // ============================================
  
  /// Routes voice commands to appropriate actions.
  /// Dependencies: None
  voiceCommandRouter,
  
  /// Aggregates all history items into a unified feed.
  /// Dependencies: eyesHistoryService, searchHistoryService, dealService
  unifiedHistoryService,
}

/// Defines the allowed dependencies for each service.
/// This is the dependency contract that must be respected.
const Map<ZidniService, List<ZidniService>> _serviceDependencies = {
  // Context Module
  ZidniService.contextService: [],
  
  // Eyes Module
  ZidniService.ocrService: [],
  ZidniService.eyesHistoryService: [],
  ZidniService.searchHistoryService: [],
  ZidniService.queryBuilderService: [],
  ZidniService.dealService: [
    ZidniService.eyesHistoryService,
    ZidniService.searchHistoryService,
  ],
  ZidniService.followupKitService: [],
  
  // Billing Module
  ZidniService.entitlementService: [],
  ZidniService.featureGate: [
    ZidniService.entitlementService,
    ZidniService.usageMeterService,
  ],
  ZidniService.upgradeTriggerService: [
    ZidniService.usageMeterService,
  ],
  
  // Usage Module
  ZidniService.usageMeterService: [],
  
  // Kits Module
  ZidniService.kitService: [
    ZidniService.contextService,
  ],
  ZidniService.kitUpdateService: [
    ZidniService.kitService,
  ],
  
  // OS Module
  ZidniService.voiceCommandRouter: [],
  ZidniService.unifiedHistoryService: [
    ZidniService.eyesHistoryService,
    ZidniService.searchHistoryService,
    ZidniService.dealService,
  ],
};

/// Validates that a service only depends on its allowed dependencies.
/// This can be used in tests to enforce the dependency contract.
bool validateServiceDependency(ZidniService service, ZidniService dependency) {
  final allowedDeps = _serviceDependencies[service] ?? [];
  return allowedDeps.contains(dependency);
}

/// Returns the list of allowed dependencies for a service.
List<ZidniService> getAllowedDependencies(ZidniService service) {
  return _serviceDependencies[service] ?? [];
}

/// Returns all services that have no dependencies (leaf services).
List<ZidniService> getLeafServices() {
  return _serviceDependencies.entries
      .where((e) => e.value.isEmpty)
      .map((e) => e.key)
      .toList();
}

/// Returns all services that depend on a given service.
List<ZidniService> getDependents(ZidniService service) {
  return _serviceDependencies.entries
      .where((e) => e.value.contains(service))
      .map((e) => e.key)
      .toList();
}

/// Service metadata for documentation purposes.
class ServiceMeta {
  final ZidniService service;
  final String module;
  final String purpose;
  final String persistence;
  
  const ServiceMeta({
    required this.service,
    required this.module,
    required this.purpose,
    required this.persistence,
  });
}

/// Complete service metadata catalog.
/// This must match docs/SERVICES.md.
const List<ServiceMeta> serviceCatalog = [
  // Context Module
  ServiceMeta(
    service: ZidniService.contextService,
    module: 'lib/context',
    purpose: 'Manages the user\'s active ContextPack',
    persistence: 'SharedPreferences',
  ),
  
  // Eyes Module
  ServiceMeta(
    service: ZidniService.ocrService,
    module: 'lib/eyes',
    purpose: 'Handles OCR text recognition from camera images',
    persistence: 'None',
  ),
  ServiceMeta(
    service: ZidniService.eyesHistoryService,
    module: 'lib/eyes',
    purpose: 'Stores Eyes scan results locally',
    persistence: 'SharedPreferences',
  ),
  ServiceMeta(
    service: ZidniService.dealService,
    module: 'lib/eyes',
    purpose: 'Creates and manages DealRecords',
    persistence: 'SharedPreferences',
  ),
  
  // Billing Module
  ServiceMeta(
    service: ZidniService.entitlementService,
    module: 'lib/billing',
    purpose: 'Manages the user\'s subscription tier',
    persistence: 'SharedPreferences',
  ),
  ServiceMeta(
    service: ZidniService.featureGate,
    module: 'lib/billing',
    purpose: 'Centralized feature gating logic',
    persistence: 'None',
  ),
  
  // Usage Module
  ServiceMeta(
    service: ZidniService.usageMeterService,
    module: 'lib/usage',
    purpose: 'Tracks daily/monthly usage of features',
    persistence: 'SharedPreferences',
  ),
  
  // Kits Module
  ServiceMeta(
    service: ZidniService.kitService,
    module: 'lib/kits',
    purpose: 'Manages installed and active OfflineKits',
    persistence: 'SharedPreferences',
  ),
  ServiceMeta(
    service: ZidniService.kitUpdateService,
    module: 'lib/kits',
    purpose: 'Checks for and downloads remote kit updates',
    persistence: 'SharedPreferences',
  ),
  
  // OS Module
  ServiceMeta(
    service: ZidniService.voiceCommandRouter,
    module: 'lib/os',
    purpose: 'Routes voice commands to appropriate actions',
    persistence: 'None',
  ),
  ServiceMeta(
    service: ZidniService.unifiedHistoryService,
    module: 'lib/os',
    purpose: 'Aggregates all history items into a unified feed',
    persistence: 'SharedPreferences',
  ),
];
