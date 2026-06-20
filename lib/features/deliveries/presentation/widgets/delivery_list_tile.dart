import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../domain/entities/delivery.dart';

class DeliveryListTile extends StatelessWidget {
  final Delivery delivery;
  final String customerName;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const DeliveryListTile({
    super.key,
    required this.delivery,
    required this.customerName,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    Color paymentColor;
    String paymentLabel;
    switch (delivery.paymentStatus) {
      case PaymentStatus.paid:
        paymentColor = AppColors.paid;
        paymentLabel = 'PAID';
      case PaymentStatus.partial:
        paymentColor = AppColors.partial;
        paymentLabel = 'PARTIAL';
      case PaymentStatus.unpaid:
        paymentColor = AppColors.unpaid;
        paymentLabel = 'UNPAID';
    }

    Color deliveryColor;
    String deliveryLabel;
    IconData deliveryIcon;
    switch (delivery.deliveryStatus) {
      case DeliveryStatus.scheduled:
        deliveryColor = Colors.blue;
        deliveryLabel = 'Scheduled';
        deliveryIcon = Icons.schedule;
      case DeliveryStatus.inProgress:
        deliveryColor = Colors.orange;
        deliveryLabel = 'In Progress';
        deliveryIcon = Icons.local_shipping_outlined;
      case DeliveryStatus.completed:
        deliveryColor = Colors.green;
        deliveryLabel = 'Completed';
        deliveryIcon = Icons.check_circle_outline;
      case DeliveryStatus.cancelled:
        deliveryColor = Colors.grey;
        deliveryLabel = 'Cancelled';
        deliveryIcon = Icons.cancel_outlined;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.person_outline,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    customerName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                _StatusBadge(label: paymentLabel, color: paymentColor),
                if (onEdit != null || onDelete != null)
                  PopupMenuButton<String>(
                    onSelected: (action) {
                      if (action == 'edit') onEdit?.call();
                      if (action == 'delete') onDelete?.call();
                    },
                    itemBuilder: (_) => [
                      if (onEdit != null)
                        const PopupMenuItem(
                          value: 'edit',
                          child: Text('Edit'),
                        ),
                      if (onDelete != null)
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 6),

            // Delivery status + date/time — wraps on narrow screens
            Wrap(
              spacing: 8,
              runSpacing: 4,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: deliveryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: deliveryColor.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(deliveryIcon, size: 12, color: deliveryColor),
                      const SizedBox(width: 4),
                      Text(
                        deliveryLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: deliveryColor,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 12,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      DateFormatter.format(delivery.deliveryDate),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (delivery.deliveryTime != null) ...[
                      const SizedBox(width: 6),
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        delivery.deliveryTime!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                _InfoChip(
                  icon: Icons.water_drop_outlined,
                  label: '${delivery.quantity} bottles',
                ),
                _InfoChip(
                  icon: Icons.payments_outlined,
                  label:
                      '${CurrencyFormatter.format(delivery.pricePerBottle)}/bottle',
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Total: ${CurrencyFormatter.format(delivery.totalAmount)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (delivery.paymentStatus != PaymentStatus.paid)
                  Flexible(
                    child: Text(
                      'Balance: ${CurrencyFormatter.format(delivery.remainingBalance)}',
                      style: TextStyle(
                        fontSize: 13,
                        color: paymentColor,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.end,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusBadge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 3),
        Flexible(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
