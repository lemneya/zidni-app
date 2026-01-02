import 'package:flutter/material.dart';
import '../../models/wallet_models.dart';
import '../../services/wallet/wallet_service.dart';
import '../../widgets/wallet/balance_card.dart';
import '../../widgets/wallet/tx_list_empty_state.dart';
import '../../widgets/wallet/coming_soon_sheet.dart';

/// Wallet screen for Zidni Pay.
/// Shows balance (0), empty transaction list, and "Coming Soon" for Add Funds.
class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final WalletService _walletService = WalletService();
  WalletState _walletState = WalletState.empty();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadWalletState();
  }

  @override
  void dispose() {
    _walletService.dispose();
    super.dispose();
  }

  Future<void> _loadWalletState() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final state = await _walletService.fetchWalletState();
      if (mounted) {
        setState(() {
          _walletState = state;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _walletState = WalletState.empty();
          _isLoading = false;
        });
      }
    }
  }

  void _showComingSoon() {
    ComingSoonSheet.show(context, featureName: 'إضافة رصيد');
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic-first
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            'المحفظة',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black87),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline, color: Colors.black54),
              onPressed: () {
                // Future: open wallet help/tutorial
                ComingSoonSheet.show(context, featureName: 'مساعدة المحفظة');
              },
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF1565C0),
                ),
              )
            : RefreshIndicator(
                onRefresh: _loadWalletState,
                color: const Color(0xFF1565C0),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Balance card
                      BalanceCard(
                        walletState: _walletState,
                        onAddFunds: _showComingSoon,
                      ),

                      // Quick actions row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.send,
                                label: 'إرسال',
                                onTap: () => ComingSoonSheet.show(
                                  context,
                                  featureName: 'إرسال الأموال',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.download,
                                label: 'استلام',
                                onTap: () => ComingSoonSheet.show(
                                  context,
                                  featureName: 'استلام الأموال',
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildQuickAction(
                                icon: Icons.history,
                                label: 'السجل',
                                onTap: () {
                                  // Scroll to transactions (already visible)
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Transactions section
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'المعاملات الأخيرة',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                // Future: view all transactions
                              },
                              child: Text(
                                'عرض الكل',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Transaction list or empty state
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: TxListWidget(
                          transactions: _walletState.transactions,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Zidni Pay info banner
                      _buildInfoBanner(),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: const Color(0xFF1565C0),
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1565C0).withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1565C0).withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF1565C0).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.info_outline,
              color: Color(0xFF1565C0),
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Zidni Pay قيد التطوير',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'سنوفر قريباً خدمات الدفع والتحويل الآمنة',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
