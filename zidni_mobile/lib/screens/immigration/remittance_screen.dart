import 'package:flutter/material.dart';

/// Screen for remittance/money transfer (UI shell - Coming Soon).
/// 
/// This is a placeholder UI for the future money transfer feature.
/// Designed for Arab immigrants sending money home.
class RemittanceScreen extends StatelessWidget {
  const RemittanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'إرسال الأموال' : 'Send Money'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Coming soon banner
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.indigo.shade700, Colors.indigo.shade500],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.send,
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isArabic ? 'قريباً — Zidni Pay' : 'Coming Soon — Zidni Pay',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isArabic
                        ? 'أرسل الأموال إلى عائلتك بسهولة وأمان'
                        : 'Send money to your family easily and securely',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Features preview
            Text(
              isArabic ? 'المميزات القادمة' : 'Upcoming Features',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),

            _buildFeatureCard(
              context,
              icon: Icons.speed,
              titleEn: 'Fast Transfers',
              titleAr: 'تحويلات سريعة',
              descriptionEn: 'Send money in minutes, not days',
              descriptionAr: 'أرسل الأموال في دقائق، وليس أيام',
              isArabic: isArabic,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.attach_money,
              titleEn: 'Low Fees',
              titleAr: 'رسوم منخفضة',
              descriptionEn: 'Competitive rates for all destinations',
              descriptionAr: 'أسعار تنافسية لجميع الوجهات',
              isArabic: isArabic,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.public,
              titleEn: 'MENA Coverage',
              titleAr: 'تغطية الشرق الأوسط',
              descriptionEn: 'Send to Egypt, Morocco, Algeria, and more',
              descriptionAr: 'أرسل إلى مصر، المغرب، الجزائر، والمزيد',
              isArabic: isArabic,
            ),
            _buildFeatureCard(
              context,
              icon: Icons.security,
              titleEn: 'Secure',
              titleAr: 'آمن',
              descriptionEn: 'Bank-level security for your transfers',
              descriptionAr: 'أمان على مستوى البنوك لتحويلاتك',
              isArabic: isArabic,
            ),

            const SizedBox(height: 24),

            // Notify me button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showNotifyDialog(context, isArabic),
                icon: const Icon(Icons.notifications_active),
                label: Text(
                  isArabic ? 'أبلغني عند الإطلاق' : 'Notify Me at Launch',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Alternative options
            Card(
              color: Colors.grey.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'في الوقت الحالي' : 'In the meantime',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isArabic
                          ? 'يمكنك استخدام Western Union أو Remitly لإرسال الأموال'
                          : 'You can use Western Union or Remitly to send money',
                      style: TextStyle(color: Colors.grey.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureCard(
    BuildContext context, {
    required IconData icon,
    required String titleEn,
    required String titleAr,
    required String descriptionEn,
    required String descriptionAr,
    required bool isArabic,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.shade50,
          child: Icon(icon, color: Colors.indigo),
        ),
        title: Text(isArabic ? titleAr : titleEn),
        subtitle: Text(isArabic ? descriptionAr : descriptionEn),
      ),
    );
  }

  void _showNotifyDialog(BuildContext context, bool isArabic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isArabic ? 'شكراً لاهتمامك!' : 'Thanks for your interest!'),
        content: Text(
          isArabic
              ? 'سنرسل لك إشعاراً عند إطلاق خدمة إرسال الأموال.'
              : 'We\'ll notify you when the money transfer service launches.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(isArabic ? 'حسناً' : 'OK'),
          ),
        ],
      ),
    );
  }
}
