import 'package:flutter/material.dart';
import 'package:zidni_mobile/billing/screens/upgrade_screen.dart';

/// Soft Upgrade Modal
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Non-intrusive modal suggesting business upgrade based on trader behavior

class SoftUpgradeModal extends StatelessWidget {
  /// The trigger reason for showing this modal
  final UpgradeTrigger trigger;
  
  /// Callback when user dismisses the modal
  final VoidCallback? onDismiss;
  
  /// Callback when user taps upgrade
  final VoidCallback? onUpgrade;
  
  const SoftUpgradeModal({
    super.key,
    required this.trigger,
    this.onDismiss,
    this.onUpgrade,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Dialog(
        backgroundColor: const Color(0xFF1A1A2E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  trigger.icon,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                trigger.arabicTitle,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              
              // Message
              Text(
                trigger.arabicMessage,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              
              // Stats badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  trigger.statsBadge,
                  style: const TextStyle(
                    color: Color(0xFF6366F1),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              
              // Upgrade button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    onUpgrade?.call();
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const UpgradeScreen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'فعّل وضع الأعمال',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              
              // Dismiss button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  onDismiss?.call();
                },
                child: Text(
                  'لاحقاً',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Show the soft upgrade modal
  static Future<void> show(
    BuildContext context, {
    required UpgradeTrigger trigger,
    VoidCallback? onDismiss,
    VoidCallback? onUpgrade,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => SoftUpgradeModal(
        trigger: trigger,
        onDismiss: onDismiss,
        onUpgrade: onUpgrade,
      ),
    );
  }
}

/// Triggers for showing the soft upgrade modal
enum UpgradeTrigger {
  /// User created many deals
  manyDeals,
  
  /// User used FindIt many times
  frequentSearches,
  
  /// User attempted to export (gated feature)
  exportAttempt,
  
  /// User hit daily limit
  dailyLimitReached,
  
  /// User has been using app heavily
  powerUser,
}

extension UpgradeTriggerExtension on UpgradeTrigger {
  /// Get Arabic title for this trigger
  String get arabicTitle {
    switch (this) {
      case UpgradeTrigger.manyDeals:
        return 'أنت تاجر نشط! 🎯';
      case UpgradeTrigger.frequentSearches:
        return 'باحث محترف! 🔍';
      case UpgradeTrigger.exportAttempt:
        return 'تريد التصدير؟ 📄';
      case UpgradeTrigger.dailyLimitReached:
        return 'وصلت للحد اليومي';
      case UpgradeTrigger.powerUser:
        return 'مستخدم متميز! ⭐';
    }
  }
  
  /// Get Arabic message for this trigger
  String get arabicMessage {
    switch (this) {
      case UpgradeTrigger.manyDeals:
        return 'يبدو أنك تستخدم Zidni للتجارة بشكل جدي.\nفعّل وضع الأعمال للحصول على ميزات احترافية.';
      case UpgradeTrigger.frequentSearches:
        return 'تبحث كثيراً عن موردين!\nوضع الأعمال يمنحك بحث غير محدود وميزات إضافية.';
      case UpgradeTrigger.exportAttempt:
        return 'تصدير PDF متاح فقط في وضع الأعمال.\nفعّله الآن لتصدير صفقاتك ومتابعاتك.';
      case UpgradeTrigger.dailyLimitReached:
        return 'وصلت للحد اليومي المجاني.\nفعّل وضع الأعمال للاستخدام غير المحدود.';
      case UpgradeTrigger.powerUser:
        return 'أنت تستخدم Zidni بشكل مكثف!\nوضع الأعمال مصمم خصيصاً للتجار مثلك.';
    }
  }
  
  /// Get stats badge text
  String get statsBadge {
    switch (this) {
      case UpgradeTrigger.manyDeals:
        return '5+ صفقات هذا الأسبوع';
      case UpgradeTrigger.frequentSearches:
        return '10+ عمليات بحث هذا الأسبوع';
      case UpgradeTrigger.exportAttempt:
        return 'ميزة أعمال';
      case UpgradeTrigger.dailyLimitReached:
        return 'الحد اليومي';
      case UpgradeTrigger.powerUser:
        return 'مستخدم نشط';
    }
  }
  
  /// Get icon for this trigger
  IconData get icon {
    switch (this) {
      case UpgradeTrigger.manyDeals:
        return Icons.handshake;
      case UpgradeTrigger.frequentSearches:
        return Icons.search;
      case UpgradeTrigger.exportAttempt:
        return Icons.picture_as_pdf;
      case UpgradeTrigger.dailyLimitReached:
        return Icons.timer_off;
      case UpgradeTrigger.powerUser:
        return Icons.star;
    }
  }
}
