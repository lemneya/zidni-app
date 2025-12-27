/// Quick Phrase Library - Local phrase translations for all target languages.
/// No API calls - all translations are bundled locally.

import '../screens/conversation/conversation_mode_screen.dart' show TargetLang;

/// Phrase keys for the library
enum PhraseKey {
  price,
  lowerPrice,
  moq,
  deliveryTime,
  sendDetails,
  receiptInvoice,
  goToAddress,
  stopHere,
  needHelp,
}

/// A single phrase with Arabic label and target translations
class QuickPhrase {
  final PhraseKey key;
  final String arabicLabel;
  final Map<TargetLang, String> translations;

  const QuickPhrase({
    required this.key,
    required this.arabicLabel,
    required this.translations,
  });

  /// Get translation for a specific target language
  String getTranslation(TargetLang target) {
    return translations[target] ?? translations[TargetLang.en] ?? '';
  }
}

/// The complete phrase library with all translations
class QuickPhraseLibrary {
  static const Map<PhraseKey, QuickPhrase> phrases = {
    PhraseKey.price: QuickPhrase(
      key: PhraseKey.price,
      arabicLabel: 'كم السعر؟',
      translations: {
        TargetLang.zh: '多少钱？',
        TargetLang.en: 'How much is it?',
        TargetLang.tr: 'Fiyatı ne kadar?',
        TargetLang.es: '¿Cuánto cuesta?',
      },
    ),
    PhraseKey.lowerPrice: QuickPhrase(
      key: PhraseKey.lowerPrice,
      arabicLabel: 'هل يمكن تخفيض السعر؟',
      translations: {
        TargetLang.zh: '可以便宜一点吗？',
        TargetLang.en: 'Can you lower the price?',
        TargetLang.tr: 'Fiyatı biraz düşürebilir misiniz?',
        TargetLang.es: '¿Puedes bajar el precio?',
      },
    ),
    PhraseKey.moq: QuickPhrase(
      key: PhraseKey.moq,
      arabicLabel: 'ما هو الحد الأدنى للطلب (MOQ)؟',
      translations: {
        TargetLang.zh: '最低订购量是多少？',
        TargetLang.en: 'What is the minimum order quantity (MOQ)?',
        TargetLang.tr: 'Asgari sipariş miktarı ne kadar?',
        TargetLang.es: '¿Cuál es la cantidad mínima de pedido (MOQ)?',
      },
    ),
    PhraseKey.deliveryTime: QuickPhrase(
      key: PhraseKey.deliveryTime,
      arabicLabel: 'كم مدة التسليم؟',
      translations: {
        TargetLang.zh: '交货需要多长时间？',
        TargetLang.en: 'How long is the delivery time?',
        TargetLang.tr: 'Teslimat ne kadar sürer?',
        TargetLang.es: '¿Cuánto tarda la entrega?',
      },
    ),
    PhraseKey.sendDetails: QuickPhrase(
      key: PhraseKey.sendDetails,
      arabicLabel: 'أرسل التفاصيل من فضلك',
      translations: {
        // WeChat variant for Chinese
        TargetLang.zh: '请把详细信息发到微信上。谢谢。',
        // WhatsApp variant for others
        TargetLang.en: 'Please send the details on WhatsApp. Thank you.',
        TargetLang.tr: 'Lütfen detayları WhatsApp\'tan gönderin. Teşekkürler.',
        TargetLang.es: 'Por favor, envía los detalles por WhatsApp. Gracias.',
      },
    ),
    PhraseKey.receiptInvoice: QuickPhrase(
      key: PhraseKey.receiptInvoice,
      arabicLabel: 'أريد فاتورة/إيصال',
      translations: {
        TargetLang.zh: '请给我发票/收据，谢谢。',
        TargetLang.en: 'I need an invoice/receipt, please.',
        TargetLang.tr: 'Lütfen fatura/fiş istiyorum.',
        TargetLang.es: 'Necesito una factura/recibo, por favor.',
      },
    ),
    PhraseKey.goToAddress: QuickPhrase(
      key: PhraseKey.goToAddress,
      arabicLabel: 'أريد الذهاب إلى هذا العنوان',
      translations: {
        TargetLang.zh: '我要去这个地址。',
        TargetLang.en: 'I want to go to this address.',
        TargetLang.tr: 'Bu adrese gitmek istiyorum.',
        TargetLang.es: 'Quiero ir a esta dirección.',
      },
    ),
    PhraseKey.stopHere: QuickPhrase(
      key: PhraseKey.stopHere,
      arabicLabel: 'توقف هنا من فضلك',
      translations: {
        TargetLang.zh: '请在这里停。',
        TargetLang.en: 'Please stop here.',
        TargetLang.tr: 'Lütfen burada durun.',
        TargetLang.es: 'Pare aquí, por favor.',
      },
    ),
    PhraseKey.needHelp: QuickPhrase(
      key: PhraseKey.needHelp,
      arabicLabel: 'أحتاج مساعدة',
      translations: {
        TargetLang.zh: '我需要帮助。',
        TargetLang.en: 'I need help, please.',
        TargetLang.tr: 'Yardıma ihtiyacım var, lütfen.',
        TargetLang.es: 'Necesito ayuda, por favor.',
      },
    ),
  };

  /// Get a phrase by key
  static QuickPhrase? getPhrase(PhraseKey key) => phrases[key];

  /// Get multiple phrases by keys
  static List<QuickPhrase> getPhrases(List<PhraseKey> keys) {
    return keys
        .map((key) => phrases[key])
        .where((phrase) => phrase != null)
        .cast<QuickPhrase>()
        .toList();
  }
}
