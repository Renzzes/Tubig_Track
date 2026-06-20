import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../domain/entities/supplier.dart';
import '../providers/suppliers_provider.dart';

class SupplierFormScreen extends ConsumerStatefulWidget {
  final String? supplierId;

  const SupplierFormScreen({super.key, this.supplierId});

  @override
  ConsumerState<SupplierFormScreen> createState() =>
      _SupplierFormScreenState();
}

class _SupplierFormScreenState extends ConsumerState<SupplierFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.supplierId != null) _load();
  }

  Future<void> _load() async {
    final s = await ref
        .read(supplierRepositoryProvider)
        .getById(widget.supplierId!);
    if (s == null || !mounted) return;
    _nameCtrl.text = s.name;
    _contactCtrl.text = s.contactPerson ?? '';
    _mobileCtrl.text = s.mobile ?? '';
    _addressCtrl.text = s.address ?? '';
    _notesCtrl.text = s.notes ?? '';
    setState(() {});
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _contactCtrl.dispose();
    _mobileCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    try {
      final supplier = Supplier(
        id: widget.supplierId ?? const Uuid().v4(),
        name: _nameCtrl.text.trim(),
        contactPerson: _contactCtrl.text.trim().isEmpty
            ? null
            : _contactCtrl.text.trim(),
        mobile:
            _mobileCtrl.text.trim().isEmpty ? null : _mobileCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty
            ? null
            : _addressCtrl.text.trim(),
        notes:
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        createdAt: DateTime.now(),
      );
      final repo = ref.read(supplierRepositoryProvider);
      if (widget.supplierId != null) {
        await repo.updateSupplier(supplier);
      } else {
        await repo.addSupplier(supplier);
      }
      if (mounted) context.pop(true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.supplierId != null;
    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Supplier' : 'Add Supplier')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            AppTextField(
              label: 'Supplier Name *',
              controller: _nameCtrl,
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Contact Person', controller: _contactCtrl),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Mobile Number',
              controller: _mobileCtrl,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            AppTextField(label: 'Address', controller: _addressCtrl),
            const SizedBox(height: 16),
            AppTextField(
              label: 'Notes',
              controller: _notesCtrl,
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _loading ? null : _save,
              style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(48)),
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEdit ? 'Save Changes' : 'Add Supplier'),
            ),
          ],
        ),
      ),
    );
  }
}
