import 'dart:convert';
import 'package:flutter/services.dart';

/// Service for managing immigration-related phrase templates.
/// 
/// Provides pre-built templates for common immigration scenarios:
/// - Speaking with immigration officers
/// - Communicating with lawyers
/// - DMV visits
/// - Social Security Administration visits
/// - USCIS appointments
class TemplatesService {
  TemplatesService._();
  static final TemplatesService instance = TemplatesService._();

  List<TemplateCategory>? _categories;

  /// Load templates from assets
  Future<void> init() async {
    if (_categories != null) return;
    
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/immigration_templates.json',
      );
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;
      final categoriesJson = jsonData['categories'] as List<dynamic>;
      
      _categories = categoriesJson
          .map((c) => TemplateCategory.fromJson(c as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Use default templates if asset loading fails
      _categories = _getDefaultTemplates();
    }
  }

  /// Get all template categories
  List<TemplateCategory> get categories => _categories ?? _getDefaultTemplates();

  /// Get templates by category ID
  List<PhraseTemplate> getTemplatesByCategory(String categoryId) {
    final category = categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => TemplateCategory(id: '', nameEn: '', nameAr: '', templates: []),
    );
    return category.templates;
  }

  /// Search templates by keyword
  List<PhraseTemplate> searchTemplates(String query) {
    final lowerQuery = query.toLowerCase();
    final results = <PhraseTemplate>[];
    
    for (final category in categories) {
      for (final template in category.templates) {
        if (template.phraseEn.toLowerCase().contains(lowerQuery) ||
            template.phraseAr.contains(query)) {
          results.add(template);
        }
      }
    }
    
    return results;
  }

  /// Get default templates (fallback)
  List<TemplateCategory> _getDefaultTemplates() {
    return [
      TemplateCategory(
        id: 'immigration_officer',
        nameEn: 'Immigration Officer',
        nameAr: 'ضابط الهجرة',
        icon: 'badge',
        templates: [
          PhraseTemplate(
            id: 'io_1',
            phraseEn: 'I am here for tourism/business.',
            phraseAr: 'أنا هنا للسياحة/الأعمال.',
          ),
          PhraseTemplate(
            id: 'io_2',
            phraseEn: 'I am staying for [X] days.',
            phraseAr: 'سأبقى لمدة [X] أيام.',
          ),
          PhraseTemplate(
            id: 'io_3',
            phraseEn: 'Here is my return ticket.',
            phraseAr: 'هذه تذكرة العودة الخاصة بي.',
          ),
          PhraseTemplate(
            id: 'io_4',
            phraseEn: 'I am staying at [hotel name].',
            phraseAr: 'سأقيم في [اسم الفندق].',
          ),
          PhraseTemplate(
            id: 'io_5',
            phraseEn: 'I have [amount] dollars for my trip.',
            phraseAr: 'لدي [المبلغ] دولار لرحلتي.',
          ),
        ],
      ),
      TemplateCategory(
        id: 'lawyer',
        nameEn: 'Immigration Lawyer',
        nameAr: 'محامي الهجرة',
        icon: 'gavel',
        templates: [
          PhraseTemplate(
            id: 'law_1',
            phraseEn: 'I need help with my visa application.',
            phraseAr: 'أحتاج مساعدة في طلب التأشيرة.',
          ),
          PhraseTemplate(
            id: 'law_2',
            phraseEn: 'What are my options for staying legally?',
            phraseAr: 'ما هي خياراتي للبقاء بشكل قانوني؟',
          ),
          PhraseTemplate(
            id: 'law_3',
            phraseEn: 'How long will the process take?',
            phraseAr: 'كم من الوقت ستستغرق العملية؟',
          ),
          PhraseTemplate(
            id: 'law_4',
            phraseEn: 'What documents do I need?',
            phraseAr: 'ما هي المستندات التي أحتاجها؟',
          ),
          PhraseTemplate(
            id: 'law_5',
            phraseEn: 'Can I work while my application is pending?',
            phraseAr: 'هل يمكنني العمل أثناء انتظار طلبي؟',
          ),
        ],
      ),
      TemplateCategory(
        id: 'dmv',
        nameEn: 'DMV',
        nameAr: 'إدارة المركبات',
        icon: 'directions_car',
        templates: [
          PhraseTemplate(
            id: 'dmv_1',
            phraseEn: 'I want to apply for a driver\'s license.',
            phraseAr: 'أريد التقدم للحصول على رخصة قيادة.',
          ),
          PhraseTemplate(
            id: 'dmv_2',
            phraseEn: 'I need to renew my license.',
            phraseAr: 'أحتاج إلى تجديد رخصتي.',
          ),
          PhraseTemplate(
            id: 'dmv_3',
            phraseEn: 'I have my I-94 and passport.',
            phraseAr: 'لدي I-94 وجواز السفر.',
          ),
          PhraseTemplate(
            id: 'dmv_4',
            phraseEn: 'When is my appointment?',
            phraseAr: 'متى موعدي؟',
          ),
        ],
      ),
      TemplateCategory(
        id: 'ssa',
        nameEn: 'Social Security',
        nameAr: 'الضمان الاجتماعي',
        icon: 'security',
        templates: [
          PhraseTemplate(
            id: 'ssa_1',
            phraseEn: 'I want to apply for a Social Security number.',
            phraseAr: 'أريد التقدم للحصول على رقم الضمان الاجتماعي.',
          ),
          PhraseTemplate(
            id: 'ssa_2',
            phraseEn: 'I need a replacement card.',
            phraseAr: 'أحتاج إلى بطاقة بديلة.',
          ),
          PhraseTemplate(
            id: 'ssa_3',
            phraseEn: 'I need to update my name.',
            phraseAr: 'أحتاج إلى تحديث اسمي.',
          ),
        ],
      ),
      TemplateCategory(
        id: 'uscis',
        nameEn: 'USCIS Appointment',
        nameAr: 'موعد USCIS',
        icon: 'account_balance',
        templates: [
          PhraseTemplate(
            id: 'uscis_1',
            phraseEn: 'I have an appointment for biometrics.',
            phraseAr: 'لدي موعد للبصمات.',
          ),
          PhraseTemplate(
            id: 'uscis_2',
            phraseEn: 'I am here for my interview.',
            phraseAr: 'أنا هنا للمقابلة.',
          ),
          PhraseTemplate(
            id: 'uscis_3',
            phraseEn: 'My receipt number is [number].',
            phraseAr: 'رقم الإيصال الخاص بي هو [الرقم].',
          ),
        ],
      ),
    ];
  }
}

/// A category of phrase templates
class TemplateCategory {
  final String id;
  final String nameEn;
  final String nameAr;
  final String? icon;
  final List<PhraseTemplate> templates;

  const TemplateCategory({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    this.icon,
    required this.templates,
  });

  String getLocalizedName(String locale) {
    return locale.startsWith('ar') ? nameAr : nameEn;
  }

  factory TemplateCategory.fromJson(Map<String, dynamic> json) {
    return TemplateCategory(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String,
      icon: json['icon'] as String?,
      templates: (json['templates'] as List<dynamic>)
          .map((t) => PhraseTemplate.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// A single phrase template
class PhraseTemplate {
  final String id;
  final String phraseEn;
  final String phraseAr;
  final String? context;

  const PhraseTemplate({
    required this.id,
    required this.phraseEn,
    required this.phraseAr,
    this.context,
  });

  String getLocalizedPhrase(String locale) {
    return locale.startsWith('ar') ? phraseAr : phraseEn;
  }

  factory PhraseTemplate.fromJson(Map<String, dynamic> json) {
    return PhraseTemplate(
      id: json['id'] as String,
      phraseEn: json['phraseEn'] as String,
      phraseAr: json['phraseAr'] as String,
      context: json['context'] as String?,
    );
  }
}
