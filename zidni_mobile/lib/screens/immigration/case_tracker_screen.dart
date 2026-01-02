import 'package:flutter/material.dart';
import '../../models/immigration/uscis_case.dart';
import '../../services/immigration/case_store.dart';

/// Screen for tracking USCIS cases by receipt number.
class CaseTrackerScreen extends StatefulWidget {
  const CaseTrackerScreen({super.key});

  @override
  State<CaseTrackerScreen> createState() => _CaseTrackerScreenState();
}

class _CaseTrackerScreenState extends State<CaseTrackerScreen> {
  final _receiptController = TextEditingController();
  List<USCISCase> _cases = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCases();
  }

  Future<void> _loadCases() async {
    await CaseStore.instance.init();
    setState(() {
      _cases = CaseStore.instance.cases;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'تتبع الطلبات' : 'Case Tracker'),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Add case card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isArabic ? 'إضافة طلب للتتبع' : 'Add Case to Track',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _receiptController,
                      decoration: InputDecoration(
                        labelText: isArabic ? 'رقم الإيصال' : 'Receipt Number',
                        hintText: 'WAC2190012345',
                        border: const OutlineInputBorder(),
                        prefixIcon: const Icon(Icons.receipt_long),
                      ),
                      textCapitalization: TextCapitalization.characters,
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _addCase,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.add),
                        label: Text(isArabic ? 'إضافة' : 'Add'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Cases list
            if (_cases.isEmpty)
              _buildEmptyState(isArabic)
            else ...[
              Text(
                isArabic ? 'الطلبات المتتبعة' : 'Tracked Cases',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ..._cases.map((c) => _buildCaseCard(c, isArabic)),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isArabic) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.track_changes,
              size: 64,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'لا توجد طلبات متتبعة' : 'No Cases Tracked',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            Text(
              isArabic
                  ? 'أضف رقم الإيصال أعلاه لتتبع طلبك'
                  : 'Add a receipt number above to track your case',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaseCard(USCISCase caseItem, bool isArabic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(caseItem.status).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(caseItem.status),
            color: _getStatusColor(caseItem.status),
          ),
        ),
        title: Text(caseItem.receiptNumber),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(caseItem.formType.getLocalizedName(isArabic ? 'ar' : 'en')),
            Text(
              caseItem.status.getLocalizedName(isArabic ? 'ar' : 'en'),
              style: TextStyle(
                color: _getStatusColor(caseItem.status),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => _refreshCase(caseItem),
        ),
        onTap: () => _showCaseDetails(caseItem),
      ),
    );
  }

  Future<void> _addCase() async {
    final receiptNumber = _receiptController.text.trim();
    if (receiptNumber.isEmpty) return;

    if (!USCISCase.isValidReceiptNumber(receiptNumber)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            Localizations.localeOf(context).languageCode == 'ar'
                ? 'رقم الإيصال غير صالح'
                : 'Invalid receipt number',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await CaseStore.instance.addCase(
        receiptNumber: receiptNumber,
        formType: USCISFormType.other,
      );
      _receiptController.clear();
      await _loadCases();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshCase(USCISCase caseItem) async {
    // TODO: Implement case refresh
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'جاري التحديث...'
              : 'Refreshing...',
        ),
      ),
    );
  }

  void _showCaseDetails(USCISCase caseItem) {
    // TODO: Show case details bottom sheet
  }

  Color _getStatusColor(CaseStatus status) {
    switch (status) {
      case CaseStatus.approved:
      case CaseStatus.cardMailed:
        return Colors.green;
      case CaseStatus.denied:
        return Colors.red;
      case CaseStatus.requestForEvidence:
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  IconData _getStatusIcon(CaseStatus status) {
    switch (status) {
      case CaseStatus.approved:
        return Icons.check_circle;
      case CaseStatus.denied:
        return Icons.cancel;
      case CaseStatus.cardMailed:
        return Icons.local_shipping;
      case CaseStatus.requestForEvidence:
        return Icons.warning;
      default:
        return Icons.hourglass_empty;
    }
  }

  @override
  void dispose() {
    _receiptController.dispose();
    super.dispose();
  }
}
