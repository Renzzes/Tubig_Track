import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  static const _features = [
    'Customer Management',
    'Delivery Scheduling',
    'Inventory Tracking',
    'Borrowed Bottle Monitoring',
    'Payment Collection',
    'Expense Tracking',
    'Dispenser Sales',
    'Reports',
    'Backup & Restore',
    'Notifications',
    'Self Update System',
    'Savings Monitoring',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Center(
            child: Column(
              children: [
                Icon(
                  Icons.water_drop,
                  size: 64,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(height: 12),
                Text(
                  AppConstants.appName,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Version ${AppConstants.appVersion}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'Local-first Mineral Water Distribution Management System',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 24),
          Text(
            'Features',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          ..._features.map(
            (f) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  '),
                  Expanded(child: Text(f)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 16),
          Text(
            'Developer',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          const Text('Clarence Emmanuel Jamora'),
          const SizedBox(height: 24),
          Center(
            child: Text(
              '© 2026 TubigTrack',
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
