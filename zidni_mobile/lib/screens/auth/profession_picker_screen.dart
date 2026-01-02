import 'package:flutter/material.dart';
import '../../auth/auth_repository.dart';

/// Profession picker screen with Arabic-first categories.
/// Required categories: Trader/Importer, Manufacturer, Service Provider, Student, Traveler, Other.
/// Service Provider shows sub-categories on selection.
class ProfessionPickerScreen extends StatefulWidget {
  final AuthRepository authRepository;
  final VoidCallback? onComplete;

  const ProfessionPickerScreen({
    super.key,
    required this.authRepository,
    this.onComplete,
  });

  @override
  State<ProfessionPickerScreen> createState() => _ProfessionPickerScreenState();
}

class _ProfessionPickerScreenState extends State<ProfessionPickerScreen> {
  String? _selectedProfession;
  String? _selectedSubProfession;
  bool _isLoading = false;

  // Profession data
  static const List<Map<String, dynamic>> _professions = [
    {
      'id': 'trader_importer',
      'name_ar': 'تاجر/مستورد',
      'icon': Icons.business,
      'color': Color(0xFF2196F3),
      'subCategories': <Map<String, String>>[],
    },
    {
      'id': 'manufacturer',
      'name_ar': 'مصنّع',
      'icon': Icons.factory,
      'color': Color(0xFF9C27B0),
      'subCategories': <Map<String, String>>[],
    },
    {
      'id': 'service_provider',
      'name_ar': 'مقدم خدمات',
      'icon': Icons.build,
      'color': Color(0xFFFF9800),
      'subCategories': [
        {'id': 'carpenter', 'name_ar': 'نجار'},
        {'id': 'electrician', 'name_ar': 'كهربائي'},
        {'id': 'plumber', 'name_ar': 'سباك'},
        {'id': 'mechanic', 'name_ar': 'ميكانيكي'},
        {'id': 'driver', 'name_ar': 'سائق'},
        {'id': 'other_service', 'name_ar': 'أخرى'},
      ],
    },
    {
      'id': 'student',
      'name_ar': 'طالب',
      'icon': Icons.school,
      'color': Color(0xFF4CAF50),
      'subCategories': <Map<String, String>>[],
    },
    {
      'id': 'traveler',
      'name_ar': 'مسافر',
      'icon': Icons.flight,
      'color': Color(0xFF00BCD4),
      'subCategories': <Map<String, String>>[],
    },
    {
      'id': 'other',
      'name_ar': 'أخرى',
      'icon': Icons.more_horiz,
      'color': Color(0xFF607D8B),
      'subCategories': <Map<String, String>>[],
    },
  ];

  List<Map<String, String>> get _currentSubCategories {
    if (_selectedProfession == null) return [];
    final profession = _professions.firstWhere(
      (p) => p['id'] == _selectedProfession,
      orElse: () => {'subCategories': <Map<String, String>>[]},
    );
    return List<Map<String, String>>.from(profession['subCategories'] ?? []);
  }

  bool get _needsSubCategory {
    return _selectedProfession == 'service_provider';
  }

  bool get _canContinue {
    if (_selectedProfession == null) return false;
    if (_needsSubCategory && _selectedSubProfession == null) return false;
    return true;
  }

  Future<void> _saveProfession() async {
    if (!_canContinue) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await widget.authRepository.updateProfession(
        _selectedProfession!,
        _selectedSubProfession,
      );

      if (mounted) {
        widget.onComplete?.call();
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('حدث خطأ. حاول مرة أخرى.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl, // Arabic-first
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text(
            'ماذا تعمل؟',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black54),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Subtitle
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Text(
                  'اختر مهنتك لنساعدك بشكل أفضل',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),

              // Profession grid
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Main professions grid
                      GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.3,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                        ),
                        itemCount: _professions.length,
                        itemBuilder: (context, index) {
                          final profession = _professions[index];
                          final isSelected = _selectedProfession == profession['id'];
                          
                          return _buildProfessionCard(
                            id: profession['id'] as String,
                            nameAr: profession['name_ar'] as String,
                            icon: profession['icon'] as IconData,
                            color: profession['color'] as Color,
                            isSelected: isSelected,
                          );
                        },
                      ),

                      // Sub-categories (if service provider selected)
                      if (_needsSubCategory && _currentSubCategories.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        const Text(
                          'حدد نوع الخدمة',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _currentSubCategories.map((sub) {
                            final isSelected = _selectedSubProfession == sub['id'];
                            return ChoiceChip(
                              label: Text(
                                sub['name_ar']!,
                                style: TextStyle(
                                  color: isSelected ? Colors.white : Colors.black87,
                                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFF9800),
                              backgroundColor: Colors.grey[100],
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSubProfession = selected ? sub['id'] : null;
                                });
                              },
                            );
                          }).toList(),
                        ),
                      ],

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Continue button
              Padding(
                padding: const EdgeInsets.all(24),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _canContinue && !_isLoading ? _saveProfession : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2196F3),
                      disabledBackgroundColor: Colors.grey[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                            'متابعة',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfessionCard({
    required String id,
    required String nameAr,
    required IconData icon,
    required Color color,
    required bool isSelected,
  }) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProfession = id;
          // Reset sub-profession when changing main profession
          if (id != 'service_provider') {
            _selectedSubProfession = null;
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected ? color : Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.grey[600],
                size: 28,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              nameAr,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
