import 'package:flutter/material.dart';

class VipScreen extends StatelessWidget {
  const VipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('VIP Подписка'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF212121),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // VIP Banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1565C0),
                  Color(0xFF42A5F5),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                const Icon(Icons.workspace_premium, color: Colors.amber, size: 48),
                const SizedBox(height: 12),
                const Text(
                  'EuroRent AI Premium',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '1500 Stars (~15 EUR/мес)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Ежедневная подборка объявлений\nпо вашим критериям',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Section: What's included
          _SectionTitle(title: 'Что входит'),

          _FeatureItem(
            icon: Icons.check_circle,
            title: 'До 10 объявлений в день',
            subtitle: 'Проверенные подборки каждый день',
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'Безлимитные проверки',
            subtitle: 'Анализируйте сколько угодно объявлений',
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'Фильтр по городу и цене',
            subtitle: 'Только то, что вам подходит',
          ),
          const SizedBox(height: 12),
          _FeatureItem(
            icon: Icons.check_circle,
            title: 'Предупреждения о мошенниках',
            subtitle: 'Бот проверяет риски каждого объявления',
          ),

          const SizedBox(height: 24),

          // Section: How it works
          _SectionTitle(title: 'Как это работает'),

          _StepItem(
            number: '1',
            title: 'Оплатите подписку',
            subtitle: '1500 Stars через Telegram (~15 EUR)',
          ),
          const SizedBox(height: 12),
          _StepItem(
            number: '2',
            title: 'Отправьте критерии',
            subtitle: 'Город, макс. цена, мин. площадь, комнаты',
          ),
          const SizedBox(height: 12),
          _StepItem(
            number: '3',
            title: 'Получайте подборки',
            subtitle: 'До 10 проверенных объявлений каждый день',
          ),

          const SizedBox(height: 24),

          // Section: Search criteria example
          _SectionTitle(title: 'Пример критериев'),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _CriteriaRow(label: 'Город', value: 'Берлин'),
                  _CriteriaRow(label: 'Макс. цена', value: '800 EUR/мес'),
                  _CriteriaRow(label: 'Мин. площадь', value: '40 м²'),
                  _CriteriaRow(label: 'Комнаты', value: '2'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Section: Payment methods
          _SectionTitle(title: 'Способы оплаты'),

          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _PaymentMethod(
                    icon: Icons.star,
                    name: 'Telegram Stars',
                    amount: '1500 Stars (~15 EUR)',
                  ),
                  const Divider(height: 24),
                  _PaymentMethod(
                    icon: Icons.account_balance_wallet,
                    name: 'Баланс бота',
                    amount: 'Пополните через /pay',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Subscribe button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Для оплаты откройте бот @expat_rent_bot в Telegram\n'
                      'и используйте команду /pay_stars_vip',
                    ),
                    duration: Duration(seconds: 4),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Подключить VIP',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Note
          Text(
            'Оплата через Telegram Stars в боте @expat_rent_bot.\n'
            'После оплаты отправьте критерии поиска боту.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF4CAF50), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StepItem extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;

  const _StepItem({
    required this.number,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: const Color(0xFF1E88E5),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF212121),
                ),
              ),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF9E9E9E),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CriteriaRow extends StatelessWidget {
  final String label;
  final String value;

  const _CriteriaRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethod extends StatelessWidget {
  final IconData icon;
  final String name;
  final String amount;

  const _PaymentMethod({
    required this.icon,
    required this.name,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF1E88E5), size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
