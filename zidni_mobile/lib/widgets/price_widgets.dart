import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:zidni_mobile/models/price_calculation.dart';
import 'package:zidni_mobile/services/price_intelligence_service.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';

/// Price Calculator Widget (Free Tier)
///
/// Basic calculator for unit price × quantity + shipping + fees
class PriceCalculatorWidget extends StatefulWidget {
  final double? initialUnitPrice;
  final int? initialQuantity;
  final String? currency;
  final Function(PriceCalculation)? onCalculated;

  const PriceCalculatorWidget({
    Key? key,
    this.initialUnitPrice,
    this.initialQuantity,
    this.currency = 'USD',
    this.onCalculated,
  }) : super(key: key);

  @override
  State<PriceCalculatorWidget> createState() => _PriceCalculatorWidgetState();
}

class _PriceCalculatorWidgetState extends State<PriceCalculatorWidget> {
  late TextEditingController _unitPriceController;
  late TextEditingController _quantityController;
  late TextEditingController _shippingController;
  late TextEditingController _dutiesController;
  late TextEditingController _feesController;

  PriceCalculation? _calculation;

  @override
  void initState() {
    super.initState();
    _unitPriceController = TextEditingController(
      text: widget.initialUnitPrice?.toString() ?? '',
    );
    _quantityController = TextEditingController(
      text: widget.initialQuantity?.toString() ?? '1',
    );
    _shippingController = TextEditingController(text: '0');
    _dutiesController = TextEditingController(text: '10'); // Default 10%
    _feesController = TextEditingController(text: '0');

    // Calculate on init if values provided
    if (widget.initialUnitPrice != null && widget.initialQuantity != null) {
      _calculate();
    }
  }

  @override
  void dispose() {
    _unitPriceController.dispose();
    _quantityController.dispose();
    _shippingController.dispose();
    _dutiesController.dispose();
    _feesController.dispose();
    super.dispose();
  }

  void _calculate() {
    final unitPrice = double.tryParse(_unitPriceController.text) ?? 0;
    final quantity = int.tryParse(_quantityController.text) ?? 1;
    final shipping = double.tryParse(_shippingController.text) ?? 0;
    final duties = double.tryParse(_dutiesController.text) ?? 0;
    final fees = double.tryParse(_feesController.text) ?? 0;

    if (unitPrice <= 0 || quantity <= 0) {
      setState(() {
        _calculation = null;
      });
      return;
    }

    final calc = PriceIntelligenceService.calculatePricing(
      unitPrice: unitPrice,
      quantity: quantity,
      shippingCost: shipping,
      dutiesPercent: duties,
      otherFees: fees,
      currency: widget.currency!,
    );

    setState(() {
      _calculation = calc;
    });

    widget.onCalculated?.call(calc);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Price Calculator',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _unitPriceController,
              label: 'Unit Price',
              prefix: widget.currency,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _quantityController,
              label: 'Quantity',
              suffix: 'units',
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _shippingController,
              label: 'Shipping Cost',
              prefix: widget.currency,
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _dutiesController,
              label: 'Import Duties',
              suffix: '%',
              onChanged: (_) => _calculate(),
            ),
            const SizedBox(height: 12),
            _buildTextField(
              controller: _feesController,
              label: 'Other Fees',
              prefix: widget.currency,
              onChanged: (_) => _calculate(),
            ),
            if (_calculation != null) ...[
              const Divider(height: 32),
              _buildResultRow(
                'Subtotal',
                _formatCurrency(_calculation!.subtotal),
              ),
              _buildResultRow(
                'Shipping',
                _formatCurrency(_calculation!.shippingCost),
              ),
              _buildResultRow(
                'Duties (${_calculation!.dutiesPercent}%)',
                _formatCurrency(_calculation!.dutiesAmount),
              ),
              _buildResultRow(
                'Other Fees',
                _formatCurrency(_calculation!.otherFees),
              ),
              const Divider(height: 24),
              _buildResultRow(
                'Total Cost',
                _formatCurrency(_calculation!.totalCost),
                bold: true,
              ),
              _buildResultRow(
                'Per Unit (Landed)',
                _formatCurrency(_calculation!.landedCostPerUnit),
                bold: true,
                color: Colors.blue,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? prefix,
    String? suffix,
    TextInputType? keyboardType,
    Function(String)? onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType ?? TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix != null ? '$prefix ' : null,
        suffixText: suffix,
        border: const OutlineInputBorder(),
        isDense: true,
      ),
      onChanged: onChanged,
    );
  }

  Widget _buildResultRow(String label, String value, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              color: color,
              fontSize: bold ? 16 : 14,
            ),
          ),
        ],
      ),
    );
  }

  String _formatCurrency(double amount) {
    return '${widget.currency} ${amount.toStringAsFixed(2)}';
  }
}

/// Price Insight Badge (shows on deal cards)
///
/// Color-coded badge showing if price is good/fair/high
class PriceInsightBadge extends StatelessWidget {
  final PriceInsight insight;
  final bool showPercentage;

  const PriceInsightBadge({
    Key? key,
    required this.insight,
    this.showPercentage = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final color = _getRecommendationColor();
    final icon = _getRecommendationIcon();
    final text = insight.recommendationText;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (showPercentage && insight.percentageDifference != 0) ...[
            const SizedBox(width: 4),
            Text(
              '${insight.percentageDifference > 0 ? '+' : ''}${insight.percentageDifference.toStringAsFixed(0)}%',
              style: TextStyle(
                color: color,
                fontSize: 10,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRecommendationColor() {
    switch (insight.recommendation) {
      case PriceRecommendation.excellent:
        return Colors.green.shade700;
      case PriceRecommendation.good:
        return Colors.green;
      case PriceRecommendation.fair:
        return Colors.blue;
      case PriceRecommendation.high:
        return Colors.orange;
      case PriceRecommendation.tooHigh:
        return Colors.red;
    }
  }

  IconData _getRecommendationIcon() {
    switch (insight.recommendation) {
      case PriceRecommendation.excellent:
        return Icons.check_circle;
      case PriceRecommendation.good:
        return Icons.thumb_up;
      case PriceRecommendation.fair:
        return Icons.info;
      case PriceRecommendation.high:
        return Icons.warning;
      case PriceRecommendation.tooHigh:
        return Icons.error;
    }
  }
}

/// Price Analysis Card (detailed view)
///
/// Full price analysis with market data and recommendations
class PriceAnalysisCard extends StatelessWidget {
  final PriceInsight insight;
  final VoidCallback? onViewComparables;

  const PriceAnalysisCard({
    Key? key,
    required this.insight,
    this.onViewComparables,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.insights, color: Colors.blue),
                const SizedBox(width: 8),
                const Text(
                  'Price Analysis',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                PriceInsightBadge(insight: insight, showPercentage: false),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoRow('Category', insight.category),
            _buildInfoRow('Your Price', '\$${insight.quotedPrice.toStringAsFixed(2)}'),
            _buildInfoRow('Market Average', '\$${insight.marketAverage.toStringAsFixed(2)}'),
            _buildInfoRow(
              'Market Range',
              '\$${insight.marketRange.min.toStringAsFixed(2)} - \$${insight.marketRange.max.toStringAsFixed(2)}',
            ),
            _buildInfoRow(
              'Price Percentile',
              '${insight.percentile}th (better than ${100 - insight.percentile}% of market)',
            ),
            const Divider(height: 24),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      insight.actionSuggestion,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            if (insight.comparables.isNotEmpty) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: onViewComparables,
                icon: const Icon(Icons.compare_arrows),
                label: Text('View ${insight.comparables.length} Comparable Products'),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              'Data updated ${_formatTimeAgo(insight.updatedAt)} • Confidence: ${insight.confidence}%',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return '${diff.inMinutes}m ago';
  }
}

/// Price Comparison Bottom Sheet
///
/// Shows price calculator + market analysis in a modal sheet
class PriceComparisonBottomSheet extends StatefulWidget {
  final String? productName;
  final String? category;
  final double? initialPrice;
  final int? initialQuantity;

  const PriceComparisonBottomSheet({
    Key? key,
    this.productName,
    this.category,
    this.initialPrice,
    this.initialQuantity,
  }) : super(key: key);

  @override
  State<PriceComparisonBottomSheet> createState() =>
      _PriceComparisonBottomSheetState();

  static Future<void> show(
    BuildContext context, {
    String? productName,
    String? category,
    double? initialPrice,
    int? initialQuantity,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => PriceComparisonBottomSheet(
        productName: productName,
        category: category,
        initialPrice: initialPrice,
        initialQuantity: initialQuantity,
      ),
    );
  }
}

class _PriceComparisonBottomSheetState
    extends State<PriceComparisonBottomSheet> {
  PriceCalculation? _calculation;
  PriceInsight? _insight;
  bool _isLoadingInsight = false;
  bool _hasBusinessTier = false;

  @override
  void initState() {
    super.initState();
    _checkEntitlement();
  }

  Future<void> _checkEntitlement() async {
    final entitlement = await EntitlementService.getEntitlement();
    setState(() {
      _hasBusinessTier = entitlement.canExportPDF;
    });
  }

  Future<void> _analyzePrice() async {
    if (!_hasBusinessTier || _calculation == null) return;

    setState(() {
      _isLoadingInsight = true;
    });

    final insight = await PriceIntelligenceService.analyzePricing(
      productName: widget.productName ?? 'Product',
      category: widget.category ?? 'Default',
      quotedPrice: _calculation!.unitPrice,
      quantity: _calculation!.quantity,
    );

    setState(() {
      _insight = insight;
      _isLoadingInsight = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text(
                    'Price Analysis',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              PriceCalculatorWidget(
                initialUnitPrice: widget.initialPrice,
                initialQuantity: widget.initialQuantity,
                onCalculated: (calc) {
                  setState(() {
                    _calculation = calc;
                  });
                },
              ),
              const SizedBox(height: 16),
              if (_hasBusinessTier && _calculation != null) ...[
                ElevatedButton.icon(
                  onPressed: _isLoadingInsight ? null : _analyzePrice,
                  icon: _isLoadingInsight
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.insights),
                  label: const Text('Analyze with Market Data'),
                ),
              ],
              if (!_hasBusinessTier && _calculation != null) ...[
                _buildUpgradePrompt(),
              ],
              if (_insight != null) ...[
                const SizedBox(height: 16),
                PriceAnalysisCard(insight: _insight!),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildUpgradePrompt() {
    return Card(
      color: Colors.orange.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Icon(Icons.lock, color: Colors.orange, size: 32),
            const SizedBox(height: 8),
            const Text(
              'Upgrade to Business for Market Analysis',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Get market price comparison, percentile ranking, and negotiation recommendations',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                // TODO: Navigate to upgrade screen
              },
              child: const Text('Upgrade Now'),
            ),
          ],
        ),
      ),
    );
  }
}
