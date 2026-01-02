import 'package:flutter/material.dart';
import '../../auth/auth_repository.dart';
import '../../screens/auth/auth_entry_screen.dart';

/// Auth value banner that shows only for guest users.
/// Explains why signup helps (backup, cross-device, business features).
/// Never blocks core actions.
class AuthValueBanner extends StatelessWidget {
  final AuthRepository authRepository;
  final VoidCallback? onAuthComplete;
  final bool compact;

  const AuthValueBanner({
    super.key,
    required this.authRepository,
    this.onAuthComplete,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    // Don't show if user is not a guest
    if (!authRepository.isGuest) {
      return const SizedBox.shrink();
    }

    return Directionality(
      textDirection: TextDirection.rtl, // Arabic-first
      child: compact ? _buildCompactBanner(context) : _buildFullBanner(context),
    );
  }

  Widget _buildFullBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF2196F3).withOpacity(0.1),
            const Color(0xFF4CAF50).withOpacity(0.1),
          ],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'أطلق شبكتك المهنية',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Benefits list
          _buildBenefitRow(
            icon: Icons.people_outline,
            text: 'التواصل مع محترفين آخرين في مجالك',
          ),
          const SizedBox(height: 8),
          _buildBenefitRow(
            icon: Icons.public,
            text: 'عرض مهاراتك وخدماتك لجمهور عالمي',
          ),
          const SizedBox(height: 8),
          _buildBenefitRow(
            icon: Icons.cloud_sync_outlined,
            text: 'النسخ الاحتياطي الآمن ومزامنة بياناتك',
          ),
          const SizedBox(height: 16),

          // CTA Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _navigateToAuth(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'تسجيل اختياري',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactBanner(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2196F3).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.shield_outlined,
            color: Color(0xFF1565C0),
            size: 24,
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'سجّل لحفظ بياناتك',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1565C0),
              ),
            ),
          ),
          TextButton(
            onPressed: () => _navigateToAuth(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text(
              'تسجيل',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2196F3),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitRow({required IconData icon, required String text}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF4CAF50),
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToAuth(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AuthEntryScreen(
          authRepository: authRepository,
          onAuthComplete: onAuthComplete,
        ),
      ),
    );
  }
}
