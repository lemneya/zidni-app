import 'dart:convert';
import 'package:flutter/services.dart';

/// Immigration-focused Alwakil (Agent) service.
/// 
/// Provides AI-powered assistance for immigration questions:
/// - Visa requirements and processes
/// - Green card timeline
/// - Citizenship eligibility
/// - Common immigration scenarios
/// 
/// Uses a knowledge pack loaded from assets for offline support.
class ImmigrationAlwakil {
  ImmigrationAlwakil._();
  static final ImmigrationAlwakil instance = ImmigrationAlwakil._();

  Map<String, dynamic>? _knowledgePack;

  /// Initialize the Alwakil with knowledge pack
  Future<void> init() async {
    if (_knowledgePack != null) return;

    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/immigration_alwakil_pack.json',
      );
      _knowledgePack = json.decode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      // Use default knowledge if asset loading fails
      _knowledgePack = _getDefaultKnowledge();
    }
  }

  /// Get answer for a question
  Future<AlwakilResponse> askQuestion(String question) async {
    await init();

    // Find best matching topic
    final topic = _findMatchingTopic(question);
    if (topic != null) {
      return AlwakilResponse(
        success: true,
        answerEn: topic['answerEn'] as String,
        answerAr: topic['answerAr'] as String,
        relatedTopics: (topic['relatedTopics'] as List<dynamic>?)
            ?.map((t) => t as String)
            .toList(),
        sources: (topic['sources'] as List<dynamic>?)
            ?.map((s) => s as String)
            .toList(),
      );
    }

    // Default response if no match found
    return AlwakilResponse(
      success: true,
      answerEn: 'I don\'t have specific information about that. '
          'For accurate immigration advice, please consult with an immigration attorney.',
      answerAr: 'ليس لدي معلومات محددة حول ذلك. '
          'للحصول على نصيحة دقيقة بشأن الهجرة، يرجى استشارة محامي هجرة.',
    );
  }

  /// Get frequently asked questions
  List<FAQ> getFAQs() {
    final faqs = _knowledgePack?['faqs'] as List<dynamic>? ?? [];
    return faqs.map((f) => FAQ.fromJson(f as Map<String, dynamic>)).toList();
  }

  /// Get quick tips for a category
  List<QuickTip> getQuickTips(String category) {
    final tips = _knowledgePack?['quickTips'] as Map<String, dynamic>? ?? {};
    final categoryTips = tips[category] as List<dynamic>? ?? [];
    return categoryTips
        .map((t) => QuickTip.fromJson(t as Map<String, dynamic>))
        .toList();
  }

  /// Find matching topic from knowledge pack
  Map<String, dynamic>? _findMatchingTopic(String question) {
    final topics = _knowledgePack?['topics'] as List<dynamic>? ?? [];
    final lowerQuestion = question.toLowerCase();

    for (final topic in topics) {
      final keywords = (topic['keywords'] as List<dynamic>?)
          ?.map((k) => k.toString().toLowerCase())
          .toList() ?? [];
      
      for (final keyword in keywords) {
        if (lowerQuestion.contains(keyword)) {
          return topic as Map<String, dynamic>;
        }
      }
    }

    return null;
  }

  /// Default knowledge pack (fallback)
  Map<String, dynamic> _getDefaultKnowledge() {
    return {
      'topics': [
        {
          'id': 'visa_extension',
          'keywords': ['extend', 'extension', 'تمديد', 'visa'],
          'answerEn': 'To extend your visa, you need to file Form I-539 with USCIS before your current status expires. '
              'Processing times vary, but you should apply at least 45 days before expiration.',
          'answerAr': 'لتمديد تأشيرتك، تحتاج إلى تقديم نموذج I-539 إلى USCIS قبل انتهاء وضعك الحالي. '
              'تختلف أوقات المعالجة، لكن يجب عليك التقديم قبل 45 يومًا على الأقل من انتهاء الصلاحية.',
          'relatedTopics': ['status_change', 'i94'],
          'sources': ['uscis.gov'],
        },
        {
          'id': 'green_card_timeline',
          'keywords': ['green card', 'البطاقة الخضراء', 'permanent resident', 'timeline'],
          'answerEn': 'Green card processing times vary by category. Family-based green cards can take 1-5+ years. '
              'Employment-based green cards depend on your priority date and country of birth.',
          'answerAr': 'تختلف أوقات معالجة البطاقة الخضراء حسب الفئة. يمكن أن تستغرق البطاقات الخضراء العائلية من 1-5+ سنوات. '
              'تعتمد البطاقات الخضراء القائمة على العمل على تاريخ الأولوية وبلد الميلاد.',
          'relatedTopics': ['citizenship', 'ead'],
        },
        {
          'id': 'citizenship',
          'keywords': ['citizenship', 'الجنسية', 'naturalization', 'n-400'],
          'answerEn': 'You can apply for citizenship (N-400) after 5 years as a permanent resident (3 years if married to a US citizen). '
              'You can apply 90 days before meeting the requirement.',
          'answerAr': 'يمكنك التقدم للحصول على الجنسية (N-400) بعد 5 سنوات كمقيم دائم (3 سنوات إذا كنت متزوجًا من مواطن أمريكي). '
              'يمكنك التقديم قبل 90 يومًا من استيفاء الشرط.',
          'relatedTopics': ['green_card_timeline'],
        },
        {
          'id': 'work_permit',
          'keywords': ['work', 'ead', 'employment', 'عمل', 'تصريح'],
          'answerEn': 'An Employment Authorization Document (EAD) allows you to work in the US. '
              'File Form I-765 to apply. Processing typically takes 3-6 months.',
          'answerAr': 'يسمح لك تصريح العمل (EAD) بالعمل في الولايات المتحدة. '
              'قدم نموذج I-765 للتقديم. عادة ما تستغرق المعالجة 3-6 أشهر.',
        },
      ],
      'faqs': [
        {
          'questionEn': 'How long can I stay in the US on a B1/B2 visa?',
          'questionAr': 'كم يمكنني البقاء في الولايات المتحدة بتأشيرة B1/B2؟',
          'answerEn': 'Typically up to 6 months, as determined by the CBP officer at entry.',
          'answerAr': 'عادة حتى 6 أشهر، كما يحددها ضابط CBP عند الدخول.',
        },
        {
          'questionEn': 'Can I travel while my green card application is pending?',
          'questionAr': 'هل يمكنني السفر أثناء انتظار طلب البطاقة الخضراء؟',
          'answerEn': 'You need an Advance Parole document (I-131) to travel and return.',
          'answerAr': 'تحتاج إلى وثيقة الإفراج المشروط المسبق (I-131) للسفر والعودة.',
        },
      ],
      'quickTips': {
        'general': [
          {
            'tipEn': 'Always keep copies of all immigration documents',
            'tipAr': 'احتفظ دائمًا بنسخ من جميع وثائق الهجرة',
          },
          {
            'tipEn': 'Never overstay your authorized period',
            'tipAr': 'لا تتجاوز أبدًا فترة إقامتك المصرح بها',
          },
        ],
      },
    };
  }
}

/// Response from Alwakil
class AlwakilResponse {
  final bool success;
  final String? answerEn;
  final String? answerAr;
  final List<String>? relatedTopics;
  final List<String>? sources;
  final String? errorMessage;

  const AlwakilResponse({
    required this.success,
    this.answerEn,
    this.answerAr,
    this.relatedTopics,
    this.sources,
    this.errorMessage,
  });

  String? getLocalizedAnswer(String locale) {
    return locale.startsWith('ar') ? answerAr : answerEn;
  }
}

/// Frequently asked question
class FAQ {
  final String questionEn;
  final String questionAr;
  final String answerEn;
  final String answerAr;

  const FAQ({
    required this.questionEn,
    required this.questionAr,
    required this.answerEn,
    required this.answerAr,
  });

  factory FAQ.fromJson(Map<String, dynamic> json) {
    return FAQ(
      questionEn: json['questionEn'] as String,
      questionAr: json['questionAr'] as String,
      answerEn: json['answerEn'] as String,
      answerAr: json['answerAr'] as String,
    );
  }

  String getLocalizedQuestion(String locale) {
    return locale.startsWith('ar') ? questionAr : questionEn;
  }

  String getLocalizedAnswer(String locale) {
    return locale.startsWith('ar') ? answerAr : answerEn;
  }
}

/// Quick tip
class QuickTip {
  final String tipEn;
  final String tipAr;

  const QuickTip({required this.tipEn, required this.tipAr});

  factory QuickTip.fromJson(Map<String, dynamic> json) {
    return QuickTip(
      tipEn: json['tipEn'] as String,
      tipAr: json['tipAr'] as String,
    );
  }

  String getLocalizedTip(String locale) {
    return locale.startsWith('ar') ? tipAr : tipEn;
  }
}
