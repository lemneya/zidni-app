import 'package:url_launcher/url_launcher.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';

/// WhatsApp integration service for instant follow-up messages
///
/// GATE: COMM-1 - Direct WhatsApp Send
///
/// VALUE PROPOSITION:
/// - Reduces follow-up time from 30 seconds to 3 seconds (10x faster)
/// - Higher deal close rates (less friction = more follow-ups)
/// - Strong upgrade driver (saves 5-10 minutes per follow-up)
///
/// MONETIZATION:
/// - Free: Manual copy-paste (current behavior)
/// - Business: One-tap send + contact extraction from OCR
class WhatsAppService {
  /// Send message to WhatsApp (free tier - requires manual phone input)
  ///
  /// Opens WhatsApp with pre-filled message.
  /// User must have WhatsApp installed on device.
  ///
  /// Example:
  /// ```dart
  /// await WhatsAppService.sendMessage(
  ///   phoneNumber: '+86 138 0013 8000',
  ///   message: 'Dear Supplier, thank you for meeting at Canton Fair...',
  /// );
  /// ```
  static Future<bool> sendMessage({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      // Clean phone number (remove spaces, dashes, parentheses)
      final cleanNumber = _cleanPhoneNumber(phoneNumber);

      if (cleanNumber.isEmpty) {
        throw ArgumentError('Phone number cannot be empty');
      }

      // WhatsApp URL scheme
      // Format: https://wa.me/PHONE?text=MESSAGE
      final encodedMessage = Uri.encodeComponent(message);
      final url = 'https://wa.me/$cleanNumber?text=$encodedMessage';

      final uri = Uri.parse(url);

      // Check if WhatsApp can be opened
      if (!await canLaunchUrl(uri)) {
        throw Exception('WhatsApp is not installed on this device');
      }

      // Open WhatsApp
      await launchUrl(uri, mode: LaunchMode.externalApplication);

      // Track usage
      await UsageMeterService.increment(UsageType.whatsappSends);

      return true;
    } catch (e) {
      print('[WhatsApp] Error sending message: $e');
      return false;
    }
  }

  /// Send message with auto-extracted contact (Business tier only)
  ///
  /// Automatically extracts phone from business card OCR or supplier profile.
  /// Falls back to manual entry if extraction fails.
  ///
  /// Premium feature that saves 10-15 seconds per send.
  static Future<bool> sendMessageSmart({
    required String message,
    String? supplierName,
    String? scannedText,
    Map<String, dynamic>? contactInfo,
  }) async {
    // Check entitlement
    final entitlement = await EntitlementService.getEntitlement();
    if (!entitlement.canExportPDF) {
      // Free tier - return false to show upgrade prompt
      return false;
    }

    try {
      // Attempt to extract phone number from various sources
      String? phoneNumber;

      // Priority 1: Explicit contact info (from business card scan)
      if (contactInfo != null && contactInfo.containsKey('phone')) {
        phoneNumber = contactInfo['phone'] as String?;
      }

      // Priority 2: Extract from OCR text
      if (phoneNumber == null && scannedText != null) {
        phoneNumber = _extractPhoneFromText(scannedText);
      }

      // Priority 3: Look up supplier profile (if implemented)
      // TODO: Add supplier profile lookup when Gate DEAL-1 is implemented
      // if (phoneNumber == null && supplierName != null) {
      //   phoneNumber = await SupplierService.getPhone(supplierName);
      // }

      if (phoneNumber == null) {
        throw Exception('Could not auto-extract phone number');
      }

      // Send via WhatsApp
      return await sendMessage(
        phoneNumber: phoneNumber,
        message: message,
      );
    } catch (e) {
      print('[WhatsApp] Smart send failed: $e');
      return false;
    }
  }

  /// Check if WhatsApp is installed on device
  static Future<bool> isWhatsAppInstalled() async {
    try {
      final uri = Uri.parse('https://wa.me/');
      return await canLaunchUrl(uri);
    } catch (e) {
      return false;
    }
  }

  /// Open WhatsApp Business (if user has both apps)
  static Future<bool> sendViaWhatsAppBusiness({
    required String phoneNumber,
    required String message,
  }) async {
    try {
      final cleanNumber = _cleanPhoneNumber(phoneNumber);
      final encodedMessage = Uri.encodeComponent(message);

      // WhatsApp Business URL scheme
      final url = 'https://wa.me/$cleanNumber?text=$encodedMessage';
      final uri = Uri.parse(url);

      await launchUrl(uri, mode: LaunchMode.externalApplication);

      await UsageMeterService.increment(UsageType.whatsappSends);

      return true;
    } catch (e) {
      print('[WhatsApp] Error sending via Business: $e');
      return false;
    }
  }

  /// Generate follow-up template for WhatsApp
  ///
  /// Creates professional follow-up message in user's language.
  /// Supports Arabic, Chinese, English, Spanish, Turkish.
  static String generateFollowUpTemplate({
    required String supplierName,
    required String language,
    String? productCategory,
    String? boothNumber,
    String? specificRequest,
  }) {
    // Default templates by language
    final templates = {
      'ar': _generateArabicTemplate(
        supplierName: supplierName,
        productCategory: productCategory,
        boothNumber: boothNumber,
        specificRequest: specificRequest,
      ),
      'zh': _generateChineseTemplate(
        supplierName: supplierName,
        productCategory: productCategory,
        boothNumber: boothNumber,
        specificRequest: specificRequest,
      ),
      'en': _generateEnglishTemplate(
        supplierName: supplierName,
        productCategory: productCategory,
        boothNumber: boothNumber,
        specificRequest: specificRequest,
      ),
      'es': _generateSpanishTemplate(
        supplierName: supplierName,
        productCategory: productCategory,
        boothNumber: boothNumber,
        specificRequest: specificRequest,
      ),
      'tr': _generateTurkishTemplate(
        supplierName: supplierName,
        productCategory: productCategory,
        boothNumber: boothNumber,
        specificRequest: specificRequest,
      ),
    };

    return templates[language] ?? templates['en']!;
  }

  // ==================== PRIVATE HELPERS ====================

  /// Clean phone number for WhatsApp URL
  static String _cleanPhoneNumber(String phone) {
    // Remove all non-digit characters except leading +
    String cleaned = phone.replaceAll(RegExp(r'[^\d+]'), '');

    // Ensure it starts with + for international format
    if (!cleaned.startsWith('+')) {
      // If no country code, this is incomplete - return as-is
      // User should provide full international number
      return cleaned;
    }

    return cleaned;
  }

  /// Extract phone number from OCR text using regex
  static String? _extractPhoneFromText(String text) {
    // Common phone number patterns
    final patterns = [
      // International: +XX XXX XXX XXXX
      RegExp(r'\+\d{1,4}\s?\d{3,4}\s?\d{3,4}\s?\d{4}'),
      // With parentheses: +XX (XXX) XXX-XXXX
      RegExp(r'\+\d{1,4}\s?\(\d{3}\)\s?\d{3}[-\s]?\d{4}'),
      // Simple format: +XXXXXXXXXXXX
      RegExp(r'\+\d{10,15}'),
      // Chinese mobile: 138 0013 8000
      RegExp(r'1[3-9]\d\s?\d{4}\s?\d{4}'),
    ];

    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      if (match != null) {
        return match.group(0);
      }
    }

    return null;
  }

  // ==================== TEMPLATE GENERATORS ====================

  static String _generateArabicTemplate({
    required String supplierName,
    String? productCategory,
    String? boothNumber,
    String? specificRequest,
  }) {
    final booth = boothNumber != null ? ' في جناح $boothNumber' : '';
    final category = productCategory != null ? ' بخصوص $productCategory' : '';

    return '''السلام عليكم $supplierName،

شكراً جزيلاً على اللقاء الطيب$booth في معرض كانتون.

أود متابعة النقاط التي تحدثنا عنها$category.

${specificRequest ?? 'هل يمكنكم إرسال قائمة الأسعار الكاملة مع شروط الدفع والشحن؟'}

نتطلع للتعاون المثمر معكم.

مع أطيب التحيات''';
  }

  static String _generateChineseTemplate({
    required String supplierName,
    String? productCategory,
    String? boothNumber,
    String? specificRequest,
  }) {
    final booth = boothNumber != null ? '在$boothNumber展位' : '';
    final category = productCategory != null ? '关于$productCategory' : '';

    return '''您好 $supplierName，

非常感谢您$booth在广交会上的热情接待。

我想跟进我们讨论的几个要点$category。

${specificRequest ?? '您能否发送完整的价格表和付款条件？'}

期待与您的合作。

此致敬礼''';
  }

  static String _generateEnglishTemplate({
    required String supplierName,
    String? productCategory,
    String? boothNumber,
    String? specificRequest,
  }) {
    final booth = boothNumber != null ? ' at booth $boothNumber' : '';
    final category = productCategory != null ? ' regarding $productCategory' : '';

    return '''Dear $supplierName,

Thank you for the pleasant meeting$booth at Canton Fair.

I would like to follow up on the points we discussed$category.

${specificRequest ?? 'Could you please send the complete price list with payment and shipping terms?'}

Looking forward to working with you.

Best regards''';
  }

  static String _generateSpanishTemplate({
    required String supplierName,
    String? productCategory,
    String? boothNumber,
    String? specificRequest,
  }) {
    final booth = boothNumber != null ? ' en el stand $boothNumber' : '';
    final category = productCategory != null ? ' sobre $productCategory' : '';

    return '''Estimado/a $supplierName,

Gracias por la agradable reunión$booth en la Feria de Cantón.

Me gustaría hacer seguimiento a los puntos que discutimos$category.

${specificRequest ?? '¿Podría enviar la lista completa de precios con términos de pago y envío?'}

Esperando trabajar con usted.

Saludos cordiales''';
  }

  static String _generateTurkishTemplate({
    required String supplierName,
    String? productCategory,
    String? boothNumber,
    String? specificRequest,
  }) {
    final booth = boothNumber != null ? ' $boothNumber numaralı stantta' : '';
    final category = productCategory != null ? ' $productCategory hakkında' : '';

    return '''Sayın $supplierName,

Canton Fuarı'nda$booth gerçekleştirdiğimiz hoş görüşme için teşekkür ederim.

Konuştuğumuz konuları$category takip etmek istiyorum.

${specificRequest ?? 'Ödeme ve nakliye şartlarıyla birlikte eksiksiz fiyat listesini gönderebilir misiniz?'}

Sizinle çalışmayı dört gözle bekliyorum.

Saygılarımla''';
  }
}
