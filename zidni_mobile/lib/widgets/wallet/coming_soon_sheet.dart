import 'package:flutter/material.dart';

/// Coming Soon bottom sheet for wallet features.
/// Shows "قريبًا — Zidni Pay" message.
class ComingSoonSheet extends StatelessWidget {
  final String? featureName;

  const ComingSoonSheet({
    super.key,
    this.featureName,
  });

  /// Shows the Coming Soon sheet as a modal bottom sheet.
  static Future<void> show(BuildContext context, {String? featureName}) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ComingSoonSheet(featureName: featureName),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // Coming Soon icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF1565C0).withOpacity(0.1),
                  const Color(0xFF4CAF50).withOpacity(0.1),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.rocket_launch_outlined,
              size: 40,
              color: Color(0xFF1565C0),
            ),
          ),
          const SizedBox(height: 24),

          // Title (Arabic)
          const Text(
            'قريبًا — Zidni Pay',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1565C0),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),

          // Description (Arabic)
          Text(
            'نعمل على إضافة خدمات الدفع والتحويل.\nترقبوا التحديثات القادمة!',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Feature-specific message if provided
          if (featureName != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                featureName!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
          const SizedBox(height: 32),

          // Features coming soon list
          _buildFeatureItem(
            icon: Icons.add_card,
            title: 'إضافة رصيد',
            subtitle: 'شحن المحفظة بسهولة',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.swap_horiz,
            title: 'تحويل الأموال',
            subtitle: 'إرسال واستقبال الأموال',
          ),
          const SizedBox(height: 12),
          _buildFeatureItem(
            icon: Icons.shopping_bag_outlined,
            title: 'الدفع للموردين',
            subtitle: 'دفع آمن وسريع',
          ),
          const SizedBox(height: 32),

          // Close button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1565C0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'حسناً',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: const Color(0xFF1565C0).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: const Color(0xFF1565C0),
            size: 22,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Icon(
          Icons.hourglass_empty,
          color: Colors.grey[400],
          size: 20,
        ),
      ],
    );
  }
}
