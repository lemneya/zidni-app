/// Tutorial topic enum for all Zidni components.
enum TutorialTopic {
  gul,
  eyes,
  alwakil,
  memory,
  dealMaker,
  wallet,
  contextPacks,
}

/// Tutorial step model containing text and timing information.
class TutorialStep {
  final String titleArabic;
  final String titleEnglish;
  final String descriptionArabic;
  final String descriptionEnglish;
  final Duration duration;
  final String? animationState; // Rive state machine state name

  const TutorialStep({
    required this.titleArabic,
    required this.titleEnglish,
    required this.descriptionArabic,
    required this.descriptionEnglish,
    this.duration = const Duration(seconds: 5),
    this.animationState,
  });
}

/// Tutorial data model containing all assets and steps for a topic.
class TutorialData {
  final TutorialTopic topic;
  final String nameArabic;
  final String nameEnglish;
  final String riveAssetPath;
  final String audioAssetPath;
  final String? youtubeUrl;
  final List<TutorialStep> steps;

  const TutorialData({
    required this.topic,
    required this.nameArabic,
    required this.nameEnglish,
    required this.riveAssetPath,
    required this.audioAssetPath,
    this.youtubeUrl,
    required this.steps,
  });
}

/// Registry service that maps tutorial topics to their assets and steps.
class TutorialRegistry {
  static final TutorialRegistry _instance = TutorialRegistry._internal();
  factory TutorialRegistry() => _instance;
  TutorialRegistry._internal();

  /// Returns the tutorial data for a given topic.
  TutorialData getTutorial(TutorialTopic topic) {
    return _tutorials[topic]!;
  }

  /// Returns all available tutorials.
  List<TutorialData> get allTutorials => _tutorials.values.toList();

  /// Returns tutorials grouped by category for the help screen.
  Map<String, List<TutorialData>> get tutorialsByCategory {
    return {
      'الميزات الأساسية': [
        _tutorials[TutorialTopic.gul]!,
        _tutorials[TutorialTopic.eyes]!,
      ],
      'أدوات التاجر': [
        _tutorials[TutorialTopic.alwakil]!,
        _tutorials[TutorialTopic.memory]!,
        _tutorials[TutorialTopic.dealMaker]!,
      ],
      'الإعدادات والمحفظة': [
        _tutorials[TutorialTopic.contextPacks]!,
        _tutorials[TutorialTopic.wallet]!,
      ],
    };
  }

  static final Map<TutorialTopic, TutorialData> _tutorials = {
    // GUL Tutorial
    TutorialTopic.gul: const TutorialData(
      topic: TutorialTopic.gul,
      nameArabic: 'قُل — الترجمة الصوتية',
      nameEnglish: 'GUL — Voice Translation',
      riveAssetPath: 'assets/tutorials/gul_tutorial.riv',
      audioAssetPath: 'assets/tutorials/gul_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/gul-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'مرحباً بك في قُل',
          titleEnglish: 'Welcome to GUL',
          descriptionArabic: 'قُل هو محرك الترجمة الصوتية الخاص بك. تحدث بلغتك وسيترجم لك فوراً.',
          descriptionEnglish: 'GUL is your voice translation engine. Speak in your language and get instant translation.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'الزر الأزرق — أنا أتحدث',
          titleEnglish: 'Blue Button — I Speak',
          descriptionArabic: 'اضغط على الزر الأزرق عندما تريد التحدث. سيترجم كلامك للغة الأخرى.',
          descriptionEnglish: 'Press the blue button when you want to speak. It will translate your speech.',
          animationState: 'blue_mic',
        ),
        TutorialStep(
          titleArabic: 'الزر الأخضر — هو يتحدث',
          titleEnglish: 'Green Button — They Speak',
          descriptionArabic: 'اضغط على الزر الأخضر عندما يتحدث الطرف الآخر. سيترجم كلامه لك.',
          descriptionEnglish: 'Press the green button when the other person speaks. It will translate for you.',
          animationState: 'green_mic',
        ),
        TutorialStep(
          titleArabic: 'العبارات السريعة',
          titleEnglish: 'Quick Phrases',
          descriptionArabic: 'استخدم العبارات السريعة للجمل الشائعة. اضغط على أي عبارة لنطقها فوراً.',
          descriptionEnglish: 'Use quick phrases for common sentences. Tap any phrase to speak it instantly.',
          animationState: 'quick_phrases',
        ),
      ],
    ),

    // EYES Tutorial
    TutorialTopic.eyes: const TutorialData(
      topic: TutorialTopic.eyes,
      nameArabic: 'عيون — مسح المنتجات',
      nameEnglish: 'EYES — Product Scanning',
      riveAssetPath: 'assets/tutorials/eyes_tutorial.riv',
      audioAssetPath: 'assets/tutorials/eyes_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/eyes-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'مرحباً بك في عيون',
          titleEnglish: 'Welcome to EYES',
          descriptionArabic: 'عيون يساعدك على مسح المنتجات والعثور على الموردين بسرعة.',
          descriptionEnglish: 'EYES helps you scan products and find suppliers quickly.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'مسح المنتج',
          titleEnglish: 'Scan Product',
          descriptionArabic: 'وجّه الكاميرا نحو المنتج أو علبته. سيقرأ عيون النص والباركود تلقائياً.',
          descriptionEnglish: 'Point the camera at the product or its box. EYES will read text and barcode automatically.',
          animationState: 'scanning',
        ),
        TutorialStep(
          titleArabic: 'البحث عن المورد',
          titleEnglish: 'Find Supplier',
          descriptionArabic: 'اضغط "ابحث عنه" للعثور على الموردين في 1688 وعلي بابا.',
          descriptionEnglish: 'Tap "Find it" to search for suppliers on 1688 and Alibaba.',
          animationState: 'search',
        ),
        TutorialStep(
          titleArabic: 'إنشاء صفقة',
          titleEnglish: 'Create Deal',
          descriptionArabic: 'اضغط "إنشاء صفقة" للحصول على قالب استفسار جاهز للإرسال.',
          descriptionEnglish: 'Tap "Create Deal" to get an inquiry template ready to send.',
          animationState: 'deal',
        ),
      ],
    ),

    // Alwakil Tutorial
    TutorialTopic.alwakil: const TutorialData(
      topic: TutorialTopic.alwakil,
      nameArabic: 'الوكيل — مساعدك الذكي',
      nameEnglish: 'Alwakil — Your Smart Agent',
      riveAssetPath: 'assets/tutorials/alwakil_tutorial.riv',
      audioAssetPath: 'assets/tutorials/alwakil_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/alwakil-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'تعرّف على الوكيل',
          titleEnglish: 'Meet Alwakil',
          descriptionArabic: 'الوكيل هو مساعدك الذكي في التجارة. يساعدك في التفاوض والتحقق من الموردين.',
          descriptionEnglish: 'Alwakil is your smart trading assistant. It helps with negotiation and supplier verification.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'التحقق من المورد',
          titleEnglish: 'Verify Supplier',
          descriptionArabic: 'الوكيل يتحقق من مصداقية الموردين ويعطيك تقييماً موثوقاً.',
          descriptionEnglish: 'Alwakil verifies supplier credibility and gives you a trusted rating.',
          animationState: 'verify',
        ),
        TutorialStep(
          titleArabic: 'المساعدة في التفاوض',
          titleEnglish: 'Negotiation Help',
          descriptionArabic: 'احصل على نصائح للتفاوض وعبارات مفيدة بالصينية.',
          descriptionEnglish: 'Get negotiation tips and useful phrases in Chinese.',
          animationState: 'negotiate',
        ),
        TutorialStep(
          titleArabic: 'تتبع الصفقات',
          titleEnglish: 'Track Deals',
          descriptionArabic: 'الوكيل يتابع صفقاتك ويذكّرك بالمتابعة في الوقت المناسب.',
          descriptionEnglish: 'Alwakil tracks your deals and reminds you to follow up at the right time.',
          animationState: 'track',
        ),
      ],
    ),

    // Memory Tutorial
    TutorialTopic.memory: const TutorialData(
      topic: TutorialTopic.memory,
      nameArabic: 'الذاكرة — سجل الصفقات',
      nameEnglish: 'Memory — Deal History',
      riveAssetPath: 'assets/tutorials/memory_tutorial.riv',
      audioAssetPath: 'assets/tutorials/memory_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/memory-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'ذاكرتك التجارية',
          titleEnglish: 'Your Trading Memory',
          descriptionArabic: 'الذاكرة تحفظ كل صفقاتك ومحادثاتك مع الموردين.',
          descriptionEnglish: 'Memory saves all your deals and conversations with suppliers.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'البحث السريع',
          titleEnglish: 'Quick Search',
          descriptionArabic: 'ابحث في صفقاتك السابقة بالاسم أو المنتج أو التاريخ.',
          descriptionEnglish: 'Search your past deals by name, product, or date.',
          animationState: 'search',
        ),
        TutorialStep(
          titleArabic: 'المجلدات',
          titleEnglish: 'Folders',
          descriptionArabic: 'نظّم صفقاتك في مجلدات حسب المورد أو المنتج أو الحالة.',
          descriptionEnglish: 'Organize your deals in folders by supplier, product, or status.',
          animationState: 'folders',
        ),
        TutorialStep(
          titleArabic: 'التصدير والمشاركة',
          titleEnglish: 'Export & Share',
          descriptionArabic: 'صدّر صفقاتك أو شاركها مع فريقك بسهولة.',
          descriptionEnglish: 'Export your deals or share them with your team easily.',
          animationState: 'export',
        ),
      ],
    ),

    // Deal Maker Tutorial
    TutorialTopic.dealMaker: const TutorialData(
      topic: TutorialTopic.dealMaker,
      nameArabic: 'صانع الصفقات',
      nameEnglish: 'Deal Maker',
      riveAssetPath: 'assets/tutorials/dealmaker_tutorial.riv',
      audioAssetPath: 'assets/tutorials/dealmaker_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/dealmaker-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'أنشئ صفقات احترافية',
          titleEnglish: 'Create Professional Deals',
          descriptionArabic: 'صانع الصفقات يساعدك على إنشاء استفسارات وعروض احترافية.',
          descriptionEnglish: 'Deal Maker helps you create professional inquiries and offers.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'قوالب جاهزة',
          titleEnglish: 'Ready Templates',
          descriptionArabic: 'اختر من قوالب جاهزة بالعربية والصينية والإنجليزية.',
          descriptionEnglish: 'Choose from ready templates in Arabic, Chinese, and English.',
          animationState: 'templates',
        ),
        TutorialStep(
          titleArabic: 'تخصيص الرسالة',
          titleEnglish: 'Customize Message',
          descriptionArabic: 'عدّل القالب وأضف تفاصيل منتجك وكميتك المطلوبة.',
          descriptionEnglish: 'Edit the template and add your product details and required quantity.',
          animationState: 'customize',
        ),
        TutorialStep(
          titleArabic: 'إرسال ومتابعة',
          titleEnglish: 'Send & Follow Up',
          descriptionArabic: 'أرسل عبر WeChat أو WhatsApp وتابع الردود من الذاكرة.',
          descriptionEnglish: 'Send via WeChat or WhatsApp and track responses from Memory.',
          animationState: 'send',
        ),
      ],
    ),

    // Wallet Tutorial
    TutorialTopic.wallet: const TutorialData(
      topic: TutorialTopic.wallet,
      nameArabic: 'المحفظة — Zidni Pay',
      nameEnglish: 'Wallet — Zidni Pay',
      riveAssetPath: 'assets/tutorials/wallet_tutorial.riv',
      audioAssetPath: 'assets/tutorials/wallet_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/wallet-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'محفظتك الرقمية',
          titleEnglish: 'Your Digital Wallet',
          descriptionArabic: 'Zidni Pay هي محفظتك الرقمية للدفع والتحويل بسهولة.',
          descriptionEnglish: 'Zidni Pay is your digital wallet for easy payments and transfers.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'إضافة رصيد',
          titleEnglish: 'Add Funds',
          descriptionArabic: 'أضف رصيداً من بطاقتك أو حسابك البنكي. (قريباً)',
          descriptionEnglish: 'Add funds from your card or bank account. (Coming Soon)',
          animationState: 'add_funds',
        ),
        TutorialStep(
          titleArabic: 'الدفع للموردين',
          titleEnglish: 'Pay Suppliers',
          descriptionArabic: 'ادفع للموردين مباشرة من التطبيق بأمان. (قريباً)',
          descriptionEnglish: 'Pay suppliers directly from the app securely. (Coming Soon)',
          animationState: 'pay',
        ),
        TutorialStep(
          titleArabic: 'سجل المعاملات',
          titleEnglish: 'Transaction History',
          descriptionArabic: 'تابع جميع معاملاتك المالية في مكان واحد.',
          descriptionEnglish: 'Track all your financial transactions in one place.',
          animationState: 'history',
        ),
      ],
    ),

    // Context Packs Tutorial
    TutorialTopic.contextPacks: const TutorialData(
      topic: TutorialTopic.contextPacks,
      nameArabic: 'حِزم السياق',
      nameEnglish: 'Context Packs',
      riveAssetPath: 'assets/tutorials/packs_tutorial.riv',
      audioAssetPath: 'assets/tutorials/packs_tutorial_ar.mp3',
      youtubeUrl: 'https://youtube.com/zidni/packs-tutorial',
      steps: [
        TutorialStep(
          titleArabic: 'حِزم مخصصة لك',
          titleEnglish: 'Packs Customized for You',
          descriptionArabic: 'حِزم السياق تعطيك عبارات وأدوات مخصصة حسب موقعك ونشاطك.',
          descriptionEnglish: 'Context Packs give you phrases and tools customized to your location and activity.',
          animationState: 'intro',
        ),
        TutorialStep(
          titleArabic: 'حزمة معرض كانتون',
          titleEnglish: 'Canton Fair Pack',
          descriptionArabic: 'عبارات خاصة بالتجارة والتفاوض مع الموردين الصينيين.',
          descriptionEnglish: 'Phrases for trading and negotiating with Chinese suppliers.',
          animationState: 'canton',
        ),
        TutorialStep(
          titleArabic: 'حزمة السفر',
          titleEnglish: 'Travel Pack',
          descriptionArabic: 'عبارات للمطار والفندق والتاكسي والمطاعم.',
          descriptionEnglish: 'Phrases for airport, hotel, taxi, and restaurants.',
          animationState: 'travel',
        ),
        TutorialStep(
          titleArabic: 'التبديل التلقائي',
          titleEnglish: 'Auto Switch',
          descriptionArabic: 'التطبيق يقترح الحزمة المناسبة تلقائياً حسب موقعك.',
          descriptionEnglish: 'The app automatically suggests the right pack based on your location.',
          animationState: 'auto',
        ),
      ],
    ),
  };
}
