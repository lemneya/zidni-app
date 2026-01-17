import 'package:zidni_mobile/eyes/models/deal_record.dart';

/// Service to generate Follow-up Kit templates for deals
/// Gate EYES-3: Create Deal + Follow-up Kit from Eyes
class FollowupKitService {
  /// Generate follow-up templates for a deal
  /// [forceSupplierLanguage] - Optional override for supplier language ('en' or 'zh')
  static FollowupKit generateKit(
    DealRecord deal, {
    String? forceSupplierLanguage,
  }) {
    final productName = deal.productName ?? deal.searchQuery;
    final brand = deal.extractedFields['brand'];
    final model = deal.extractedFields['model'];
    final sku = deal.extractedFields['sku'];

    // Build product description
    String productDesc = productName;
    if (brand != null && model != null) {
      productDesc = '$brand $model';
    }

    // Determine supplier language: use forced value or auto-detect
    final String supplierLang;
    if (forceSupplierLanguage != null) {
      supplierLang = forceSupplierLanguage;
    } else {
      supplierLang = _shouldUseChineseTemplate(deal) ? 'zh' : 'en';
    }

    return FollowupKit(
      dealId: deal.id,
      arabicTemplate: _generateArabicTemplate(productDesc, brand, model, sku),
      supplierTemplate: supplierLang == 'zh'
          ? _generateChineseTemplate(productDesc, brand, model, sku)
          : _generateEnglishTemplate(productDesc, brand, model, sku),
      supplierLanguage: supplierLang,
    );
  }

  /// Determine if we should use Chinese template based on deal context
  static bool _shouldUseChineseTemplate(DealRecord deal) {
    // Check if platform is 1688 (Chinese platform)
    if (deal.selectedPlatform == '1688' || 
        deal.selectedPlatform == 'alibaba1688') {
      return true;
    }

    // Check if context chips include Chinese locations
    final chineseChips = ['广州', '佛山', '义乌', '工厂', '批发', '价格'];
    for (final chip in deal.contextChips) {
      if (chineseChips.contains(chip)) {
        return true;
      }
    }

    // Check if OCR text contains significant Chinese
    final chineseCharCount = RegExp(r'[\u4e00-\u9fff]')
        .allMatches(deal.ocrRawText)
        .length;
    if (chineseCharCount > 10) {
      return true;
    }

    return false;
  }

  /// Generate Arabic template (for trader/user)
  static String _generateArabicTemplate(
    String productName,
    String? brand,
    String? model,
    String? sku,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('📋 ملخص الصفقة');
    buffer.writeln('');
    buffer.writeln('المنتج: $productName');
    
    if (brand != null) {
      buffer.writeln('العلامة التجارية: $brand');
    }
    if (model != null) {
      buffer.writeln('الموديل: $model');
    }
    if (sku != null) {
      buffer.writeln('رقم المنتج: $sku');
    }

    buffer.writeln('');
    buffer.writeln('📝 ملاحظات:');
    buffer.writeln('• تم مسح المنتج بواسطة Zidni Eyes');
    buffer.writeln('• يرجى التحقق من السعر والحد الأدنى للطلب');
    buffer.writeln('• تأكد من جودة المنتج قبل الشراء');

    return buffer.toString();
  }

  /// Generate English template (for supplier)
  static String _generateEnglishTemplate(
    String productName,
    String? brand,
    String? model,
    String? sku,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Hello,');
    buffer.writeln('');
    buffer.writeln('I am interested in the following product:');
    buffer.writeln('');
    buffer.writeln('Product: $productName');
    
    if (brand != null) {
      buffer.writeln('Brand: $brand');
    }
    if (model != null) {
      buffer.writeln('Model: $model');
    }
    if (sku != null) {
      buffer.writeln('SKU/Code: $sku');
    }

    buffer.writeln('');
    buffer.writeln('Please provide:');
    buffer.writeln('1. Unit price and MOQ');
    buffer.writeln('2. Available colors/sizes');
    buffer.writeln('3. Shipping options to Middle East');
    buffer.writeln('4. Payment terms');
    buffer.writeln('');
    buffer.writeln('Looking forward to your reply.');
    buffer.writeln('');
    buffer.writeln('Best regards');

    return buffer.toString();
  }

  /// Generate Chinese template (for supplier on 1688/Chinese platforms)
  static String _generateChineseTemplate(
    String productName,
    String? brand,
    String? model,
    String? sku,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('您好，');
    buffer.writeln('');
    buffer.writeln('我对以下产品感兴趣：');
    buffer.writeln('');
    buffer.writeln('产品：$productName');
    
    if (brand != null) {
      buffer.writeln('品牌：$brand');
    }
    if (model != null) {
      buffer.writeln('型号：$model');
    }
    if (sku != null) {
      buffer.writeln('货号：$sku');
    }

    buffer.writeln('');
    buffer.writeln('请提供以下信息：');
    buffer.writeln('1. 单价和起订量');
    buffer.writeln('2. 可选颜色/尺寸');
    buffer.writeln('3. 发货到中东的物流方式');
    buffer.writeln('4. 付款方式');
    buffer.writeln('');
    buffer.writeln('期待您的回复。');
    buffer.writeln('');
    buffer.writeln('谢谢');

    return buffer.toString();
  }
}

/// Follow-up Kit containing templates for both parties
class FollowupKit {
  final String dealId;
  final String arabicTemplate;
  final String supplierTemplate;
  final String supplierLanguage; // 'en' or 'zh'

  FollowupKit({
    required this.dealId,
    required this.arabicTemplate,
    required this.supplierTemplate,
    required this.supplierLanguage,
  });

  /// Get supplier language display name
  String get supplierLanguageName {
    return supplierLanguage == 'zh' ? '中文' : 'English';
  }

  /// Get supplier language Arabic name
  String get supplierLanguageArabicName {
    return supplierLanguage == 'zh' ? 'الصينية' : 'الإنجليزية';
  }
}
