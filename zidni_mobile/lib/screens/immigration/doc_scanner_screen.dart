import 'package:flutter/material.dart';
import '../../models/immigration/immigration_document.dart';
import '../../services/immigration/doc_scanner_service.dart';

/// Screen for scanning immigration documents using OCR.
/// 
/// Integrates with EYES OCR to scan:
/// - I-94 (Arrival/Departure Record)
/// - Visa stamps
/// - Green Card
/// - SSN card
/// - EAD card
class DocScannerScreen extends StatefulWidget {
  const DocScannerScreen({super.key});

  @override
  State<DocScannerScreen> createState() => _DocScannerScreenState();
}

class _DocScannerScreenState extends State<DocScannerScreen> {
  bool _isScanning = false;
  ScanResult? _lastResult;
  ImmigrationDocumentType? _selectedType;

  @override
  Widget build(BuildContext context) {
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final textDirection = isArabic ? TextDirection.rtl : TextDirection.ltr;

    return Directionality(
      textDirection: textDirection,
      child: Scaffold(
        appBar: AppBar(
          title: Text(isArabic ? 'مسح المستندات' : 'Document Scanner'),
        ),
        body: _isScanning
            ? _buildScanningView(isArabic)
            : _lastResult != null
                ? _buildResultView(isArabic)
                : _buildDocumentTypeSelector(isArabic),
      ),
    );
  }

  Widget _buildDocumentTypeSelector(bool isArabic) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Instructions
        Card(
          color: Colors.blue.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(Icons.info_outline, color: Colors.blue.shade700),
                const SizedBox(height: 8),
                Text(
                  isArabic
                      ? 'اختر نوع المستند الذي تريد مسحه'
                      : 'Select the type of document you want to scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.blue.shade700),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Document type options
        ...ImmigrationDocumentType.values
            .where((t) => t != ImmigrationDocumentType.other)
            .map((type) => _buildDocumentTypeCard(type, isArabic)),
      ],
    );
  }

  Widget _buildDocumentTypeCard(ImmigrationDocumentType type, bool isArabic) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getTypeColor(type).withOpacity(0.1),
          child: Icon(
            _getTypeIcon(type),
            color: _getTypeColor(type),
          ),
        ),
        title: Text(type.getLocalizedName(isArabic ? 'ar' : 'en')),
        subtitle: Text(_getTypeDescription(type, isArabic)),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => _startScan(type),
      ),
    );
  }

  Widget _buildScanningView(bool isArabic) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 24),
          Text(
            isArabic ? 'جاري المسح...' : 'Scanning...',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            isArabic
                ? 'يرجى الانتظار بينما نقوم بتحليل المستند'
                : 'Please wait while we analyze the document',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildResultView(bool isArabic) {
    final result = _lastResult!;

    if (!result.success) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              isArabic ? 'فشل المسح' : 'Scan Failed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(result.errorMessage ?? ''),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _reset,
              child: Text(isArabic ? 'حاول مرة أخرى' : 'Try Again'),
            ),
          ],
        ),
      );
    }

    final document = result.document!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Success header
        Card(
          color: Colors.green.shade50,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isArabic ? 'تم المسح بنجاح' : 'Scan Successful',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green.shade700,
                        ),
                      ),
                      Text(
                        '${isArabic ? 'الثقة:' : 'Confidence:'} ${((result.confidence ?? 0) * 100).toStringAsFixed(0)}%',
                        style: TextStyle(color: Colors.green.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Document details
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  document.type.getLocalizedName(isArabic ? 'ar' : 'en'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const Divider(),
                if (document.fullName != null)
                  _buildDetailRow(
                    isArabic ? 'الاسم' : 'Name',
                    document.fullName!,
                  ),
                if (document.documentNumber != null)
                  _buildDetailRow(
                    isArabic ? 'رقم المستند' : 'Document Number',
                    document.documentNumber!,
                  ),
                if (document.expirationDate != null)
                  _buildDetailRow(
                    isArabic ? 'تاريخ الانتهاء' : 'Expiration Date',
                    _formatDate(document.expirationDate!),
                    isWarning: document.isExpired,
                  ),
                if (document.admitUntilDate != null)
                  _buildDetailRow(
                    isArabic ? 'مسموح حتى' : 'Admit Until',
                    _formatDate(document.admitUntilDate!),
                  ),
                if (document.classOfAdmission != null)
                  _buildDetailRow(
                    isArabic ? 'فئة القبول' : 'Class of Admission',
                    document.classOfAdmission!,
                  ),
                if (document.countryOfCitizenship != null)
                  _buildDetailRow(
                    isArabic ? 'الجنسية' : 'Citizenship',
                    document.countryOfCitizenship!,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Actions
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _reset,
                icon: const Icon(Icons.refresh),
                label: Text(isArabic ? 'مسح آخر' : 'Scan Another'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () => _saveDocument(document),
                icon: const Icon(Icons.save),
                label: Text(isArabic ? 'حفظ' : 'Save'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isWarning = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isWarning ? Colors.red : null,
              ),
            ),
          ),
          if (isWarning)
            const Icon(Icons.warning, color: Colors.red, size: 16),
        ],
      ),
    );
  }

  void _startScan(ImmigrationDocumentType type) async {
    setState(() {
      _selectedType = type;
      _isScanning = true;
    });

    // TODO: Open camera and capture image
    // For now, use mock scan
    final result = await DocScannerService.instance.scanDocument(
      imagePath: '/mock/path/to/image.jpg',
      documentType: type,
    );

    setState(() {
      _isScanning = false;
      _lastResult = result;
    });
  }

  void _reset() {
    setState(() {
      _lastResult = null;
      _selectedType = null;
    });
  }

  void _saveDocument(ImmigrationDocument document) {
    // TODO: Save to local storage
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'تم حفظ المستند'
              : 'Document saved',
        ),
      ),
    );
    Navigator.pop(context, document);
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Color _getTypeColor(ImmigrationDocumentType type) {
    switch (type) {
      case ImmigrationDocumentType.i94:
        return Colors.blue;
      case ImmigrationDocumentType.visa:
        return Colors.green;
      case ImmigrationDocumentType.greenCard:
        return Colors.teal;
      case ImmigrationDocumentType.ssn:
        return Colors.purple;
      case ImmigrationDocumentType.ead:
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getTypeIcon(ImmigrationDocumentType type) {
    switch (type) {
      case ImmigrationDocumentType.i94:
        return Icons.flight_land;
      case ImmigrationDocumentType.visa:
        return Icons.badge;
      case ImmigrationDocumentType.greenCard:
        return Icons.card_membership;
      case ImmigrationDocumentType.ssn:
        return Icons.security;
      case ImmigrationDocumentType.ead:
        return Icons.work;
      default:
        return Icons.document_scanner;
    }
  }

  String _getTypeDescription(ImmigrationDocumentType type, bool isArabic) {
    if (isArabic) {
      switch (type) {
        case ImmigrationDocumentType.i94:
          return 'سجل الوصول والمغادرة';
        case ImmigrationDocumentType.visa:
          return 'تأشيرة الدخول';
        case ImmigrationDocumentType.greenCard:
          return 'بطاقة الإقامة الدائمة';
        case ImmigrationDocumentType.ssn:
          return 'بطاقة الضمان الاجتماعي';
        case ImmigrationDocumentType.ead:
          return 'تصريح العمل';
        default:
          return '';
      }
    } else {
      switch (type) {
        case ImmigrationDocumentType.i94:
          return 'Arrival/Departure Record';
        case ImmigrationDocumentType.visa:
          return 'Entry Visa';
        case ImmigrationDocumentType.greenCard:
          return 'Permanent Resident Card';
        case ImmigrationDocumentType.ssn:
          return 'Social Security Card';
        case ImmigrationDocumentType.ead:
          return 'Employment Authorization';
        default:
          return '';
      }
    }
  }
}
