import 'package:flutter/material.dart';
import 'package:zidni_mobile/billing/models/entitlement.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/billing/services/feature_gate.dart';

/// Upgrade Screen
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Arabic-first upgrade/paywall screen explaining tiers

class UpgradeScreen extends StatefulWidget {
  /// Optional feature that triggered the upgrade prompt
  final Feature? triggeredByFeature;
  
  const UpgradeScreen({
    super.key,
    this.triggeredByFeature,
  });

  @override
  State<UpgradeScreen> createState() => _UpgradeScreenState();
}

class _UpgradeScreenState extends State<UpgradeScreen> {
  Entitlement? _currentEntitlement;
  bool _isLoading = true;
  bool _isRestoring = false;
  bool _isUpgrading = false;

  @override
  void initState() {
    super.initState();
    _loadEntitlement();
  }

  Future<void> _loadEntitlement() async {
    final entitlement = await EntitlementService.getEntitlement();
    setState(() {
      _currentEntitlement = entitlement;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A2E),
        appBar: AppBar(
          backgroundColor: const Color(0xFF1A1A2E),
          elevation: 0,
          title: const Text(
            'ترقية الحساب',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header with icon
                      _buildHeader(),
                      const SizedBox(height: 24),
                      
                      // Triggered feature message
                      if (widget.triggeredByFeature != null)
                        _buildTriggeredFeatureMessage(),
                      
                      // Current tier badge
                      _buildCurrentTierBadge(),
                      const SizedBox(height: 24),
                      
                      // Tier comparison
                      _buildTierComparison(),
                      const SizedBox(height: 24),
                      
                      // Business features list
                      _buildBusinessFeatures(),
                      const SizedBox(height: 24),
                      
                      // Coming soon features
                      _buildComingSoonFeatures(),
                      const SizedBox(height: 32),
                      
                      // Upgrade button
                      _buildUpgradeButton(),
                      const SizedBox(height: 12),
                      
                      // Restore button
                      _buildRestoreButton(),
                      const SizedBox(height: 24),
                      
                      // Terms note
                      _buildTermsNote(),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6366F1).withOpacity(0.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.rocket_launch,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: 16),
        RichText(
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.center,
          text: const TextSpan(
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(text: 'فعّل قوة '),
              TextSpan(
                text: 'Zidni',
                style: TextStyle(fontFamily: 'Roboto'),
              ),
              TextSpan(text: ' الكاملة'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'وضع الأعمال للتجار المحترفين',
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 16,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTriggeredFeatureMessage() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Colors.orange, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'هذه الميزة (${widget.triggeredByFeature!.arabicName}) متاحة في وضع الأعمال',
              style: const TextStyle(
                color: Colors.orange,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentTierBadge() {
    final tier = _currentEntitlement?.tier ?? SubscriptionTier.personalFree;
    final isBusiness = tier.isBusiness;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isBusiness 
            ? Colors.green.withOpacity(0.1) 
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isBusiness 
              ? Colors.green.withOpacity(0.3) 
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isBusiness ? Icons.verified : Icons.person,
            color: isBusiness ? Colors.green : Colors.grey,
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'حسابك الحالي: ${tier.arabicName}',
            style: TextStyle(
              color: isBusiness ? Colors.green : Colors.grey,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTierComparison() {
    return Row(
      children: [
        // Free tier
        Expanded(
          child: _buildTierCard(
            title: 'شخصي مجاني',
            subtitle: 'للاستخدام الشخصي',
            price: 'مجاني',
            features: [
              'ترجمة صوتية غير محدودة',
              '10 مسح يومياً',
              '15 بحث يومياً',
              '5 متابعات يومياً',
            ],
            isHighlighted: false,
          ),
        ),
        const SizedBox(width: 12),
        // Business tier
        Expanded(
          child: _buildTierCard(
            title: 'أعمال فردي',
            subtitle: 'للتجار المحترفين',
            price: 'قريباً',
            features: [
              'كل ميزات المجاني',
              'مسح غير محدود',
              'بحث غير محدود',
              'متابعات غير محدودة',
              'تصدير PDF',
              'تعزيز سحابي',
            ],
            isHighlighted: true,
          ),
        ),
      ],
    );
  }

  Widget _buildTierCard({
    required String title,
    required String subtitle,
    required String price,
    required List<String> features,
    required bool isHighlighted,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isHighlighted 
            ? const Color(0xFF6366F1).withOpacity(0.1) 
            : Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isHighlighted 
              ? const Color(0xFF6366F1) 
              : Colors.white.withOpacity(0.1),
          width: isHighlighted ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isHighlighted)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'موصى به',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          Text(
            title,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF6366F1) : Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.5),
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            price,
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF6366F1) : Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...features.map((f) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle,
                  color: isHighlighted 
                      ? const Color(0xFF6366F1) 
                      : Colors.green,
                  size: 14,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    f,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _buildBusinessFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ميزات وضع الأعمال',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...FeatureGate.businessFeatures.map((feature) => _buildFeatureRow(
          icon: _getFeatureIcon(feature),
          title: feature.arabicName,
          subtitle: _getFeatureDescription(feature),
        )),
      ],
    );
  }

  Widget _buildComingSoonFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'قريباً',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'قيد التطوير',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...FeatureGate.comingSoonFeatures.map((feature) => _buildFeatureRow(
          icon: _getFeatureIcon(feature),
          title: feature.arabicName,
          subtitle: _getFeatureDescription(feature),
          isComingSoon: true,
        )),
      ],
    );
  }

  Widget _buildFeatureRow({
    required IconData icon,
    required String title,
    required String subtitle,
    bool isComingSoon = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: isComingSoon 
                  ? Colors.orange.withOpacity(0.2) 
                  : const Color(0xFF6366F1).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: isComingSoon ? Colors.orange : const Color(0xFF6366F1),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (isComingSoon)
            const Icon(
              Icons.schedule,
              color: Colors.orange,
              size: 18,
            )
          else
            const Icon(
              Icons.check_circle,
              color: Color(0xFF6366F1),
              size: 18,
            ),
        ],
      ),
    );
  }

  Widget _buildUpgradeButton() {
    return ElevatedButton(
      onPressed: _isUpgrading ? null : _handleUpgrade,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF6366F1),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 8,
        shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
      ),
      child: _isUpgrading
          ? const SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
          : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rocket_launch, size: 20),
                SizedBox(width: 8),
                Text(
                  'ترقية إلى وضع الأعمال',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildRestoreButton() {
    return TextButton(
      onPressed: _isRestoring ? null : _handleRestore,
      child: _isRestoring
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                color: Colors.white54,
                strokeWidth: 2,
              ),
            )
          : Text(
              'استعادة المشتريات',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
    );
  }

  Widget _buildTermsNote() {
    return Text(
      'الدفع سيتم من خلال متجر التطبيقات. يمكنك إلغاء الاشتراك في أي وقت.',
      style: TextStyle(
        color: Colors.white.withOpacity(0.4),
        fontSize: 11,
      ),
      textAlign: TextAlign.center,
    );
  }

  IconData _getFeatureIcon(Feature feature) {
    switch (feature) {
      case Feature.cloudBoost:
        return Icons.cloud_upload;
      case Feature.exportPdf:
        return Icons.picture_as_pdf;
      case Feature.teamMode:
        return Icons.group;
      case Feature.verification:
        return Icons.verified_user;
      case Feature.unlimitedFollowups:
        return Icons.repeat;
      case Feature.unlimitedScans:
        return Icons.document_scanner;
      case Feature.unlimitedSearches:
        return Icons.search;
    }
  }

  String _getFeatureDescription(Feature feature) {
    switch (feature) {
      case Feature.cloudBoost:
        return 'ترجمة محسّنة بالذكاء الاصطناعي';
      case Feature.exportPdf:
        return 'صدّر صفقاتك ومتابعاتك كملفات PDF';
      case Feature.teamMode:
        return 'شارك الصفقات مع فريقك';
      case Feature.verification:
        return 'تحقق من الموردين والمنتجات';
      case Feature.unlimitedFollowups:
        return 'أنشئ متابعات بدون حدود';
      case Feature.unlimitedScans:
        return 'امسح منتجات بدون حدود';
      case Feature.unlimitedSearches:
        return 'ابحث عن موردين بدون حدود';
    }
  }

  Future<void> _handleUpgrade() async {
    setState(() => _isUpgrading = true);
    
    // Placeholder: In BILL-2, this will:
    // 1. Show RevenueCat paywall
    // 2. Process payment
    // 3. Update entitlement on success
    
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      setState(() => _isUpgrading = false);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الدفع سيكون متاحاً قريباً'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isRestoring = true);
    
    final restored = await EntitlementService.restorePurchase();
    
    if (mounted) {
      setState(() => _isRestoring = false);
      
      if (restored) {
        await _loadEntitlement();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم استعادة المشتريات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('لم يتم العثور على مشتريات سابقة'),
            backgroundColor: Colors.grey,
          ),
        );
      }
    }
  }
}
