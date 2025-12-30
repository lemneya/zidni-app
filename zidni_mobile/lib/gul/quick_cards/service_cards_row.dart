/// Service Cards Row Widget
/// Gate QT-2: Service Cards + Phrase Sheet (Arabic-first)
///
/// Displays a horizontal row of color-coded service cards.
/// Tapping a card opens the phrase sheet for that service.

import 'package:flutter/material.dart';
import 'phrase_pack_model.dart';

/// Callback when a service card is tapped
typedef OnServiceTapped = void Function(ServiceType service);

/// A horizontal row of service cards with Arabic labels
class ServiceCardsRow extends StatelessWidget {
  final OnServiceTapped onServiceTapped;
  final bool enabled;

  const ServiceCardsRow({
    super.key,
    required this.onServiceTapped,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        // Label: "جُمل جاهزة" (Ready phrases)
        Padding(
          padding: const EdgeInsets.only(right: 16, bottom: 8),
          child: Text(
            'جُمل جاهزة',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: enabled ? Colors.grey[700] : Colors.grey[400],
            ),
          ),
        ),
        // Horizontal scrollable row of service cards
        SizedBox(
          height: 80,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            reverse: true, // RTL: start from right
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: ServiceType.values.length,
            itemBuilder: (context, index) {
              final service = ServiceType.values[index];
              return _ServiceCard(
                service: service,
                enabled: enabled,
                onTap: () => onServiceTapped(service),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// Individual service card widget
class _ServiceCard extends StatelessWidget {
  final ServiceType service;
  final bool enabled;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.service,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Material(
        color: enabled ? service.color : service.color.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  service.icon,
                  style: const TextStyle(fontSize: 24),
                ),
                const SizedBox(height: 4),
                Text(
                  service.arabicLabel,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: enabled ? Colors.white : Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
