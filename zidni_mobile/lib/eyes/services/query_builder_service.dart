import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/models/search_query.dart';

/// Service to build search queries from OCR results
/// Gate EYES-2: Find Where To Buy - Query Builder
class QueryBuilderService {
  /// Build a clean search query from an EyesScanResult
  /// Priority: brand + model > productNameGuess > SKU > keywords from raw text
  static SearchQuery buildFromScanResult(EyesScanResult result) {
    final brand = result.extractedFields['brand'];
    final model = result.extractedFields['model'];
    final sku = result.extractedFields['sku'];
    // Note: size and material are available in extractedFields but not used in query building
    
    // Extract keywords from raw text
    final keywords = _extractKeywords(result.rawText);
    
    // Build base query with priority
    String baseQuery;
    
    if (brand != null && model != null) {
      // Best case: brand + model
      baseQuery = '$brand $model';
    } else if (result.productNameGuess != null && result.productNameGuess!.isNotEmpty) {
      // Use product name guess
      baseQuery = result.productNameGuess!;
    } else if (brand != null) {
      // Just brand
      baseQuery = brand;
    } else if (model != null) {
      // Just model
      baseQuery = model;
    } else if (sku != null) {
      // Use SKU/barcode
      baseQuery = sku;
    } else if (keywords.isNotEmpty) {
      // Use extracted keywords
      baseQuery = keywords.take(3).join(' ');
    } else {
      // Fallback to first line of raw text
      baseQuery = _getFirstMeaningfulLine(result.rawText);
    }
    
    // Clean up the query
    baseQuery = _cleanQuery(baseQuery);
    
    return SearchQuery(
      baseQuery: baseQuery,
      brand: brand,
      model: model,
      sku: sku,
      keywords: keywords,
      contextChips: [],
      platform: 'pending',
      createdAt: DateTime.now(),
      scanResultId: result.id,
    );
  }
  
  /// Extract meaningful keywords from raw OCR text
  static List<String> _extractKeywords(String text) {
    if (text.isEmpty) return [];
    
    final keywords = <String>[];
    
    // Split by lines and common delimiters
    final lines = text.split(RegExp(r'[\n\r,;:]'));
    
    for (final line in lines) {
      final trimmed = line.trim();
      
      // Skip empty or very short lines
      if (trimmed.length < 3) continue;
      
      // Skip lines that are just numbers (likely barcodes handled separately)
      if (RegExp(r'^\d+$').hasMatch(trimmed)) continue;
      
      // Skip very long lines (likely paragraphs)
      if (trimmed.length > 50) continue;
      
      // Add as keyword
      keywords.add(trimmed);
      
      // Limit to 10 keywords
      if (keywords.length >= 10) break;
    }
    
    return keywords;
  }
  
  /// Get the first meaningful line from text
  static String _getFirstMeaningfulLine(String text) {
    if (text.isEmpty) return '';
    
    final lines = text.split('\n');
    for (final line in lines) {
      final trimmed = line.trim();
      if (trimmed.length >= 3 && !RegExp(r'^\d+$').hasMatch(trimmed)) {
        return trimmed.length > 100 ? trimmed.substring(0, 100) : trimmed;
      }
    }
    
    return text.length > 100 ? text.substring(0, 100) : text;
  }
  
  /// Clean up a query string
  static String _cleanQuery(String query) {
    // Remove excessive whitespace
    var cleaned = query.replaceAll(RegExp(r'\s+'), ' ').trim();
    
    // Remove special characters that might break URLs
    cleaned = cleaned.replaceAll(RegExp(r'[<>\[\]{}|^`]'), '');
    cleaned = cleaned.replaceAll('"', '');
    cleaned = cleaned.replaceAll("'", '');
    
    // Limit length
    if (cleaned.length > 100) {
      cleaned = cleaned.substring(0, 100);
    }
    
    return cleaned;
  }
  
  /// Add context chips to a query
  static SearchQuery addContextChips(SearchQuery query, List<String> chipIds) {
    final modifiers = <String>[];
    
    for (final chipId in chipIds) {
      final chip = ContextChips.all.where((c) => c.id == chipId).firstOrNull;
      if (chip != null) {
        modifiers.add(chip.queryModifier);
      }
    }
    
    return query.copyWith(contextChips: modifiers);
  }
  
  /// Update the base query (for user edits)
  static SearchQuery updateBaseQuery(SearchQuery query, String newBaseQuery) {
    return query.copyWith(baseQuery: _cleanQuery(newBaseQuery));
  }
  
  /// Set the platform for a query
  static SearchQuery setPlatform(SearchQuery query, String platform) {
    return query.copyWith(platform: platform);
  }
}
