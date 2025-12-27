import 'package:flutter/material.dart';
import 'package:zidni_mobile/services/offline_settings_service.dart';
import 'package:zidni_mobile/services/local_companion_client.dart';

class OfflineSettingsScreen extends StatefulWidget {
  const OfflineSettingsScreen({Key? key}) : super(key: key);

  @override
  State<OfflineSettingsScreen> createState() => _OfflineSettingsScreenState();
}

class _OfflineSettingsScreenState extends State<OfflineSettingsScreen> {
  bool _offlineModeEnabled = false;
  final TextEditingController _urlController = TextEditingController();
  bool _loading = true;
  bool _testing = false;
  String? _testResult;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final enabled = await OfflineSettingsService.isOfflineModeEnabled();
    final url = await OfflineSettingsService.getCompanionUrl();
    if (mounted) {
      setState(() {
        _offlineModeEnabled = enabled;
        _urlController.text = url;
        _loading = false;
      });
    }
  }

  Future<void> _saveOfflineMode(bool enabled) async {
    await OfflineSettingsService.setOfflineModeEnabled(enabled);
    setState(() {
      _offlineModeEnabled = enabled;
    });
  }

  Future<void> _saveUrl() async {
    await OfflineSettingsService.setCompanionUrl(_urlController.text.trim());
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Companion URL saved'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    setState(() {
      _testing = true;
      _testResult = null;
    });

    final url = _urlController.text.trim();
    final client = LocalCompanionClient(baseUrl: url);
    final isHealthy = await client.checkHealth();

    if (mounted) {
      setState(() {
        _testing = false;
        _testResult = isHealthy ? 'success' : 'failed';
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                isHealthy ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(isHealthy
                  ? 'Connection successful!'
                  : 'Connection failed - check URL and companion'),
            ],
          ),
          backgroundColor: isHealthy ? Colors.green : Colors.red,
        ),
      );
    }
  }

  void _resetToDefault() {
    setState(() {
      _urlController.text = OfflineSettingsService.defaultCompanionUrl;
    });
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Offline Mode')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Mode'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Offline Mode Toggle
            Card(
              child: SwitchListTile(
                title: const Text('Offline Mode'),
                subtitle: const Text(
                  'Use local companion for STT and LLM when enabled',
                ),
                value: _offlineModeEnabled,
                onChanged: _saveOfflineMode,
                secondary: Icon(
                  _offlineModeEnabled ? Icons.wifi_off : Icons.wifi,
                  color: _offlineModeEnabled ? Colors.orange : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Local Companion URL
            const Text(
              'Local Companion URL',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _urlController,
              decoration: InputDecoration(
                hintText: 'http://192.168.4.1:8787',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Reset to default',
                  onPressed: _resetToDefault,
                ),
              ),
              keyboardType: TextInputType.url,
              onSubmitted: (_) => _saveUrl(),
            ),
            const SizedBox(height: 8),
            Text(
              'Default: ${OfflineSettingsService.defaultCompanionUrl}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),

            // Save URL Button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Save URL'),
                onPressed: _saveUrl,
              ),
            ),
            const SizedBox(height: 24),

            // Test Connection Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: _testing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.network_check),
                label: Text(_testing ? 'Testing...' : 'Test Connection'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                onPressed: _testing ? null : _testConnection,
              ),
            ),
            if (_testResult != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _testResult == 'success'
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _testResult == 'success' ? Colors.green : Colors.red,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _testResult == 'success'
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          _testResult == 'success' ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _testResult == 'success'
                            ? 'Companion is reachable and healthy'
                            : 'Could not reach companion - verify URL and ensure companion is running',
                        style: TextStyle(
                          color: _testResult == 'success'
                              ? Colors.green[800]
                              : Colors.red[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 32),

            // Info Section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About Offline Mode',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'When offline mode is enabled, Zidni will use a local companion device for speech-to-text and AI features instead of cloud services.\n\n'
                    'This is useful at Canton Fair where Wi-Fi may be unreliable.\n\n'
                    'Requirements:\n'
                    '• Local companion device running on the same network\n'
                    '• Companion server started with correct IP and port',
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
