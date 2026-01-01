import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:zidni_mobile/billing/services/entitlement_service.dart';
import 'package:zidni_mobile/billing/widgets/soft_upgrade_modal.dart';
import 'package:zidni_mobile/usage/services/usage_meter_service.dart';
import 'package:zidni_mobile/usage/models/usage_record.dart';

/// Upgrade Trigger Service
/// Gate BILL-1: Entitlements + Usage Meter + Paywall
///
/// Monitors user behavior and triggers soft upgrade suggestions

class UpgradeTriggerService {
  static const String _storageKey = 'zidni_upgrade_triggers';
  
  // Trigger thresholds
  static const int _dealsPerWeekThreshold = 5;
  static const int _searchesPerWeekThreshold = 10;
  
  // Cooldown between showing modals (in hours)
  static const int _modalCooldownHours = 24;
  
  // ============================================
  // Check triggers
  // ============================================
  
  /// Check if any trigger condition is met and show modal if appropriate
  static Future<void> checkAndShowIfNeeded(BuildContext context) async {
    // Don't show to business users
    if (await EntitlementService.isBusiness()) {
      return;
    }
    
    // Check cooldown
    if (await _isInCooldown()) {
      return;
    }
    
    // Check triggers in priority order
    final trigger = await _getActiveTrigger();
    
    if (trigger != null && context.mounted) {
      await _recordModalShown(trigger);
      await SoftUpgradeModal.show(
        context,
        trigger: trigger,
        onDismiss: () => _recordDismissed(trigger),
        onUpgrade: () => _recordUpgradeClicked(trigger),
      );
    }
  }
  
  /// Get the active trigger (if any)
  static Future<UpgradeTrigger?> _getActiveTrigger() async {
    // Check deals threshold
    final dealsThisWeek = await UsageMeterService.getWeekCount(UsageType.dealsCreated);
    if (dealsThisWeek >= _dealsPerWeekThreshold) {
      if (!await _wasTriggerShownRecently(UpgradeTrigger.manyDeals)) {
        return UpgradeTrigger.manyDeals;
      }
    }
    
    // Check searches threshold
    final searchesThisWeek = await UsageMeterService.getWeekCount(UsageType.eyesSearches);
    if (searchesThisWeek >= _searchesPerWeekThreshold) {
      if (!await _wasTriggerShownRecently(UpgradeTrigger.frequentSearches)) {
        return UpgradeTrigger.frequentSearches;
      }
    }
    
    return null;
  }
  
  /// Manually trigger an upgrade modal (e.g., when user hits a gated feature)
  static Future<void> triggerForFeature(
    BuildContext context, 
    UpgradeTrigger trigger,
  ) async {
    // Don't show to business users
    if (await EntitlementService.isBusiness()) {
      return;
    }
    
    if (context.mounted) {
      await _recordModalShown(trigger);
      await SoftUpgradeModal.show(
        context,
        trigger: trigger,
        onDismiss: () => _recordDismissed(trigger),
        onUpgrade: () => _recordUpgradeClicked(trigger),
      );
    }
  }
  
  /// Trigger for export attempt (gated feature)
  static Future<void> triggerForExport(BuildContext context) async {
    await triggerForFeature(context, UpgradeTrigger.exportAttempt);
  }
  
  /// Trigger for daily limit reached
  static Future<void> triggerForDailyLimit(BuildContext context) async {
    await triggerForFeature(context, UpgradeTrigger.dailyLimitReached);
  }
  
  // ============================================
  // Cooldown and tracking
  // ============================================
  
  static Future<bool> _isInCooldown() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    
    if (json == null) return false;
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final lastShown = data['lastModalShown'] as String?;
      
      if (lastShown != null) {
        final lastShownTime = DateTime.parse(lastShown);
        final hoursSince = DateTime.now().difference(lastShownTime).inHours;
        return hoursSince < _modalCooldownHours;
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    return false;
  }
  
  static Future<bool> _wasTriggerShownRecently(UpgradeTrigger trigger) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    
    if (json == null) return false;
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      final triggers = data['triggerHistory'] as Map<String, dynamic>? ?? {};
      final lastShown = triggers[trigger.name] as String?;
      
      if (lastShown != null) {
        final lastShownTime = DateTime.parse(lastShown);
        final daysSince = DateTime.now().difference(lastShownTime).inDays;
        return daysSince < 7; // Don't show same trigger more than once per week
      }
    } catch (e) {
      // Ignore parsing errors
    }
    
    return false;
  }
  
  static Future<void> _recordModalShown(UpgradeTrigger trigger) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    
    Map<String, dynamic> data = {};
    if (json != null) {
      try {
        data = jsonDecode(json) as Map<String, dynamic>;
      } catch (e) {
        // Start fresh if parsing fails
      }
    }
    
    data['lastModalShown'] = DateTime.now().toIso8601String();
    
    final triggers = (data['triggerHistory'] as Map<String, dynamic>?) ?? {};
    triggers[trigger.name] = DateTime.now().toIso8601String();
    data['triggerHistory'] = triggers;
    
    // Track total shows
    final showCount = (data['totalShows'] as int?) ?? 0;
    data['totalShows'] = showCount + 1;
    
    await prefs.setString(_storageKey, jsonEncode(data));
    
    _logAuditEvent('upgrade_modal_shown', {
      'trigger': trigger.name,
      'totalShows': data['totalShows'],
    });
  }
  
  static Future<void> _recordDismissed(UpgradeTrigger trigger) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    
    Map<String, dynamic> data = {};
    if (json != null) {
      try {
        data = jsonDecode(json) as Map<String, dynamic>;
      } catch (e) {
        // Start fresh
      }
    }
    
    final dismissCount = (data['totalDismisses'] as int?) ?? 0;
    data['totalDismisses'] = dismissCount + 1;
    
    await prefs.setString(_storageKey, jsonEncode(data));
    
    _logAuditEvent('upgrade_modal_dismissed', {
      'trigger': trigger.name,
      'totalDismisses': data['totalDismisses'],
    });
  }
  
  static Future<void> _recordUpgradeClicked(UpgradeTrigger trigger) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    
    Map<String, dynamic> data = {};
    if (json != null) {
      try {
        data = jsonDecode(json) as Map<String, dynamic>;
      } catch (e) {
        // Start fresh
      }
    }
    
    final clickCount = (data['totalUpgradeClicks'] as int?) ?? 0;
    data['totalUpgradeClicks'] = clickCount + 1;
    
    await prefs.setString(_storageKey, jsonEncode(data));
    
    _logAuditEvent('upgrade_modal_clicked', {
      'trigger': trigger.name,
      'totalClicks': data['totalUpgradeClicks'],
    });
  }
  
  // ============================================
  // Analytics helpers
  // ============================================
  
  /// Get upgrade funnel stats
  static Future<Map<String, int>> getFunnelStats() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_storageKey);
    
    if (json == null) {
      return {
        'totalShows': 0,
        'totalDismisses': 0,
        'totalUpgradeClicks': 0,
      };
    }
    
    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return {
        'totalShows': (data['totalShows'] as int?) ?? 0,
        'totalDismisses': (data['totalDismisses'] as int?) ?? 0,
        'totalUpgradeClicks': (data['totalUpgradeClicks'] as int?) ?? 0,
      };
    } catch (e) {
      return {
        'totalShows': 0,
        'totalDismisses': 0,
        'totalUpgradeClicks': 0,
      };
    }
  }
  
  static void _logAuditEvent(String event, Map<String, dynamic> data) {
    // TODO: Integrate with analytics in future
    print('[UpgradeTriggerService] $event: $data');
  }
  
  // ============================================
  // Testing helpers
  // ============================================
  
  /// Clear all trigger data (for testing)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
  
  /// Force show a trigger (for testing)
  static Future<void> forceShowTrigger(
    BuildContext context, 
    UpgradeTrigger trigger,
  ) async {
    if (context.mounted) {
      await SoftUpgradeModal.show(context, trigger: trigger);
    }
  }
}
