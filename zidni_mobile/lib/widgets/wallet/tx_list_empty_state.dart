import 'package:flutter/material.dart';

/// Empty state widget for transaction list.
/// Shows when there are no transactions: "لا توجد معاملات بعد"
class TxListEmptyState extends StatelessWidget {
  const TxListEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),

          // Empty state title (Arabic)
          Text(
            'لا توجد معاملات بعد',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Empty state description (Arabic)
          Text(
            'ستظهر هنا جميع معاملاتك المالية',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Transaction list widget that shows transactions or empty state.
class TxListWidget extends StatelessWidget {
  final List<dynamic> transactions;

  const TxListWidget({
    super.key,
    required this.transactions,
  });

  @override
  Widget build(BuildContext context) {
    if (transactions.isEmpty) {
      return const TxListEmptyState();
    }

    // Future: render actual transaction list
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        // Placeholder for future transaction item rendering
        return const SizedBox.shrink();
      },
    );
  }
}
