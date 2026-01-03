import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zidni_mobile/services/whatsapp_service.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/models/deal_folder.dart';

/// WhatsApp action button for sending follow-up messages
///
/// GATE: COMM-1 - Direct WhatsApp Send
///
/// FREE TIER: Manual phone input + copy-paste
/// BUSINESS TIER: One-tap send with auto-extracted contact
class WhatsAppActionButton extends StatelessWidget {
  final DealFolder? dealFolder;
  final String? transcript;
  final String? supplierName;
  final String? phoneNumber;
  final String? customMessage;

  const WhatsAppActionButton({
    Key? key,
    this.dealFolder,
    this.transcript,
    this.supplierName,
    this.phoneNumber,
    this.customMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handleWhatsAppSend(context),
      icon: const Icon(Icons.send),
      label: const Text('Send via WhatsApp'),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF25D366), // WhatsApp green
        foregroundColor: Colors.white,
      ),
    );
  }

  Future<void> _handleWhatsAppSend(BuildContext context) async {
    // Check if WhatsApp is installed
    final isInstalled = await WhatsAppService.isWhatsAppInstalled();
    if (!isInstalled) {
      _showError(context, 'WhatsApp is not installed on this device');
      return;
    }

    // Check entitlement for smart features
    final entitlement = await EntitlementService.getEntitlement();
    final hasBusinessFeatures = entitlement.canExportPDF;

    if (hasBusinessFeatures && phoneNumber == null) {
      // Business tier: Try smart send with auto-extraction
      await _handleBusinessSend(context);
    } else {
      // Free tier or explicit phone provided: Manual send
      await _handleFreeSend(context);
    }
  }

  /// Business tier: Smart send with auto-extraction
  Future<void> _handleBusinessSend(BuildContext context) async {
    final message = _generateMessage();

    final success = await WhatsAppService.sendMessageSmart(
      message: message,
      supplierName: supplierName ?? dealFolder?.supplierName,
      contactInfo: phoneNumber != null ? {'phone': phoneNumber} : null,
    );

    if (!success) {
      // Extraction failed, fall back to manual entry
      _showPhoneInputDialog(context, message);
    }
  }

  /// Free tier: Manual phone entry
  Future<void> _handleFreeSend(BuildContext context) async {
    final message = _generateMessage();

    if (phoneNumber != null) {
      // Phone provided, send directly
      final success = await WhatsAppService.sendMessage(
        phoneNumber: phoneNumber!,
        message: message,
      );

      if (!success) {
        _showError(context, 'Failed to send WhatsApp message');
      }
    } else {
      // Show phone input dialog
      _showPhoneInputDialog(context, message);
    }
  }

  /// Generate follow-up message
  String _generateMessage() {
    if (customMessage != null) {
      return customMessage!;
    }

    // Use template generator
    final supplier = supplierName ?? dealFolder?.supplierName ?? 'Supplier';
    final language = 'en'; // TODO: Get from user preferences

    return WhatsAppService.generateFollowUpTemplate(
      supplierName: supplier,
      language: language,
      productCategory: dealFolder?.category,
      boothNumber: dealFolder?.boothHall,
    );
  }

  /// Show phone input dialog for manual entry
  void _showPhoneInputDialog(BuildContext context, String message) {
    final phoneController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Enter WhatsApp Number'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                hintText: '+86 138 0013 8000',
                prefixIcon: Icon(Icons.phone),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            const Text(
              'Include country code (e.g., +86 for China)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final phone = phoneController.text.trim();
              if (phone.isEmpty) {
                _showError(context, 'Please enter a phone number');
                return;
              }

              Navigator.pop(context);

              final success = await WhatsAppService.sendMessage(
                phoneNumber: phone,
                message: message,
              );

              if (!success) {
                _showError(context, 'Failed to send WhatsApp message');
              }
            },
            icon: const Icon(Icons.send),
            label: const Text('Send'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF25D366),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Show error message
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}

/// WhatsApp share option for bottom sheets
class WhatsAppShareOption extends StatelessWidget {
  final String message;
  final String? phoneNumber;
  final VoidCallback? onUpgrade;

  const WhatsAppShareOption({
    Key? key,
    required this.message,
    this.phoneNumber,
    this.onUpgrade,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFF25D366).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.message,
          color: Color(0xFF25D366),
        ),
      ),
      title: const Text('Send via WhatsApp'),
      subtitle: const Text('One-tap follow-up message'),
      trailing: FutureBuilder<bool>(
        future: _hasBusinessFeatures(),
        builder: (context, snapshot) {
          final hasBusiness = snapshot.data ?? false;
          if (!hasBusiness && phoneNumber == null) {
            return const Chip(
              label: Text('Pro'),
              backgroundColor: Colors.orange,
              labelStyle: TextStyle(color: Colors.white, fontSize: 10),
            );
          }
          return const Icon(Icons.arrow_forward_ios, size: 16);
        },
      ),
      onTap: () => _handleTap(context),
    );
  }

  Future<bool> _hasBusinessFeatures() async {
    final entitlement = await EntitlementService.getEntitlement();
    return entitlement.canExportPDF;
  }

  Future<void> _handleTap(BuildContext context) async {
    final hasBusiness = await _hasBusinessFeatures();

    if (!hasBusiness && phoneNumber == null) {
      // Show upgrade prompt
      _showUpgradePrompt(context);
      return;
    }

    // Copy message to clipboard (free tier fallback)
    await Clipboard.setData(ClipboardData(text: message));

    // Try to send
    if (phoneNumber != null) {
      await WhatsAppService.sendMessage(
        phoneNumber: phoneNumber!,
        message: message,
      );
    } else {
      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Message copied! Open WhatsApp to paste and send.'),
          backgroundColor: Color(0xFF25D366),
        ),
      );
    }
  }

  void _showUpgradePrompt(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Upgrade to Business'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Send in 1 tap with Business! (vs 30 seconds manually)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Business features:'),
            const SizedBox(height: 8),
            _buildFeatureBullet('Auto-extract contact from business cards'),
            _buildFeatureBullet('One-tap WhatsApp send'),
            _buildFeatureBullet('Save 5-10 minutes per follow-up'),
            _buildFeatureBullet('Unlimited cloud boosts'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              // Copy message as fallback
              Clipboard.setData(ClipboardData(text: message));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Message copied to clipboard'),
                ),
              );
            },
            child: const Text('Copy Instead'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onUpgrade?.call();
            },
            child: const Text('Upgrade Now'),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureBullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
