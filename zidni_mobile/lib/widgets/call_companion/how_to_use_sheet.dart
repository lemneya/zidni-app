/// How To Use Sheet Widget for Call Companion Mode
/// Bottom sheet explaining how to use the call companion feature

import 'package:flutter/material.dart';

/// Bottom sheet with instructions for using Call Companion
class HowToUseSheet extends StatelessWidget {
  const HowToUseSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A2E),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Title
              const Center(
                child: Text(
                  'كيفية استخدام رفيق المكالمات',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Step 1: Speakerphone
              _buildStep(
                number: 1,
                icon: Icons.volume_up,
                color: Colors.blue,
                title: 'ضع المكالمة على مكبر الصوت',
                description:
                    'عند الاتصال بالمورد أو استقبال مكالمة منه، قم بتفعيل مكبر الصوت ليتمكن زدني من سماع المحادثة.',
              ),

              // Step 2: Listen mode
              _buildStep(
                number: 2,
                icon: Icons.hearing,
                color: Colors.green,
                title: 'استخدم زر "استمع" للصيني',
                description:
                    'عندما يتحدث المورد بالصينية، اضغط على زر "استمع" الأخضر. سيقوم زدني بتحويل كلامه إلى نص وترجمته للعربية.',
              ),

              // Step 3: Speak mode
              _buildStep(
                number: 3,
                icon: Icons.mic,
                color: Colors.blue,
                title: 'استخدم زر "تحدث" للعربية',
                description:
                    'عندما تريد الرد، اضغط على زر "تحدث" الأزرق وتكلم بالعربية. سيقوم زدني بترجمة كلامك ونطقه بالصينية للمورد.',
              ),

              // Step 4: Voice messages
              _buildStep(
                number: 4,
                icon: Icons.share,
                color: Colors.orange,
                title: 'ترجمة الرسائل الصوتية',
                description:
                    'يمكنك أيضاً مشاركة رسائل صوتية من WeChat أو WhatsApp مع زدني لترجمتها، ثم تسجيل ردك بالعربية وإرساله كرسالة صينية.',
              ),

              const SizedBox(height: 24),

              // Tips section
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.amber.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.lightbulb, color: Colors.amber, size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'نصائح للحصول على أفضل نتائج',
                          style: TextStyle(
                            color: Colors.amber,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildTip('تحدث بوضوح وببطء'),
                    _buildTip('تجنب الضوضاء الخلفية'),
                    _buildTip('انتظر حتى ينتهي المورد من الكلام قبل الضغط'),
                    _buildTip('استخدم جمل قصيرة ومباشرة'),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Offline note
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'يعمل بدون إنترنت',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'بعد تحميل النماذج، يمكنك استخدام رفيق المكالمات بدون اتصال بالإنترنت.',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.7),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Close button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('فهمت'),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep({
    required int number,
    required IconData icon,
    required Color color,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Number circle
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.2),
              border: Border.all(color: color),
            ),
            child: Center(
              child: Text(
                '$number',
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: Colors.amber.withOpacity(0.7),
            size: 14,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
