import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/responsive.dart';
import '../../domain/entities/customer.dart';

class CustomerStatsRow extends StatelessWidget {
  final CustomerStats stats;

  const CustomerStatsRow({super.key, required this.stats});

  @override
  Widget build(BuildContext context) {
    return ResponsiveStatGrid(
      spacing: 8,
      children: [
        _StatBox(
          label: 'Bottles Held',
          value: '${stats.bottlesHeld}',
          icon: Icons.inventory_2_outlined,
          color: AppColors.primary,
        ),
        _StatBox(
          label: 'Delivered',
          value: '${stats.borrowedBottles}',
          icon: Icons.local_shipping_outlined,
          color: AppColors.warning,
        ),
        _StatBox(
          label: 'Collected',
          value: '${stats.returnedBottles}',
          icon: Icons.arrow_downward,
          color: AppColors.success,
        ),
        _StatBox(
          label: 'Unpaid Balance',
          value: CurrencyFormatter.format(stats.unpaidBalance),
          icon: Icons.account_balance_wallet_outlined,
          color: stats.unpaidBalance > 0 ? AppColors.error : AppColors.success,
        ),
      ],
    );
  }
}

class _StatBox extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatBox({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final labelSize = context.scaledFontSize(12);
    final valueSize = context.scaledFontSize(18);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: labelSize,
                    color: color.withValues(alpha: 0.9),
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: valueSize,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
