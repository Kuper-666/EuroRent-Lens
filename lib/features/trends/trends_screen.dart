import 'package:flutter/material.dart';

class TrendsScreen extends StatelessWidget {
  const TrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Тренды цен'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // City cards
          _CityTrend(
            city: 'Berlin',
            country: 'Германия',
            avgPrice: '850 €',
            change: '+5.2%',
            isUp: true,
          ),
          const SizedBox(height: 12),
          _CityTrend(
            city: 'München',
            country: 'Германия',
            avgPrice: '1 200 €',
            change: '+3.1%',
            isUp: true,
          ),
          const SizedBox(height: 12),
          _CityTrend(
            city: 'Hamburg',
            country: 'Германия',
            avgPrice: '780 €',
            change: '-2.4%',
            isUp: false,
          ),
          const SizedBox(height: 12),
          _CityTrend(
            city: 'Köln',
            country: 'Германия',
            avgPrice: '720 €',
            change: '+1.8%',
            isUp: true,
          ),
          const SizedBox(height: 12),
          _CityTrend(
            city: 'Wien',
            country: 'Австрия',
            avgPrice: '950 €',
            change: '+4.5%',
            isUp: true,
          ),
        ],
      ),
    );
  }
}

class _CityTrend extends StatelessWidget {
  final String city;
  final String country;
  final String avgPrice;
  final String change;
  final bool isUp;

  const _CityTrend({
    required this.city,
    required this.country,
    required this.avgPrice,
    required this.change,
    required this.isUp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.location_city,
                color: Color(0xFF1E88E5),
                size: 24,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    city,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF212121),
                    ),
                  ),
                  Text(
                    country,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF9E9E9E),
                    ),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  avgPrice,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212121),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isUp ? Icons.arrow_upward : Icons.arrow_downward,
                      size: 14,
                      color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                    ),
                    Text(
                      change,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isUp ? const Color(0xFF4CAF50) : const Color(0xFFF44336),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
