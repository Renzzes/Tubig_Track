import 'package:flutter/material.dart';
import '../../domain/entities/delivery.dart';

class PaymentModeSelector extends StatelessWidget {
  final PaymentStatus selectedStatus;
  final ValueChanged<PaymentStatus> onChanged;

  const PaymentModeSelector({
    super.key,
    required this.selectedStatus,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Mode',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: Colors.grey[700],
              ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _ModeButton(
              label: 'Paid',
              icon: Icons.check_circle_outline,
              color: const Color(0xFF2E7D32),
              isSelected: selectedStatus == PaymentStatus.paid,
              onTap: () => onChanged(PaymentStatus.paid),
            ),
            const SizedBox(width: 8),
            _ModeButton(
              label: 'Unpaid',
              icon: Icons.cancel_outlined,
              color: const Color(0xFFC62828),
              isSelected: selectedStatus == PaymentStatus.unpaid,
              onTap: () => onChanged(PaymentStatus.unpaid),
            ),
            const SizedBox(width: 8),
            _ModeButton(
              label: 'Partial',
              icon: Icons.timelapse,
              color: const Color(0xFFF57F17),
              isSelected: selectedStatus == PaymentStatus.partial,
              onTap: () => onChanged(PaymentStatus.partial),
            ),
          ],
        ),
      ],
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? color.withValues(alpha: 0.15) : Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey[300]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : Colors.grey[500],
                size: 22,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight:
                      isSelected ? FontWeight.w700 : FontWeight.normal,
                  color: isSelected ? color : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
