import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/currency_formatter.dart';
import '../../../../core/utils/deposit_calculator.dart';
import '../../../../core/utils/payment_status_utils.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../../customers/domain/entities/customer.dart';
import '../../../customers/presentation/providers/customers_provider.dart';
import '../../../deposits/domain/entities/customer_deposit.dart';
import '../../../deposits/presentation/providers/deposits_provider.dart';
import '../../domain/entities/delivery.dart';
import '../providers/deliveries_provider.dart';
import '../widgets/payment_mode_selector.dart';

class AddDeliveryScreen extends ConsumerStatefulWidget {
  final String? preselectedCustomerId;
  final String? deliveryId;

  const AddDeliveryScreen({
    super.key,
    this.preselectedCustomerId,
    this.deliveryId,
  });

  @override
  ConsumerState<AddDeliveryScreen> createState() => _AddDeliveryScreenState();
}

class _AddDeliveryScreenState extends ConsumerState<AddDeliveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl = TextEditingController(text: '1');
  final _priceCtrl = TextEditingController(
    text: AppConstants.defaultPricePerBottle.toStringAsFixed(2),
  );
  final _amountPaidCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  Customer? _selectedCustomer;
  PaymentStatus _paymentStatus = PaymentStatus.unpaid;
  DeliveryStatus _deliveryStatus = DeliveryStatus.scheduled;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = const TimeOfDay(hour: 9, minute: 0);
  bool _isLoading = false;
  bool _isEditMode = false;
  bool _applyDeposit = false;
  double _availableDeposit = 0;
  String? _editDeliveryId;

  double get _quantity => double.tryParse(_quantityCtrl.text) ?? 0;
  double get _price => double.tryParse(_priceCtrl.text) ?? 0;
  double get _total => _quantity * _price;
  double get _cashReceived => double.tryParse(_amountPaidCtrl.text) ?? 0;
  double get _depositApplied => DepositCalculator.depositToApply(
        availableDeposit: _availableDeposit,
        totalAmount: _total,
        applyDeposit: _applyDeposit,
      );
  double get _amountDue => DepositCalculator.amountDue(
        totalAmount: _total,
        depositApplied: _depositApplied,
      );
  double get _cashApplied => DepositCalculator.cashAppliedToDelivery(
        cashPaid: _cashReceived,
        amountDue: _amountDue,
      );
  double get _remainingDeposit => DepositCalculator.remainingDepositAfterUse(
        availableDeposit: _availableDeposit,
        depositApplied: _depositApplied,
      );
  double get _remainingBalance => DepositCalculator.remainingBalance(
        totalAmount: _total,
        depositApplied: _depositApplied,
        cashPaid: _cashApplied,
      );
  double get _excessDeposit => DepositCalculator.excessPayment(
        cashPaid: _cashReceived,
        amountDue: _amountDue,
      );

  @override
  void initState() {
    super.initState();
    _quantityCtrl.addListener(_recalculate);
    _priceCtrl.addListener(_recalculate);
    if (widget.deliveryId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadDelivery(widget.deliveryId!);
      });
    }
  }

  Future<void> _loadDelivery(String id) async {
    setState(() => _isLoading = true);
    try {
      final delivery =
          await ref.read(deliveryRepositoryProvider).getById(id);
      if (delivery == null || !mounted) return;

      final customers =
          await ref.read(customerRepositoryProvider).getAll();
      Customer? matched;
      for (final c in customers) {
        if (c.id == delivery.customerId) {
          matched = c;
          break;
        }
      }
      _editDeliveryId = id;
      _isEditMode = true;
      _selectedCustomer = matched;
      _quantityCtrl.text = delivery.quantity.toString();
      _priceCtrl.text = delivery.pricePerBottle.toStringAsFixed(2);
      _paymentStatus = delivery.paymentStatus;
      _deliveryStatus = delivery.deliveryStatus;
      _selectedDate = delivery.deliveryDate;
      if (delivery.deliveryTime != null) {
        _selectedTime = _parseTime(delivery.deliveryTime!);
      }
      _amountPaidCtrl.text =
          delivery.amountPaid > 0 ? delivery.amountPaid.toString() : '';
      _notesCtrl.text = delivery.notes ?? '';

      final depositRows = await ref
          .read(customerDepositRepositoryProvider)
          .getByCustomer(delivery.customerId);
      var excess = 0.0;
      for (final row in depositRows) {
        if (row.deliveryId == id &&
            row.transactionType == DepositTransactionType.depositAdded) {
          excess += row.amount;
        }
      }
      if (excess > 0 || delivery.amountPaid > 0) {
        _amountPaidCtrl.text = (delivery.amountPaid + excess).toStringAsFixed(2);
      }
      _applyDeposit = delivery.depositApplied > 0;
      _availableDeposit = await ref
          .read(customerDepositRepositoryProvider)
          .getAvailableForDelivery(
            delivery.customerId,
            excludeDeliveryId: id,
          );
      if (_applyDeposit) {
        _availableDeposit += delivery.depositApplied;
      }
      setState(() {});
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  TimeOfDay _parseTime(String time) {
    try {
      final parts = time.split(' ');
      final hm = parts[0].split(':');
      var hour = int.parse(hm[0]);
      final minute = int.parse(hm[1]);
      if (parts.length > 1) {
        final period = parts[1].toUpperCase();
        if (period == 'PM' && hour < 12) hour += 12;
        if (period == 'AM' && hour == 12) hour = 0;
      }
      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _priceCtrl.dispose();
    _amountPaidCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  void _recalculate() => setState(() {});

  Future<void> _loadDepositForCustomer(Customer customer) async {
    final available = await ref
        .read(customerDepositRepositoryProvider)
        .getAvailableForDelivery(
          customer.id,
          excludeDeliveryId: _editDeliveryId,
        );
    if (!mounted) return;
    setState(() {
      _availableDeposit = available;
      if (!_applyDeposit && _availableDeposit <= 0) {
        _applyDeposit = false;
      }
    });
  }

  void _onPaymentModeChanged(PaymentStatus status) {
    setState(() {
      _paymentStatus = status;
      if (status == PaymentStatus.paid) {
        _amountPaidCtrl.text = _amountDue.toStringAsFixed(2);
      } else if (status == PaymentStatus.unpaid) {
        _amountPaidCtrl.clear();
      }
    });
  }

  void _onCustomerChanged(Customer? customer) {
    setState(() {
      _selectedCustomer = customer;
      _applyDeposit = false;
      _availableDeposit = 0;
    });
    if (customer != null) {
      _loadDepositForCustomer(customer);
    }
  }

  String get _formattedDate =>
      DateFormat('MMMM d, yyyy').format(_selectedDate);

  String get _formattedTime => _selectedTime.format(context);

  String get _deliveryTimeString {
    final hour = _selectedTime.hourOfPeriod == 0
        ? 12
        : _selectedTime.hourOfPeriod;
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    final period = _selectedTime.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCustomer == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a customer')),
      );
      return;
    }
    setState(() => _isLoading = true);

    try {
      final qty = int.parse(_quantityCtrl.text.trim());
      final price = double.parse(_priceCtrl.text.trim());
      final total = qty * price;
      final depositApplied = DepositCalculator.depositToApply(
        availableDeposit: _availableDeposit,
        totalAmount: total,
        applyDeposit: _applyDeposit,
      );
      final amountDue = total - depositApplied;

      double cashReceived = 0;
      switch (_paymentStatus) {
        case PaymentStatus.paid:
          cashReceived = _cashReceived > 0 ? _cashReceived : amountDue;
        case PaymentStatus.unpaid:
          cashReceived = 0;
        case PaymentStatus.partial:
          cashReceived = _cashReceived;
      }

      final cashApplied = DepositCalculator.cashAppliedToDelivery(
        cashPaid: cashReceived,
        amountDue: amountDue,
      );
      final balance = PaymentStatusUtils.computeRemainingBalance(
        totalAmount: total,
        amountPaid: cashApplied,
        depositApplied: depositApplied,
      );
      final statusStr = PaymentStatusUtils.computeStatus(
        totalAmount: total,
        amountPaid: cashApplied,
        depositApplied: depositApplied,
      );
      final status = Delivery.paymentStatusFromString(statusStr);

      final delivery = Delivery(
        id: _editDeliveryId ?? const Uuid().v4(),
        customerId: _selectedCustomer!.id,
        quantity: qty,
        pricePerBottle: price,
        totalAmount: total,
        paymentStatus: status,
        amountPaid: cashApplied,
        depositApplied: depositApplied,
        remainingBalance: balance,
        deliveryDate: _selectedDate,
        deliveryTime: _deliveryTimeString,
        deliveryStatus: _deliveryStatus,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );

      if (_isEditMode) {
        await ref.read(deliveryRepositoryProvider).updateDelivery(
              delivery,
              cashReceived: cashReceived,
            );
      } else {
        await ref.read(deliveryRepositoryProvider).createDelivery(
              delivery,
              cashReceived: cashReceived,
            );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditMode ? 'Delivery updated!' : 'Delivery scheduled!',
            ),
          ),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final customersAsync = ref.watch(customersStreamProvider);

    // Preselect customer
    if (_selectedCustomer == null && widget.preselectedCustomerId != null) {
      customersAsync.whenData((customers) {
        final match = customers.where(
          (c) => c.id == widget.preselectedCustomerId,
        );
        if (match.isNotEmpty && _selectedCustomer == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _onCustomerChanged(match.first);
          });
        }
      });
    }

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Delivery' : 'New Delivery'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Customer selector
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Customer',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 8),
                    customersAsync.when(
                      data: (customers) => DropdownButtonFormField<Customer>(
                        // ignore: deprecated_member_use
                        value: _selectedCustomer,
                        decoration: const InputDecoration(
                          hintText: 'Select a customer',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        items: customers
                            .map(
                              (c) => DropdownMenuItem(
                                value: c,
                                child: Text(c.name),
                              ),
                            )
                            .toList(),
                        onChanged: _onCustomerChanged,
                        validator: (v) =>
                            v == null ? 'Please select a customer' : null,
                      ),
                      loading: () => const CircularProgressIndicator(),
                      error: (e, _) => Text('Error: $e'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Date and Time
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Schedule',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _PickerButton(
                            icon: Icons.calendar_today_outlined,
                            label: 'Delivery Date',
                            value: _formattedDate,
                            onTap: _pickDate,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _PickerButton(
                            icon: Icons.access_time_outlined,
                            label: 'Time',
                            value: _formattedTime,
                            onTap: _pickTime,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Delivery Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Status',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      children: [
                        _StatusChip(
                          label: 'Scheduled',
                          icon: Icons.schedule,
                          color: Colors.blue,
                          selected:
                              _deliveryStatus == DeliveryStatus.scheduled,
                          onTap: () => setState(
                              () => _deliveryStatus = DeliveryStatus.scheduled),
                        ),
                        _StatusChip(
                          label: 'In Progress',
                          icon: Icons.local_shipping_outlined,
                          color: Colors.orange,
                          selected:
                              _deliveryStatus == DeliveryStatus.inProgress,
                          onTap: () => setState(
                              () =>
                                  _deliveryStatus = DeliveryStatus.inProgress),
                        ),
                        _StatusChip(
                          label: 'Completed',
                          icon: Icons.check_circle_outline,
                          color: Colors.green,
                          selected:
                              _deliveryStatus == DeliveryStatus.completed,
                          onTap: () => setState(
                              () =>
                                  _deliveryStatus = DeliveryStatus.completed),
                        ),
                        _StatusChip(
                          label: 'Cancelled',
                          icon: Icons.cancel_outlined,
                          color: Colors.grey,
                          selected:
                              _deliveryStatus == DeliveryStatus.cancelled,
                          onTap: () => setState(
                              () =>
                                  _deliveryStatus = DeliveryStatus.cancelled),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Quantity and price
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Delivery Details',
                      style: theme.textTheme.titleSmall
                          ?.copyWith(color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: AppTextField(
                            label: 'Quantity *',
                            controller: _quantityCtrl,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            textInputAction: TextInputAction.next,
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final n = int.tryParse(v);
                              if (n == null || n <= 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            label: 'Price per Bottle *',
                            controller: _priceCtrl,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'^\d+\.?\d{0,2}'),
                              ),
                            ],
                            textInputAction: TextInputAction.next,
                            prefixIcon:
                                const Icon(Icons.monetization_on_outlined),
                            validator: (v) {
                              if (v == null || v.isEmpty) return 'Required';
                              final n = double.tryParse(v);
                              if (n == null || n <= 0) return 'Invalid';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.06),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Total Amount',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            CurrencyFormatter.format(_total),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Payment mode
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PaymentModeSelector(
                      selectedStatus: _paymentStatus,
                      onChanged: _onPaymentModeChanged,
                    ),
                    if (_selectedCustomer != null) ...[
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Deposit Available (Pundo)',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ),
                          Text(
                            CurrencyFormatter.format(_availableDeposit),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1976D2),
                            ),
                          ),
                        ],
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Apply Deposit'),
                        subtitle: _applyDeposit && _depositApplied > 0
                            ? Text(
                                'Using ${CurrencyFormatter.format(_depositApplied)}',
                              )
                            : null,
                        value: _applyDeposit,
                        onChanged: _availableDeposit > 0
                            ? (v) {
                                setState(() {
                                  _applyDeposit = v;
                                  if (_paymentStatus == PaymentStatus.paid) {
                                    _amountPaidCtrl.text =
                                        _amountDue.toStringAsFixed(2);
                                  }
                                });
                              }
                            : null,
                      ),
                    ],
                    if (_paymentStatus != PaymentStatus.unpaid) ...[
                      const SizedBox(height: 8),
                      AppTextField(
                        label: 'Amount Paid',
                        controller: _amountPaidCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        prefixIcon: const Icon(Icons.payments_outlined),
                        onChanged: (_) => setState(() {}),
                        validator: (v) {
                          if (_paymentStatus == PaymentStatus.unpaid) {
                            return null;
                          }
                          if (v == null || v.isEmpty) return 'Required';
                          final n = double.tryParse(v);
                          if (n == null || n < 0) return 'Invalid amount';
                          return null;
                        },
                      ),
                    ],
                    if (_total > 0) ...[
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.06),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Delivery Total',
                              value: CurrencyFormatter.format(_total),
                            ),
                            if (_depositApplied > 0)
                              _SummaryRow(
                                label: 'Deposit Applied',
                                value: CurrencyFormatter.format(_depositApplied),
                                valueColor: const Color(0xFF2E7D32),
                              ),
                            _SummaryRow(
                              label: 'Amount Due',
                              value: CurrencyFormatter.format(_amountDue),
                            ),
                            if (_paymentStatus != PaymentStatus.unpaid)
                              _SummaryRow(
                                label: 'Amount Paid',
                                value: CurrencyFormatter.format(_cashApplied),
                              ),
                            if (_excessDeposit > 0)
                              _SummaryRow(
                                label: 'New Deposit (Pundo)',
                                value: CurrencyFormatter.format(_excessDeposit),
                                valueColor: const Color(0xFF1565C0),
                              ),
                            _SummaryRow(
                              label: 'Remaining Balance',
                              value: CurrencyFormatter.format(_remainingBalance),
                              valueColor: _remainingBalance > 0
                                  ? const Color(0xFFF57F17)
                                  : const Color(0xFF2E7D32),
                            ),
                            _SummaryRow(
                              label: 'Remaining Deposit',
                              value: CurrencyFormatter.format(_remainingDeposit),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Notes
            AppTextField(
              label: 'Notes (Optional)',
              controller: _notesCtrl,
              maxLines: 2,
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: _isLoading ? null : _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 56),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Update Delivery' : 'Save Delivery',
                      style: const TextStyle(fontSize: 17),
                    ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _SummaryRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _PickerButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _PickerButton({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(icon, size: 16, color: const Color(0xFF1976D2)),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
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

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.12) : Colors.grey[100],
          border: Border.all(
            color: selected ? color : Colors.grey[300]!,
            width: selected ? 1.5 : 1,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: selected ? color : Colors.grey[500]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.normal,
                color: selected ? color : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
