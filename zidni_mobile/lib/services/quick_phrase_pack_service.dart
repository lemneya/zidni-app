/// Quick Phrase Pack Service - Selects the appropriate 5-phrase pack
/// based on host country (when location is enabled) or falls back to default.

import '../packs/quick_phrase_library.dart';

/// Pack types based on context
enum PackType {
  china,    // Trade-focused for Canton Fair
  turkey,   // Daily life + safety
  spanish,  // Daily life + proof
  defaultPack, // Universal protection
}

class QuickPhrasePackService {
  /// Get pack type based on country code
  /// Returns defaultPack if country is null or not recognized
  static PackType getPackType(String? countryCode) {
    if (countryCode == null) return PackType.defaultPack;
    
    final code = countryCode.toUpperCase();
    
    // China Pack: CN, HK, TW
    if (code == 'CN' || code == 'HK' || code == 'TW') {
      return PackType.china;
    }
    
    // Turkey Pack: TR
    if (code == 'TR') {
      return PackType.turkey;
    }
    
    // Spanish Pack: Spain + Latin America
    const spanishCountries = {
      'ES', // Spain
      'MX', // Mexico
      'AR', // Argentina
      'CO', // Colombia
      'CL', // Chile
      'PE', // Peru
      'VE', // Venezuela
      'EC', // Ecuador
      'DO', // Dominican Republic
      'PR', // Puerto Rico
      'GT', // Guatemala
      'CU', // Cuba
      'BO', // Bolivia
      'HN', // Honduras
      'PY', // Paraguay
      'SV', // El Salvador
      'NI', // Nicaragua
      'CR', // Costa Rica
      'PA', // Panama
      'UY', // Uruguay
    };
    if (spanishCountries.contains(code)) {
      return PackType.spanish;
    }
    
    return PackType.defaultPack;
  }

  /// Get the 5 phrase keys for a pack type
  static List<PhraseKey> getPackPhraseKeys(PackType packType) {
    switch (packType) {
      case PackType.china:
        // Trade-first: PRICE, LOWER_PRICE, MOQ, DELIVERY_TIME, SEND_DETAILS(WeChat)
        return [
          PhraseKey.price,
          PhraseKey.lowerPrice,
          PhraseKey.moq,
          PhraseKey.deliveryTime,
          PhraseKey.sendDetails,
        ];
      
      case PackType.turkey:
        // Daily life + safety: GO_TO_ADDRESS, STOP_HERE, PRICE, RECEIPT_INVOICE, NEED_HELP
        return [
          PhraseKey.goToAddress,
          PhraseKey.stopHere,
          PhraseKey.price,
          PhraseKey.receiptInvoice,
          PhraseKey.needHelp,
        ];
      
      case PackType.spanish:
        // Daily life + proof: GO_TO_ADDRESS, PRICE, RECEIPT_INVOICE, SEND_DETAILS(WhatsApp), NEED_HELP
        return [
          PhraseKey.goToAddress,
          PhraseKey.price,
          PhraseKey.receiptInvoice,
          PhraseKey.sendDetails,
          PhraseKey.needHelp,
        ];
      
      case PackType.defaultPack:
        // Universal protection: PRICE, LOWER_PRICE, RECEIPT_INVOICE, DELIVERY_TIME, SEND_DETAILS(WhatsApp)
        return [
          PhraseKey.price,
          PhraseKey.lowerPrice,
          PhraseKey.receiptInvoice,
          PhraseKey.deliveryTime,
          PhraseKey.sendDetails,
        ];
    }
  }

  /// Get the 5 phrases for a given country code
  /// If countryCode is null, returns default pack
  static List<QuickPhrase> getPhrasesForCountry(String? countryCode) {
    final packType = getPackType(countryCode);
    final keys = getPackPhraseKeys(packType);
    return QuickPhraseLibrary.getPhrases(keys);
  }

  /// Get pack name in Arabic for display
  static String getPackNameArabic(PackType packType) {
    switch (packType) {
      case PackType.china:
        return 'حزمة الصين';
      case PackType.turkey:
        return 'حزمة تركيا';
      case PackType.spanish:
        return 'حزمة إسبانيا';
      case PackType.defaultPack:
        return 'حزمة عامة';
    }
  }
}
