import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:zidni_mobile/eyes/models/eyes_scan_result.dart';
import 'package:zidni_mobile/eyes/services/ocr_service.dart';
import 'package:zidni_mobile/eyes/widgets/product_insight_card.dart';

/// Eyes Scan Screen - Camera capture and OCR processing
/// Gate EYES-1: OCR Scan → Product Insight Card → Save
class EyesScanScreen extends StatefulWidget {
  const EyesScanScreen({super.key});

  @override
  State<EyesScanScreen> createState() => _EyesScanScreenState();
}

class _EyesScanScreenState extends State<EyesScanScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();
  
  bool _isProcessing = false;
  String? _capturedImagePath;
  EyesScanResult? _scanResult;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _ocrService.init();
    // Auto-launch camera on screen open
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _captureImage();
    });
  }

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }

  Future<void> _captureImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
      );
      
      if (image == null) {
        // User cancelled camera
        if (mounted && _capturedImagePath == null) {
          Navigator.of(context).pop();
        }
        return;
      }
      
      // Save image to app directory for persistence
      final appDir = await getApplicationDocumentsDirectory();
      final eyesDir = Directory('${appDir.path}/eyes_scans');
      if (!await eyesDir.exists()) {
        await eyesDir.create(recursive: true);
      }
      
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final savedPath = '${eyesDir.path}/scan_$timestamp.jpg';
      await File(image.path).copy(savedPath);
      
      setState(() {
        _capturedImagePath = savedPath;
        _isProcessing = true;
        _errorMessage = null;
      });
      
      await _processImage(savedPath);
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل التقاط الصورة: $e';
        _isProcessing = false;
      });
    }
  }

  Future<void> _processImage(String imagePath) async {
    try {
      final result = await _ocrService.processImage(imagePath);
      
      if (result.rawText.isEmpty) {
        setState(() {
          _errorMessage = 'لم يتم العثور على نص في الصورة';
          _isProcessing = false;
        });
        return;
      }
      
      setState(() {
        _scanResult = result;
        _isProcessing = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'فشل معالجة الصورة: $e';
        _isProcessing = false;
      });
    }
  }

  void _retakePhoto() {
    setState(() {
      _capturedImagePath = null;
      _scanResult = null;
      _errorMessage = null;
    });
    _captureImage();
  }

  void _onSaveComplete(EyesScanResult savedResult) {
    // Show success message and return to previous screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم الحفظ في السجل'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.of(context).pop(savedResult);
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
            'عيون زدني',
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
          actions: [
            if (_capturedImagePath != null && !_isProcessing)
              IconButton(
                icon: const Icon(Icons.camera_alt, color: Colors.white),
                onPressed: _retakePhoto,
                tooltip: 'التقاط صورة جديدة',
              ),
          ],
        ),
        body: SafeArea(
          child: _buildBody(),
        ),
      ),
    );
  }

  Widget _buildBody() {
    // Processing state
    if (_isProcessing) {
      return _buildProcessingState();
    }
    
    // Error state
    if (_errorMessage != null) {
      return _buildErrorState();
    }
    
    // Result state
    if (_scanResult != null) {
      return ProductInsightCard(
        result: _scanResult!,
        imagePath: _capturedImagePath,
        onRetake: _retakePhoto,
        onSaveComplete: _onSaveComplete,
      );
    }
    
    // Initial/waiting state
    return _buildWaitingState();
  }

  Widget _buildProcessingState() {
    return Column(
      children: [
        // Show captured image
        if (_capturedImagePath != null)
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.5), width: 2),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  File(_capturedImagePath!),
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        
        // Processing indicator
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 16),
                const Text(
                  'جاري قراءة النص...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'OCR Text Extraction',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.withOpacity(0.7),
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _retakePhoto,
              icon: const Icon(Icons.camera_alt),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaitingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.camera_alt,
            size: 64,
            color: Colors.white.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'جاري فتح الكاميرا...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
