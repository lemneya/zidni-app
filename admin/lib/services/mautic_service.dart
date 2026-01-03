import 'dart:convert';
import 'package:http/http.dart' as http;

/// Mautic Marketing Automation Service
/// Handles all communication with Mautic REST API
class MauticService {
  static final MauticService _instance = MauticService._internal();
  factory MauticService() => _instance;
  MauticService._internal();

  // Configuration - Replace with your Mautic instance details
  static const String _baseUrl = 'https://your-mautic-instance.com';
  static const String _apiUser = 'api_user';
  static const String _apiPassword = 'api_password';

  String get _authHeader {
    final credentials = base64Encode(utf8.encode('$_apiUser:$_apiPassword'));
    return 'Basic $credentials';
  }

  Map<String, String> get _headers => {
    'Authorization': _authHeader,
    'Content-Type': 'application/json',
  };

  // ============ CONTACTS ============

  /// Create a new contact in Mautic
  Future<Map<String, dynamic>?> createContact({
    required String email,
    String? firstName,
    String? lastName,
    String? language,
    Map<String, dynamic>? customFields,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/contacts/new'),
        headers: _headers,
        body: jsonEncode({
          'email': email,
          'firstname': firstName,
          'lastname': lastName,
          'preferred_locale': language ?? 'ar',
          ...?customFields,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error creating Mautic contact: $e');
      return null;
    }
  }

  /// Get contact by email
  Future<Map<String, dynamic>?> getContactByEmail(String email) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/contacts?search=email:$email'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contacts = data['contacts'] as Map<String, dynamic>?;
        if (contacts != null && contacts.isNotEmpty) {
          return contacts.values.first;
        }
      }
      return null;
    } catch (e) {
      print('Error getting Mautic contact: $e');
      return null;
    }
  }

  /// Update contact
  Future<bool> updateContact(int contactId, Map<String, dynamic> data) async {
    try {
      final response = await http.patch(
        Uri.parse('$_baseUrl/api/contacts/$contactId/edit'),
        headers: _headers,
        body: jsonEncode(data),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error updating Mautic contact: $e');
      return false;
    }
  }

  /// Get all contacts with pagination
  Future<List<Map<String, dynamic>>> getContacts({
    int start = 0,
    int limit = 50,
    String? search,
  }) async {
    try {
      String url = '$_baseUrl/api/contacts?start=$start&limit=$limit';
      if (search != null) {
        url += '&search=$search';
      }

      final response = await http.get(Uri.parse(url), headers: _headers);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final contacts = data['contacts'] as Map<String, dynamic>?;
        return contacts?.values.cast<Map<String, dynamic>>().toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting Mautic contacts: $e');
      return [];
    }
  }

  /// Get contact count
  Future<int> getContactCount() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/contacts?limit=1'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['total'] ?? 0;
      }
      return 0;
    } catch (e) {
      print('Error getting Mautic contact count: $e');
      return 0;
    }
  }

  // ============ SEGMENTS ============

  /// Get all segments
  Future<List<Map<String, dynamic>>> getSegments() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/segments'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final lists = data['lists'] as Map<String, dynamic>?;
        return lists?.values.cast<Map<String, dynamic>>().toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting Mautic segments: $e');
      return [];
    }
  }

  /// Add contact to segment
  Future<bool> addContactToSegment(int contactId, int segmentId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/segments/$segmentId/contact/$contactId/add'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error adding contact to segment: $e');
      return false;
    }
  }

  // ============ CAMPAIGNS ============

  /// Get all campaigns
  Future<List<Map<String, dynamic>>> getCampaigns() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/campaigns'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final campaigns = data['campaigns'] as Map<String, dynamic>?;
        return campaigns?.values.cast<Map<String, dynamic>>().toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting Mautic campaigns: $e');
      return [];
    }
  }

  /// Get campaign statistics
  Future<Map<String, dynamic>?> getCampaignStats(int campaignId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/campaigns/$campaignId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting campaign stats: $e');
      return null;
    }
  }

  // ============ EMAILS ============

  /// Get all emails
  Future<List<Map<String, dynamic>>> getEmails() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/emails'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final emails = data['emails'] as Map<String, dynamic>?;
        return emails?.values.cast<Map<String, dynamic>>().toList() ?? [];
      }
      return [];
    } catch (e) {
      print('Error getting Mautic emails: $e');
      return [];
    }
  }

  /// Send email to contact
  Future<bool> sendEmailToContact(int emailId, int contactId) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/emails/$emailId/contact/$contactId/send'),
        headers: _headers,
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error sending email: $e');
      return false;
    }
  }

  /// Get email statistics
  Future<Map<String, dynamic>?> getEmailStats(int emailId) async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/api/emails/$emailId'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (e) {
      print('Error getting email stats: $e');
      return null;
    }
  }

  // ============ ANALYTICS ============

  /// Get dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    try {
      // Get various stats
      final contactCount = await getContactCount();
      final campaigns = await getCampaigns();
      final emails = await getEmails();
      final segments = await getSegments();

      // Calculate active campaigns
      final activeCampaigns = campaigns.where((c) => c['isPublished'] == true).length;

      return {
        'totalContacts': contactCount,
        'totalCampaigns': campaigns.length,
        'activeCampaigns': activeCampaigns,
        'totalEmails': emails.length,
        'totalSegments': segments.length,
      };
    } catch (e) {
      print('Error getting dashboard stats: $e');
      return {
        'totalContacts': 0,
        'totalCampaigns': 0,
        'activeCampaigns': 0,
        'totalEmails': 0,
        'totalSegments': 0,
      };
    }
  }

  // ============ PUSH NOTIFICATIONS ============

  /// Trigger push notification via webhook
  /// This connects to your Firebase Cloud Function
  Future<bool> triggerPushNotification({
    required String title,
    required String body,
    List<int>? contactIds,
    int? segmentId,
    Map<String, dynamic>? data,
  }) async {
    try {
      // This would call your Firebase Cloud Function
      // that handles the actual push sending via FCM
      final response = await http.post(
        Uri.parse('YOUR_CLOUD_FUNCTION_URL/sendPush'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': title,
          'body': body,
          'contactIds': contactIds,
          'segmentId': segmentId,
          'data': data,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      print('Error triggering push notification: $e');
      return false;
    }
  }
}
