import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zidni_mobile/eyes/models/deal_record.dart';
import 'package:zidni_mobile/eyes/services/followup_kit_service.dart';

/// Follow-up Kit Card - Displays copy-ready templates for deal follow-up
/// Gate EYES-3: Create Deal + Follow-up Kit from Eyes
class FollowupKitCard extends StatefulWidget {
  final DealRecord deal;
  final VoidCallback? onClose;

  const FollowupKitCard({
    super.key,
    required this.deal,
    this.onClose,
  });

  @override
  State<FollowupKitCard> createState() => _FollowupKitCardState();
}

class _FollowupKitCardState extends State<FollowupKitCard> {
  late FollowupKit _kit;
  bool _arabicCopied = false;
  bool _supplierCopied = false;

  @override
  void initState() {
    super.initState();
    _kit = FollowupKitService.generateKit(widget.deal);
  }

  Future<void> _copyArabic() async {
    await Clipboard.setData(ClipboardData(text: _kit.arabicTemplate));
    setState(() {
      _arabicCopied = true;
      _supplierCopied = false;
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ النص العربي'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _copySupplier() async {
    await Clipboard.setData(ClipboardData(text: _kit.supplierTemplate));
    setState(() {
      _supplierCopied = true;
      _arabicCopied = false;
    });
    
    if (mounted) {
      final langName = _kit.supplierLanguage == 'zh' ? 'الصينية' : 'الإنجليزية';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم نسخ النص $langName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2A2A4E),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 16),

            // Header
            _buildHeader(),
            const SizedBox(height: 20),

            // Deal summary
            _buildDealSummary(),
            const SizedBox(height: 20),

            // Arabic template
            _buildTemplateSection(
              title: 'ملخصك (عربي)',
              icon: Icons.person,
              template: _kit.arabicTemplate,
              isCopied: _arabicCopied,
              onCopy: _copyArabic,
              buttonLabel: 'نسخ العربي',
            ),
            const SizedBox(height: 16),

            // Supplier template
            _buildTemplateSection(
              title: 'للمورد (${_kit.supplierLanguageArabicName})',
              icon: Icons.business,
              template: _kit.supplierTemplate,
              isCopied: _supplierCopied,
              onCopy: _copySupplier,
              buttonLabel: 'نسخ ${_kit.supplierLanguageArabicName}',
            ),
            const SizedBox(height: 20),

            // Close button
            if (widget.onClose != null)
              TextButton(
                onPressed: widget.onClose,
                child: const Text(
                  'إغلاق',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 24,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'تم إنشاء الصفقة!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'استخدم القوالب أدناه للمتابعة',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDealSummary() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.inventory_2, color: Colors.blue, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  widget.deal.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (widget.deal.selectedPlatform != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.store, color: Colors.white54, size: 14),
                const SizedBox(width: 8),
                Text(
                  'المنصة: ${widget.deal.selectedPlatform}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          if (widget.deal.contextChips.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: widget.deal.contextChips.map((chip) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    chip,
                    style: const TextStyle(
                      color: Colors.blue,
                      fontSize: 10,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTemplateSection({
    required String title,
    required IconData icon,
    required String template,
    required bool isCopied,
    required VoidCallback onCopy,
    required String buttonLabel,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCopied ? Colors.green.withOpacity(0.5) : Colors.white.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: const BorderRadius.vertical(top: Radius.circular(11)),
            ),
            child: Row(
              children: [
                Icon(icon, color: Colors.white70, size: 18),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (isCopied)
                  const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check, color: Colors.green, size: 16),
                      SizedBox(width: 4),
                      Text(
                        'تم النسخ',
                        style: TextStyle(color: Colors.green, fontSize: 12),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Template content
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            padding: const EdgeInsets.all(12),
            child: SingleChildScrollView(
              child: Text(
                template,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  height: 1.5,
                ),
              ),
            ),
          ),

          // Copy button
          Padding(
            padding: const EdgeInsets.all(12),
            child: ElevatedButton.icon(
              onPressed: onCopy,
              icon: Icon(isCopied ? Icons.check : Icons.copy, size: 18),
              label: Text(buttonLabel),
              style: ElevatedButton.styleFrom(
                backgroundColor: isCopied ? Colors.green : Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
