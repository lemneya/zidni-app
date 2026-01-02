import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/immigration/templates_service.dart';

/// Screen for browsing and using immigration phrase templates.
class TemplatesScreen extends StatefulWidget {
  const TemplatesScreen({super.key});

  @override
  State<TemplatesScreen> createState() => _TemplatesScreenState();
}

class _TemplatesScreenState extends State<TemplatesScreen> {
  List<TemplateCategory> _categories = [];
  String? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    _loadTemplates();
  }

  Future<void> _loadTemplates() async {
    await TemplatesService.instance.init();
    setState(() {
      _categories = TemplatesService.instance.categories;
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
          title: Text(isArabic ? 'عبارات الهجرة' : 'Immigration Phrases'),
        ),
        body: _selectedCategoryId == null
            ? _buildCategoryList(isArabic)
            : _buildTemplateList(isArabic),
      ),
    );
  }

  Widget _buildCategoryList(bool isArabic) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final category = _categories[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: _getCategoryColor(index).withOpacity(0.1),
              child: Icon(
                _getCategoryIcon(category.icon),
                color: _getCategoryColor(index),
              ),
            ),
            title: Text(category.getLocalizedName(isArabic ? 'ar' : 'en')),
            subtitle: Text(
              '${category.templates.length} ${isArabic ? 'عبارة' : 'phrases'}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => setState(() => _selectedCategoryId = category.id),
          ),
        );
      },
    );
  }

  Widget _buildTemplateList(bool isArabic) {
    final category = _categories.firstWhere(
      (c) => c.id == _selectedCategoryId,
    );

    return Column(
      children: [
        // Back button
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: Text(category.getLocalizedName(isArabic ? 'ar' : 'en')),
          onTap: () => setState(() => _selectedCategoryId = null),
        ),
        const Divider(),
        
        // Templates
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: category.templates.length,
            itemBuilder: (context, index) {
              final template = category.templates[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Arabic phrase
                      Text(
                        template.phraseAr,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        textDirection: TextDirection.rtl,
                      ),
                      const SizedBox(height: 8),
                      
                      // English phrase
                      Text(
                        template.phraseEn,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Actions
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () => _copyToClipboard(
                              isArabic ? template.phraseAr : template.phraseEn,
                            ),
                            icon: const Icon(Icons.copy, size: 16),
                            label: Text(isArabic ? 'نسخ' : 'Copy'),
                          ),
                          TextButton.icon(
                            onPressed: () => _speakPhrase(template),
                            icon: const Icon(Icons.volume_up, size: 16),
                            label: Text(isArabic ? 'نطق' : 'Speak'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'تم النسخ'
              : 'Copied',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void _speakPhrase(PhraseTemplate template) {
    // TODO: Integrate with GUL TTS
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          Localizations.localeOf(context).languageCode == 'ar'
              ? 'سيتم التكامل مع قُل'
              : 'Will integrate with GUL',
        ),
      ),
    );
  }

  Color _getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  IconData _getCategoryIcon(String? iconName) {
    switch (iconName) {
      case 'badge':
        return Icons.badge;
      case 'gavel':
        return Icons.gavel;
      case 'directions_car':
        return Icons.directions_car;
      case 'security':
        return Icons.security;
      case 'account_balance':
        return Icons.account_balance;
      default:
        return Icons.chat_bubble_outline;
    }
  }
}
