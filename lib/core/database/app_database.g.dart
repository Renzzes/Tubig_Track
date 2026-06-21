// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CustomersTableTable extends CustomersTable
    with TableInfo<$CustomersTableTable, CustomersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phoneMeta = const VerificationMeta('phone');
  @override
  late final GeneratedColumn<String> phone = GeneratedColumn<String>(
    'phone',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _pendingPhysicalBottleCountMeta =
      const VerificationMeta('pendingPhysicalBottleCount');
  @override
  late final GeneratedColumn<int> pendingPhysicalBottleCount =
      GeneratedColumn<int>(
        'pending_physical_bottle_count',
        aliasedName,
        true,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _customerOwnedBottlesHeldMeta =
      const VerificationMeta('customerOwnedBottlesHeld');
  @override
  late final GeneratedColumn<int> customerOwnedBottlesHeld =
      GeneratedColumn<int>(
        'customer_owned_bottles_held',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _lastPhysicalCountDateMeta =
      const VerificationMeta('lastPhysicalCountDate');
  @override
  late final GeneratedColumn<DateTime> lastPhysicalCountDate =
      GeneratedColumn<DateTime>(
        'last_physical_count_date',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastPhysicalCountVerifiedMeta =
      const VerificationMeta('lastPhysicalCountVerified');
  @override
  late final GeneratedColumn<bool> lastPhysicalCountVerified =
      GeneratedColumn<bool>(
        'last_physical_count_verified',
        aliasedName,
        false,
        type: DriftSqlType.bool,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("last_physical_count_verified" IN (0, 1))',
        ),
        defaultValue: const Constant(false),
      );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    phone,
    address,
    notes,
    pendingPhysicalBottleCount,
    customerOwnedBottlesHeld,
    lastPhysicalCountDate,
    lastPhysicalCountVerified,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customers';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('phone')) {
      context.handle(
        _phoneMeta,
        phone.isAcceptableOrUnknown(data['phone']!, _phoneMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('pending_physical_bottle_count')) {
      context.handle(
        _pendingPhysicalBottleCountMeta,
        pendingPhysicalBottleCount.isAcceptableOrUnknown(
          data['pending_physical_bottle_count']!,
          _pendingPhysicalBottleCountMeta,
        ),
      );
    }
    if (data.containsKey('customer_owned_bottles_held')) {
      context.handle(
        _customerOwnedBottlesHeldMeta,
        customerOwnedBottlesHeld.isAcceptableOrUnknown(
          data['customer_owned_bottles_held']!,
          _customerOwnedBottlesHeldMeta,
        ),
      );
    }
    if (data.containsKey('last_physical_count_date')) {
      context.handle(
        _lastPhysicalCountDateMeta,
        lastPhysicalCountDate.isAcceptableOrUnknown(
          data['last_physical_count_date']!,
          _lastPhysicalCountDateMeta,
        ),
      );
    }
    if (data.containsKey('last_physical_count_verified')) {
      context.handle(
        _lastPhysicalCountVerifiedMeta,
        lastPhysicalCountVerified.isAcceptableOrUnknown(
          data['last_physical_count_verified']!,
          _lastPhysicalCountVerifiedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      phone: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}phone'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      pendingPhysicalBottleCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pending_physical_bottle_count'],
      ),
      customerOwnedBottlesHeld: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_owned_bottles_held'],
      )!,
      lastPhysicalCountDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_physical_count_date'],
      ),
      lastPhysicalCountVerified: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}last_physical_count_verified'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomersTableTable createAlias(String alias) {
    return $CustomersTableTable(attachedDatabase, alias);
  }
}

class CustomersTableData extends DataClass
    implements Insertable<CustomersTableData> {
  final String id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;

  /// Last recorded physical count pending reconciliation adjustment.
  final int? pendingPhysicalBottleCount;

  /// Bottles owned by the customer (not business inventory).
  final int customerOwnedBottlesHeld;

  /// Date of the most recent completed physical bottle count.
  final DateTime? lastPhysicalCountDate;
  final bool lastPhysicalCountVerified;
  final DateTime createdAt;
  const CustomersTableData({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    this.pendingPhysicalBottleCount,
    required this.customerOwnedBottlesHeld,
    this.lastPhysicalCountDate,
    required this.lastPhysicalCountVerified,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || phone != null) {
      map['phone'] = Variable<String>(phone);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || pendingPhysicalBottleCount != null) {
      map['pending_physical_bottle_count'] = Variable<int>(
        pendingPhysicalBottleCount,
      );
    }
    map['customer_owned_bottles_held'] = Variable<int>(
      customerOwnedBottlesHeld,
    );
    if (!nullToAbsent || lastPhysicalCountDate != null) {
      map['last_physical_count_date'] = Variable<DateTime>(
        lastPhysicalCountDate,
      );
    }
    map['last_physical_count_verified'] = Variable<bool>(
      lastPhysicalCountVerified,
    );
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomersTableCompanion toCompanion(bool nullToAbsent) {
    return CustomersTableCompanion(
      id: Value(id),
      name: Value(name),
      phone: phone == null && nullToAbsent
          ? const Value.absent()
          : Value(phone),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      pendingPhysicalBottleCount:
          pendingPhysicalBottleCount == null && nullToAbsent
          ? const Value.absent()
          : Value(pendingPhysicalBottleCount),
      customerOwnedBottlesHeld: Value(customerOwnedBottlesHeld),
      lastPhysicalCountDate: lastPhysicalCountDate == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPhysicalCountDate),
      lastPhysicalCountVerified: Value(lastPhysicalCountVerified),
      createdAt: Value(createdAt),
    );
  }

  factory CustomersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomersTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      phone: serializer.fromJson<String?>(json['phone']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      pendingPhysicalBottleCount: serializer.fromJson<int?>(
        json['pendingPhysicalBottleCount'],
      ),
      customerOwnedBottlesHeld: serializer.fromJson<int>(
        json['customerOwnedBottlesHeld'],
      ),
      lastPhysicalCountDate: serializer.fromJson<DateTime?>(
        json['lastPhysicalCountDate'],
      ),
      lastPhysicalCountVerified: serializer.fromJson<bool>(
        json['lastPhysicalCountVerified'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'phone': serializer.toJson<String?>(phone),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'pendingPhysicalBottleCount': serializer.toJson<int?>(
        pendingPhysicalBottleCount,
      ),
      'customerOwnedBottlesHeld': serializer.toJson<int>(
        customerOwnedBottlesHeld,
      ),
      'lastPhysicalCountDate': serializer.toJson<DateTime?>(
        lastPhysicalCountDate,
      ),
      'lastPhysicalCountVerified': serializer.toJson<bool>(
        lastPhysicalCountVerified,
      ),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomersTableData copyWith({
    String? id,
    String? name,
    Value<String?> phone = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<int?> pendingPhysicalBottleCount = const Value.absent(),
    int? customerOwnedBottlesHeld,
    Value<DateTime?> lastPhysicalCountDate = const Value.absent(),
    bool? lastPhysicalCountVerified,
    DateTime? createdAt,
  }) => CustomersTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone.present ? phone.value : this.phone,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    pendingPhysicalBottleCount: pendingPhysicalBottleCount.present
        ? pendingPhysicalBottleCount.value
        : this.pendingPhysicalBottleCount,
    customerOwnedBottlesHeld:
        customerOwnedBottlesHeld ?? this.customerOwnedBottlesHeld,
    lastPhysicalCountDate: lastPhysicalCountDate.present
        ? lastPhysicalCountDate.value
        : this.lastPhysicalCountDate,
    lastPhysicalCountVerified:
        lastPhysicalCountVerified ?? this.lastPhysicalCountVerified,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomersTableData copyWithCompanion(CustomersTableCompanion data) {
    return CustomersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      phone: data.phone.present ? data.phone.value : this.phone,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      pendingPhysicalBottleCount: data.pendingPhysicalBottleCount.present
          ? data.pendingPhysicalBottleCount.value
          : this.pendingPhysicalBottleCount,
      customerOwnedBottlesHeld: data.customerOwnedBottlesHeld.present
          ? data.customerOwnedBottlesHeld.value
          : this.customerOwnedBottlesHeld,
      lastPhysicalCountDate: data.lastPhysicalCountDate.present
          ? data.lastPhysicalCountDate.value
          : this.lastPhysicalCountDate,
      lastPhysicalCountVerified: data.lastPhysicalCountVerified.present
          ? data.lastPhysicalCountVerified.value
          : this.lastPhysicalCountVerified,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('pendingPhysicalBottleCount: $pendingPhysicalBottleCount, ')
          ..write('customerOwnedBottlesHeld: $customerOwnedBottlesHeld, ')
          ..write('lastPhysicalCountDate: $lastPhysicalCountDate, ')
          ..write('lastPhysicalCountVerified: $lastPhysicalCountVerified, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    phone,
    address,
    notes,
    pendingPhysicalBottleCount,
    customerOwnedBottlesHeld,
    lastPhysicalCountDate,
    lastPhysicalCountVerified,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.phone == this.phone &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.pendingPhysicalBottleCount == this.pendingPhysicalBottleCount &&
          other.customerOwnedBottlesHeld == this.customerOwnedBottlesHeld &&
          other.lastPhysicalCountDate == this.lastPhysicalCountDate &&
          other.lastPhysicalCountVerified == this.lastPhysicalCountVerified &&
          other.createdAt == this.createdAt);
}

class CustomersTableCompanion extends UpdateCompanion<CustomersTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> phone;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<int?> pendingPhysicalBottleCount;
  final Value<int> customerOwnedBottlesHeld;
  final Value<DateTime?> lastPhysicalCountDate;
  final Value<bool> lastPhysicalCountVerified;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.pendingPhysicalBottleCount = const Value.absent(),
    this.customerOwnedBottlesHeld = const Value.absent(),
    this.lastPhysicalCountDate = const Value.absent(),
    this.lastPhysicalCountVerified = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomersTableCompanion.insert({
    required String id,
    required String name,
    this.phone = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.pendingPhysicalBottleCount = const Value.absent(),
    this.customerOwnedBottlesHeld = const Value.absent(),
    this.lastPhysicalCountDate = const Value.absent(),
    this.lastPhysicalCountVerified = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<CustomersTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? phone,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<int>? pendingPhysicalBottleCount,
    Expression<int>? customerOwnedBottlesHeld,
    Expression<DateTime>? lastPhysicalCountDate,
    Expression<bool>? lastPhysicalCountVerified,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (pendingPhysicalBottleCount != null)
        'pending_physical_bottle_count': pendingPhysicalBottleCount,
      if (customerOwnedBottlesHeld != null)
        'customer_owned_bottles_held': customerOwnedBottlesHeld,
      if (lastPhysicalCountDate != null)
        'last_physical_count_date': lastPhysicalCountDate,
      if (lastPhysicalCountVerified != null)
        'last_physical_count_verified': lastPhysicalCountVerified,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? phone,
    Value<String?>? address,
    Value<String?>? notes,
    Value<int?>? pendingPhysicalBottleCount,
    Value<int>? customerOwnedBottlesHeld,
    Value<DateTime?>? lastPhysicalCountDate,
    Value<bool>? lastPhysicalCountVerified,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      pendingPhysicalBottleCount:
          pendingPhysicalBottleCount ?? this.pendingPhysicalBottleCount,
      customerOwnedBottlesHeld:
          customerOwnedBottlesHeld ?? this.customerOwnedBottlesHeld,
      lastPhysicalCountDate:
          lastPhysicalCountDate ?? this.lastPhysicalCountDate,
      lastPhysicalCountVerified:
          lastPhysicalCountVerified ?? this.lastPhysicalCountVerified,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (phone.present) {
      map['phone'] = Variable<String>(phone.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (pendingPhysicalBottleCount.present) {
      map['pending_physical_bottle_count'] = Variable<int>(
        pendingPhysicalBottleCount.value,
      );
    }
    if (customerOwnedBottlesHeld.present) {
      map['customer_owned_bottles_held'] = Variable<int>(
        customerOwnedBottlesHeld.value,
      );
    }
    if (lastPhysicalCountDate.present) {
      map['last_physical_count_date'] = Variable<DateTime>(
        lastPhysicalCountDate.value,
      );
    }
    if (lastPhysicalCountVerified.present) {
      map['last_physical_count_verified'] = Variable<bool>(
        lastPhysicalCountVerified.value,
      );
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('phone: $phone, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('pendingPhysicalBottleCount: $pendingPhysicalBottleCount, ')
          ..write('customerOwnedBottlesHeld: $customerOwnedBottlesHeld, ')
          ..write('lastPhysicalCountDate: $lastPhysicalCountDate, ')
          ..write('lastPhysicalCountVerified: $lastPhysicalCountVerified, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeliveriesTableTable extends DeliveriesTable
    with TableInfo<$DeliveriesTableTable, DeliveriesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeliveriesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pricePerBottleMeta = const VerificationMeta(
    'pricePerBottle',
  );
  @override
  late final GeneratedColumn<double> pricePerBottle = GeneratedColumn<double>(
    'price_per_bottle',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentStatusMeta = const VerificationMeta(
    'paymentStatus',
  );
  @override
  late final GeneratedColumn<String> paymentStatus = GeneratedColumn<String>(
    'payment_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('unpaid'),
  );
  static const VerificationMeta _amountPaidMeta = const VerificationMeta(
    'amountPaid',
  );
  @override
  late final GeneratedColumn<double> amountPaid = GeneratedColumn<double>(
    'amount_paid',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _depositAppliedMeta = const VerificationMeta(
    'depositApplied',
  );
  @override
  late final GeneratedColumn<double> depositApplied = GeneratedColumn<double>(
    'deposit_applied',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _remainingBalanceMeta = const VerificationMeta(
    'remainingBalance',
  );
  @override
  late final GeneratedColumn<double> remainingBalance = GeneratedColumn<double>(
    'remaining_balance',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(0.0),
  );
  static const VerificationMeta _deliveryDateMeta = const VerificationMeta(
    'deliveryDate',
  );
  @override
  late final GeneratedColumn<DateTime> deliveryDate = GeneratedColumn<DateTime>(
    'delivery_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _deliveryTimeMeta = const VerificationMeta(
    'deliveryTime',
  );
  @override
  late final GeneratedColumn<String> deliveryTime = GeneratedColumn<String>(
    'delivery_time',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryStatusMeta = const VerificationMeta(
    'deliveryStatus',
  );
  @override
  late final GeneratedColumn<String> deliveryStatus = GeneratedColumn<String>(
    'delivery_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('completed'),
  );
  static const VerificationMeta _collectedEmptyBottlesMeta =
      const VerificationMeta('collectedEmptyBottles');
  @override
  late final GeneratedColumn<int> collectedEmptyBottles = GeneratedColumn<int>(
    'collected_empty_bottles',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _customerOwnedBottlesFilledMeta =
      const VerificationMeta('customerOwnedBottlesFilled');
  @override
  late final GeneratedColumn<int> customerOwnedBottlesFilled =
      GeneratedColumn<int>(
        'customer_owned_bottles_filled',
        aliasedName,
        false,
        type: DriftSqlType.int,
        requiredDuringInsert: false,
        defaultValue: const Constant(0),
      );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _receiptNumberMeta = const VerificationMeta(
    'receiptNumber',
  );
  @override
  late final GeneratedColumn<String> receiptNumber = GeneratedColumn<String>(
    'receipt_number',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    quantity,
    pricePerBottle,
    totalAmount,
    paymentStatus,
    amountPaid,
    depositApplied,
    remainingBalance,
    deliveryDate,
    deliveryTime,
    deliveryStatus,
    collectedEmptyBottles,
    customerOwnedBottlesFilled,
    notes,
    receiptNumber,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deliveries';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeliveriesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('price_per_bottle')) {
      context.handle(
        _pricePerBottleMeta,
        pricePerBottle.isAcceptableOrUnknown(
          data['price_per_bottle']!,
          _pricePerBottleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerBottleMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('payment_status')) {
      context.handle(
        _paymentStatusMeta,
        paymentStatus.isAcceptableOrUnknown(
          data['payment_status']!,
          _paymentStatusMeta,
        ),
      );
    }
    if (data.containsKey('amount_paid')) {
      context.handle(
        _amountPaidMeta,
        amountPaid.isAcceptableOrUnknown(data['amount_paid']!, _amountPaidMeta),
      );
    }
    if (data.containsKey('deposit_applied')) {
      context.handle(
        _depositAppliedMeta,
        depositApplied.isAcceptableOrUnknown(
          data['deposit_applied']!,
          _depositAppliedMeta,
        ),
      );
    }
    if (data.containsKey('remaining_balance')) {
      context.handle(
        _remainingBalanceMeta,
        remainingBalance.isAcceptableOrUnknown(
          data['remaining_balance']!,
          _remainingBalanceMeta,
        ),
      );
    }
    if (data.containsKey('delivery_date')) {
      context.handle(
        _deliveryDateMeta,
        deliveryDate.isAcceptableOrUnknown(
          data['delivery_date']!,
          _deliveryDateMeta,
        ),
      );
    }
    if (data.containsKey('delivery_time')) {
      context.handle(
        _deliveryTimeMeta,
        deliveryTime.isAcceptableOrUnknown(
          data['delivery_time']!,
          _deliveryTimeMeta,
        ),
      );
    }
    if (data.containsKey('delivery_status')) {
      context.handle(
        _deliveryStatusMeta,
        deliveryStatus.isAcceptableOrUnknown(
          data['delivery_status']!,
          _deliveryStatusMeta,
        ),
      );
    }
    if (data.containsKey('collected_empty_bottles')) {
      context.handle(
        _collectedEmptyBottlesMeta,
        collectedEmptyBottles.isAcceptableOrUnknown(
          data['collected_empty_bottles']!,
          _collectedEmptyBottlesMeta,
        ),
      );
    }
    if (data.containsKey('customer_owned_bottles_filled')) {
      context.handle(
        _customerOwnedBottlesFilledMeta,
        customerOwnedBottlesFilled.isAcceptableOrUnknown(
          data['customer_owned_bottles_filled']!,
          _customerOwnedBottlesFilledMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('receipt_number')) {
      context.handle(
        _receiptNumberMeta,
        receiptNumber.isAcceptableOrUnknown(
          data['receipt_number']!,
          _receiptNumberMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeliveriesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeliveriesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      pricePerBottle: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_bottle'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paymentStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_status'],
      )!,
      amountPaid: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount_paid'],
      )!,
      depositApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}deposit_applied'],
      )!,
      remainingBalance: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}remaining_balance'],
      )!,
      deliveryDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}delivery_date'],
      )!,
      deliveryTime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_time'],
      ),
      deliveryStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_status'],
      )!,
      collectedEmptyBottles: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}collected_empty_bottles'],
      )!,
      customerOwnedBottlesFilled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_owned_bottles_filled'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      receiptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}receipt_number'],
      ),
    );
  }

  @override
  $DeliveriesTableTable createAlias(String alias) {
    return $DeliveriesTableTable(attachedDatabase, alias);
  }
}

class DeliveriesTableData extends DataClass
    implements Insertable<DeliveriesTableData> {
  final String id;
  final String customerId;
  final int quantity;
  final double pricePerBottle;
  final double totalAmount;
  final String paymentStatus;
  final double amountPaid;
  final double depositApplied;
  final double remainingBalance;
  final DateTime deliveryDate;
  final String? deliveryTime;
  final String deliveryStatus;
  final int collectedEmptyBottles;

  /// Customer-owned bottles filled during this delivery (no inventory impact).
  final int customerOwnedBottlesFilled;
  final String? notes;
  final String? receiptNumber;
  const DeliveriesTableData({
    required this.id,
    required this.customerId,
    required this.quantity,
    required this.pricePerBottle,
    required this.totalAmount,
    required this.paymentStatus,
    required this.amountPaid,
    required this.depositApplied,
    required this.remainingBalance,
    required this.deliveryDate,
    this.deliveryTime,
    required this.deliveryStatus,
    required this.collectedEmptyBottles,
    required this.customerOwnedBottlesFilled,
    this.notes,
    this.receiptNumber,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['quantity'] = Variable<int>(quantity);
    map['price_per_bottle'] = Variable<double>(pricePerBottle);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_status'] = Variable<String>(paymentStatus);
    map['amount_paid'] = Variable<double>(amountPaid);
    map['deposit_applied'] = Variable<double>(depositApplied);
    map['remaining_balance'] = Variable<double>(remainingBalance);
    map['delivery_date'] = Variable<DateTime>(deliveryDate);
    if (!nullToAbsent || deliveryTime != null) {
      map['delivery_time'] = Variable<String>(deliveryTime);
    }
    map['delivery_status'] = Variable<String>(deliveryStatus);
    map['collected_empty_bottles'] = Variable<int>(collectedEmptyBottles);
    map['customer_owned_bottles_filled'] = Variable<int>(
      customerOwnedBottlesFilled,
    );
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || receiptNumber != null) {
      map['receipt_number'] = Variable<String>(receiptNumber);
    }
    return map;
  }

  DeliveriesTableCompanion toCompanion(bool nullToAbsent) {
    return DeliveriesTableCompanion(
      id: Value(id),
      customerId: Value(customerId),
      quantity: Value(quantity),
      pricePerBottle: Value(pricePerBottle),
      totalAmount: Value(totalAmount),
      paymentStatus: Value(paymentStatus),
      amountPaid: Value(amountPaid),
      depositApplied: Value(depositApplied),
      remainingBalance: Value(remainingBalance),
      deliveryDate: Value(deliveryDate),
      deliveryTime: deliveryTime == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryTime),
      deliveryStatus: Value(deliveryStatus),
      collectedEmptyBottles: Value(collectedEmptyBottles),
      customerOwnedBottlesFilled: Value(customerOwnedBottlesFilled),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      receiptNumber: receiptNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(receiptNumber),
    );
  }

  factory DeliveriesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeliveriesTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      quantity: serializer.fromJson<int>(json['quantity']),
      pricePerBottle: serializer.fromJson<double>(json['pricePerBottle']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentStatus: serializer.fromJson<String>(json['paymentStatus']),
      amountPaid: serializer.fromJson<double>(json['amountPaid']),
      depositApplied: serializer.fromJson<double>(json['depositApplied']),
      remainingBalance: serializer.fromJson<double>(json['remainingBalance']),
      deliveryDate: serializer.fromJson<DateTime>(json['deliveryDate']),
      deliveryTime: serializer.fromJson<String?>(json['deliveryTime']),
      deliveryStatus: serializer.fromJson<String>(json['deliveryStatus']),
      collectedEmptyBottles: serializer.fromJson<int>(
        json['collectedEmptyBottles'],
      ),
      customerOwnedBottlesFilled: serializer.fromJson<int>(
        json['customerOwnedBottlesFilled'],
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      receiptNumber: serializer.fromJson<String?>(json['receiptNumber']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'quantity': serializer.toJson<int>(quantity),
      'pricePerBottle': serializer.toJson<double>(pricePerBottle),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentStatus': serializer.toJson<String>(paymentStatus),
      'amountPaid': serializer.toJson<double>(amountPaid),
      'depositApplied': serializer.toJson<double>(depositApplied),
      'remainingBalance': serializer.toJson<double>(remainingBalance),
      'deliveryDate': serializer.toJson<DateTime>(deliveryDate),
      'deliveryTime': serializer.toJson<String?>(deliveryTime),
      'deliveryStatus': serializer.toJson<String>(deliveryStatus),
      'collectedEmptyBottles': serializer.toJson<int>(collectedEmptyBottles),
      'customerOwnedBottlesFilled': serializer.toJson<int>(
        customerOwnedBottlesFilled,
      ),
      'notes': serializer.toJson<String?>(notes),
      'receiptNumber': serializer.toJson<String?>(receiptNumber),
    };
  }

  DeliveriesTableData copyWith({
    String? id,
    String? customerId,
    int? quantity,
    double? pricePerBottle,
    double? totalAmount,
    String? paymentStatus,
    double? amountPaid,
    double? depositApplied,
    double? remainingBalance,
    DateTime? deliveryDate,
    Value<String?> deliveryTime = const Value.absent(),
    String? deliveryStatus,
    int? collectedEmptyBottles,
    int? customerOwnedBottlesFilled,
    Value<String?> notes = const Value.absent(),
    Value<String?> receiptNumber = const Value.absent(),
  }) => DeliveriesTableData(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    quantity: quantity ?? this.quantity,
    pricePerBottle: pricePerBottle ?? this.pricePerBottle,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentStatus: paymentStatus ?? this.paymentStatus,
    amountPaid: amountPaid ?? this.amountPaid,
    depositApplied: depositApplied ?? this.depositApplied,
    remainingBalance: remainingBalance ?? this.remainingBalance,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    deliveryTime: deliveryTime.present ? deliveryTime.value : this.deliveryTime,
    deliveryStatus: deliveryStatus ?? this.deliveryStatus,
    collectedEmptyBottles: collectedEmptyBottles ?? this.collectedEmptyBottles,
    customerOwnedBottlesFilled:
        customerOwnedBottlesFilled ?? this.customerOwnedBottlesFilled,
    notes: notes.present ? notes.value : this.notes,
    receiptNumber: receiptNumber.present
        ? receiptNumber.value
        : this.receiptNumber,
  );
  DeliveriesTableData copyWithCompanion(DeliveriesTableCompanion data) {
    return DeliveriesTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      pricePerBottle: data.pricePerBottle.present
          ? data.pricePerBottle.value
          : this.pricePerBottle,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paymentStatus: data.paymentStatus.present
          ? data.paymentStatus.value
          : this.paymentStatus,
      amountPaid: data.amountPaid.present
          ? data.amountPaid.value
          : this.amountPaid,
      depositApplied: data.depositApplied.present
          ? data.depositApplied.value
          : this.depositApplied,
      remainingBalance: data.remainingBalance.present
          ? data.remainingBalance.value
          : this.remainingBalance,
      deliveryDate: data.deliveryDate.present
          ? data.deliveryDate.value
          : this.deliveryDate,
      deliveryTime: data.deliveryTime.present
          ? data.deliveryTime.value
          : this.deliveryTime,
      deliveryStatus: data.deliveryStatus.present
          ? data.deliveryStatus.value
          : this.deliveryStatus,
      collectedEmptyBottles: data.collectedEmptyBottles.present
          ? data.collectedEmptyBottles.value
          : this.collectedEmptyBottles,
      customerOwnedBottlesFilled: data.customerOwnedBottlesFilled.present
          ? data.customerOwnedBottlesFilled.value
          : this.customerOwnedBottlesFilled,
      notes: data.notes.present ? data.notes.value : this.notes,
      receiptNumber: data.receiptNumber.present
          ? data.receiptNumber.value
          : this.receiptNumber,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerBottle: $pricePerBottle, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('depositApplied: $depositApplied, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('collectedEmptyBottles: $collectedEmptyBottles, ')
          ..write('customerOwnedBottlesFilled: $customerOwnedBottlesFilled, ')
          ..write('notes: $notes, ')
          ..write('receiptNumber: $receiptNumber')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    quantity,
    pricePerBottle,
    totalAmount,
    paymentStatus,
    amountPaid,
    depositApplied,
    remainingBalance,
    deliveryDate,
    deliveryTime,
    deliveryStatus,
    collectedEmptyBottles,
    customerOwnedBottlesFilled,
    notes,
    receiptNumber,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeliveriesTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.quantity == this.quantity &&
          other.pricePerBottle == this.pricePerBottle &&
          other.totalAmount == this.totalAmount &&
          other.paymentStatus == this.paymentStatus &&
          other.amountPaid == this.amountPaid &&
          other.depositApplied == this.depositApplied &&
          other.remainingBalance == this.remainingBalance &&
          other.deliveryDate == this.deliveryDate &&
          other.deliveryTime == this.deliveryTime &&
          other.deliveryStatus == this.deliveryStatus &&
          other.collectedEmptyBottles == this.collectedEmptyBottles &&
          other.customerOwnedBottlesFilled == this.customerOwnedBottlesFilled &&
          other.notes == this.notes &&
          other.receiptNumber == this.receiptNumber);
}

class DeliveriesTableCompanion extends UpdateCompanion<DeliveriesTableData> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<int> quantity;
  final Value<double> pricePerBottle;
  final Value<double> totalAmount;
  final Value<String> paymentStatus;
  final Value<double> amountPaid;
  final Value<double> depositApplied;
  final Value<double> remainingBalance;
  final Value<DateTime> deliveryDate;
  final Value<String?> deliveryTime;
  final Value<String> deliveryStatus;
  final Value<int> collectedEmptyBottles;
  final Value<int> customerOwnedBottlesFilled;
  final Value<String?> notes;
  final Value<String?> receiptNumber;
  final Value<int> rowid;
  const DeliveriesTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.quantity = const Value.absent(),
    this.pricePerBottle = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentStatus = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.depositApplied = const Value.absent(),
    this.remainingBalance = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.deliveryTime = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.collectedEmptyBottles = const Value.absent(),
    this.customerOwnedBottlesFilled = const Value.absent(),
    this.notes = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeliveriesTableCompanion.insert({
    required String id,
    required String customerId,
    required int quantity,
    required double pricePerBottle,
    required double totalAmount,
    this.paymentStatus = const Value.absent(),
    this.amountPaid = const Value.absent(),
    this.depositApplied = const Value.absent(),
    this.remainingBalance = const Value.absent(),
    this.deliveryDate = const Value.absent(),
    this.deliveryTime = const Value.absent(),
    this.deliveryStatus = const Value.absent(),
    this.collectedEmptyBottles = const Value.absent(),
    this.customerOwnedBottlesFilled = const Value.absent(),
    this.notes = const Value.absent(),
    this.receiptNumber = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       quantity = Value(quantity),
       pricePerBottle = Value(pricePerBottle),
       totalAmount = Value(totalAmount);
  static Insertable<DeliveriesTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<int>? quantity,
    Expression<double>? pricePerBottle,
    Expression<double>? totalAmount,
    Expression<String>? paymentStatus,
    Expression<double>? amountPaid,
    Expression<double>? depositApplied,
    Expression<double>? remainingBalance,
    Expression<DateTime>? deliveryDate,
    Expression<String>? deliveryTime,
    Expression<String>? deliveryStatus,
    Expression<int>? collectedEmptyBottles,
    Expression<int>? customerOwnedBottlesFilled,
    Expression<String>? notes,
    Expression<String>? receiptNumber,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (quantity != null) 'quantity': quantity,
      if (pricePerBottle != null) 'price_per_bottle': pricePerBottle,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentStatus != null) 'payment_status': paymentStatus,
      if (amountPaid != null) 'amount_paid': amountPaid,
      if (depositApplied != null) 'deposit_applied': depositApplied,
      if (remainingBalance != null) 'remaining_balance': remainingBalance,
      if (deliveryDate != null) 'delivery_date': deliveryDate,
      if (deliveryTime != null) 'delivery_time': deliveryTime,
      if (deliveryStatus != null) 'delivery_status': deliveryStatus,
      if (collectedEmptyBottles != null)
        'collected_empty_bottles': collectedEmptyBottles,
      if (customerOwnedBottlesFilled != null)
        'customer_owned_bottles_filled': customerOwnedBottlesFilled,
      if (notes != null) 'notes': notes,
      if (receiptNumber != null) 'receipt_number': receiptNumber,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeliveriesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<int>? quantity,
    Value<double>? pricePerBottle,
    Value<double>? totalAmount,
    Value<String>? paymentStatus,
    Value<double>? amountPaid,
    Value<double>? depositApplied,
    Value<double>? remainingBalance,
    Value<DateTime>? deliveryDate,
    Value<String?>? deliveryTime,
    Value<String>? deliveryStatus,
    Value<int>? collectedEmptyBottles,
    Value<int>? customerOwnedBottlesFilled,
    Value<String?>? notes,
    Value<String?>? receiptNumber,
    Value<int>? rowid,
  }) {
    return DeliveriesTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      quantity: quantity ?? this.quantity,
      pricePerBottle: pricePerBottle ?? this.pricePerBottle,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      amountPaid: amountPaid ?? this.amountPaid,
      depositApplied: depositApplied ?? this.depositApplied,
      remainingBalance: remainingBalance ?? this.remainingBalance,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      deliveryTime: deliveryTime ?? this.deliveryTime,
      deliveryStatus: deliveryStatus ?? this.deliveryStatus,
      collectedEmptyBottles:
          collectedEmptyBottles ?? this.collectedEmptyBottles,
      customerOwnedBottlesFilled:
          customerOwnedBottlesFilled ?? this.customerOwnedBottlesFilled,
      notes: notes ?? this.notes,
      receiptNumber: receiptNumber ?? this.receiptNumber,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (pricePerBottle.present) {
      map['price_per_bottle'] = Variable<double>(pricePerBottle.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentStatus.present) {
      map['payment_status'] = Variable<String>(paymentStatus.value);
    }
    if (amountPaid.present) {
      map['amount_paid'] = Variable<double>(amountPaid.value);
    }
    if (depositApplied.present) {
      map['deposit_applied'] = Variable<double>(depositApplied.value);
    }
    if (remainingBalance.present) {
      map['remaining_balance'] = Variable<double>(remainingBalance.value);
    }
    if (deliveryDate.present) {
      map['delivery_date'] = Variable<DateTime>(deliveryDate.value);
    }
    if (deliveryTime.present) {
      map['delivery_time'] = Variable<String>(deliveryTime.value);
    }
    if (deliveryStatus.present) {
      map['delivery_status'] = Variable<String>(deliveryStatus.value);
    }
    if (collectedEmptyBottles.present) {
      map['collected_empty_bottles'] = Variable<int>(
        collectedEmptyBottles.value,
      );
    }
    if (customerOwnedBottlesFilled.present) {
      map['customer_owned_bottles_filled'] = Variable<int>(
        customerOwnedBottlesFilled.value,
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (receiptNumber.present) {
      map['receipt_number'] = Variable<String>(receiptNumber.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeliveriesTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('quantity: $quantity, ')
          ..write('pricePerBottle: $pricePerBottle, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentStatus: $paymentStatus, ')
          ..write('amountPaid: $amountPaid, ')
          ..write('depositApplied: $depositApplied, ')
          ..write('remainingBalance: $remainingBalance, ')
          ..write('deliveryDate: $deliveryDate, ')
          ..write('deliveryTime: $deliveryTime, ')
          ..write('deliveryStatus: $deliveryStatus, ')
          ..write('collectedEmptyBottles: $collectedEmptyBottles, ')
          ..write('customerOwnedBottlesFilled: $customerOwnedBottlesFilled, ')
          ..write('notes: $notes, ')
          ..write('receiptNumber: $receiptNumber, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BottleTransactionsTableTable extends BottleTransactionsTable
    with TableInfo<$BottleTransactionsTableTable, BottleTransactionsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BottleTransactionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    transactionType,
    quantity,
    date,
    reason,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'bottle_transactions';
  @override
  VerificationContext validateIntegrity(
    Insertable<BottleTransactionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BottleTransactionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BottleTransactionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $BottleTransactionsTableTable createAlias(String alias) {
    return $BottleTransactionsTableTable(attachedDatabase, alias);
  }
}

class BottleTransactionsTableData extends DataClass
    implements Insertable<BottleTransactionsTableData> {
  final String id;
  final String? customerId;
  final String transactionType;
  final int quantity;
  final DateTime date;
  final String? reason;
  final String? notes;
  const BottleTransactionsTableData({
    required this.id,
    this.customerId,
    required this.transactionType,
    required this.quantity,
    required this.date,
    this.reason,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['transaction_type'] = Variable<String>(transactionType);
    map['quantity'] = Variable<int>(quantity);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  BottleTransactionsTableCompanion toCompanion(bool nullToAbsent) {
    return BottleTransactionsTableCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      transactionType: Value(transactionType),
      quantity: Value(quantity),
      date: Value(date),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory BottleTransactionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BottleTransactionsTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      date: serializer.fromJson<DateTime>(json['date']),
      reason: serializer.fromJson<String?>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'transactionType': serializer.toJson<String>(transactionType),
      'quantity': serializer.toJson<int>(quantity),
      'date': serializer.toJson<DateTime>(date),
      'reason': serializer.toJson<String?>(reason),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  BottleTransactionsTableData copyWith({
    String? id,
    Value<String?> customerId = const Value.absent(),
    String? transactionType,
    int? quantity,
    DateTime? date,
    Value<String?> reason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => BottleTransactionsTableData(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    transactionType: transactionType ?? this.transactionType,
    quantity: quantity ?? this.quantity,
    date: date ?? this.date,
    reason: reason.present ? reason.value : this.reason,
    notes: notes.present ? notes.value : this.notes,
  );
  BottleTransactionsTableData copyWithCompanion(
    BottleTransactionsTableCompanion data,
  ) {
    return BottleTransactionsTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      date: data.date.present ? data.date.value : this.date,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BottleTransactionsTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantity: $quantity, ')
          ..write('date: $date, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    transactionType,
    quantity,
    date,
    reason,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BottleTransactionsTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.transactionType == this.transactionType &&
          other.quantity == this.quantity &&
          other.date == this.date &&
          other.reason == this.reason &&
          other.notes == this.notes);
}

class BottleTransactionsTableCompanion
    extends UpdateCompanion<BottleTransactionsTableData> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<String> transactionType;
  final Value<int> quantity;
  final Value<DateTime> date;
  final Value<String?> reason;
  final Value<String?> notes;
  final Value<int> rowid;
  const BottleTransactionsTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.date = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BottleTransactionsTableCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    required String transactionType,
    required int quantity,
    this.date = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       transactionType = Value(transactionType),
       quantity = Value(quantity);
  static Insertable<BottleTransactionsTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? transactionType,
    Expression<int>? quantity,
    Expression<DateTime>? date,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (transactionType != null) 'transaction_type': transactionType,
      if (quantity != null) 'quantity': quantity,
      if (date != null) 'date': date,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BottleTransactionsTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? customerId,
    Value<String>? transactionType,
    Value<int>? quantity,
    Value<DateTime>? date,
    Value<String?>? reason,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return BottleTransactionsTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      transactionType: transactionType ?? this.transactionType,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BottleTransactionsTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('transactionType: $transactionType, ')
          ..write('quantity: $quantity, ')
          ..write('date: $date, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PaymentsTableTable extends PaymentsTable
    with TableInfo<$PaymentsTableTable, PaymentsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PaymentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<String> deliveryId = GeneratedColumn<String>(
    'delivery_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentDateMeta = const VerificationMeta(
    'paymentDate',
  );
  @override
  late final GeneratedColumn<DateTime> paymentDate = GeneratedColumn<DateTime>(
    'payment_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    deliveryId,
    amount,
    paymentDate,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'payments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PaymentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('payment_date')) {
      context.handle(
        _paymentDateMeta,
        paymentDate.isAcceptableOrUnknown(
          data['payment_date']!,
          _paymentDateMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PaymentsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PaymentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_id'],
      ),
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      paymentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}payment_date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $PaymentsTableTable createAlias(String alias) {
    return $PaymentsTableTable(attachedDatabase, alias);
  }
}

class PaymentsTableData extends DataClass
    implements Insertable<PaymentsTableData> {
  final String id;
  final String customerId;
  final String? deliveryId;
  final double amount;
  final DateTime paymentDate;
  final String? notes;
  const PaymentsTableData({
    required this.id,
    required this.customerId,
    this.deliveryId,
    required this.amount,
    required this.paymentDate,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    if (!nullToAbsent || deliveryId != null) {
      map['delivery_id'] = Variable<String>(deliveryId);
    }
    map['amount'] = Variable<double>(amount);
    map['payment_date'] = Variable<DateTime>(paymentDate);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  PaymentsTableCompanion toCompanion(bool nullToAbsent) {
    return PaymentsTableCompanion(
      id: Value(id),
      customerId: Value(customerId),
      deliveryId: deliveryId == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryId),
      amount: Value(amount),
      paymentDate: Value(paymentDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory PaymentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PaymentsTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      deliveryId: serializer.fromJson<String?>(json['deliveryId']),
      amount: serializer.fromJson<double>(json['amount']),
      paymentDate: serializer.fromJson<DateTime>(json['paymentDate']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'deliveryId': serializer.toJson<String?>(deliveryId),
      'amount': serializer.toJson<double>(amount),
      'paymentDate': serializer.toJson<DateTime>(paymentDate),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  PaymentsTableData copyWith({
    String? id,
    String? customerId,
    Value<String?> deliveryId = const Value.absent(),
    double? amount,
    DateTime? paymentDate,
    Value<String?> notes = const Value.absent(),
  }) => PaymentsTableData(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    deliveryId: deliveryId.present ? deliveryId.value : this.deliveryId,
    amount: amount ?? this.amount,
    paymentDate: paymentDate ?? this.paymentDate,
    notes: notes.present ? notes.value : this.notes,
  );
  PaymentsTableData copyWithCompanion(PaymentsTableCompanion data) {
    return PaymentsTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      amount: data.amount.present ? data.amount.value : this.amount,
      paymentDate: data.paymentDate.present
          ? data.paymentDate.value
          : this.paymentDate,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, customerId, deliveryId, amount, paymentDate, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PaymentsTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.deliveryId == this.deliveryId &&
          other.amount == this.amount &&
          other.paymentDate == this.paymentDate &&
          other.notes == this.notes);
}

class PaymentsTableCompanion extends UpdateCompanion<PaymentsTableData> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String?> deliveryId;
  final Value<double> amount;
  final Value<DateTime> paymentDate;
  final Value<String?> notes;
  final Value<int> rowid;
  const PaymentsTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.amount = const Value.absent(),
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PaymentsTableCompanion.insert({
    required String id,
    required String customerId,
    this.deliveryId = const Value.absent(),
    required double amount,
    this.paymentDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       amount = Value(amount);
  static Insertable<PaymentsTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? deliveryId,
    Expression<double>? amount,
    Expression<DateTime>? paymentDate,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (amount != null) 'amount': amount,
      if (paymentDate != null) 'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PaymentsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String?>? deliveryId,
    Value<double>? amount,
    Value<DateTime>? paymentDate,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return PaymentsTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      deliveryId: deliveryId ?? this.deliveryId,
      amount: amount ?? this.amount,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<String>(deliveryId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (paymentDate.present) {
      map['payment_date'] = Variable<DateTime>(paymentDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PaymentsTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('amount: $amount, ')
          ..write('paymentDate: $paymentDate, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTableTable extends ExpensesTable
    with TableInfo<$ExpensesTableTable, ExpensesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplierMeta = const VerificationMeta(
    'supplier',
  );
  @override
  late final GeneratedColumn<String> supplier = GeneratedColumn<String>(
    'supplier',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _supplyPurchaseIdMeta = const VerificationMeta(
    'supplyPurchaseId',
  );
  @override
  late final GeneratedColumn<String> supplyPurchaseId = GeneratedColumn<String>(
    'supply_purchase_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    category,
    amount,
    date,
    notes,
    description,
    supplier,
    quantity,
    unitCost,
    supplyPurchaseId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExpensesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('supplier')) {
      context.handle(
        _supplierMeta,
        supplier.isAcceptableOrUnknown(data['supplier']!, _supplierMeta),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    }
    if (data.containsKey('supply_purchase_id')) {
      context.handle(
        _supplyPurchaseIdMeta,
        supplyPurchaseId.isAcceptableOrUnknown(
          data['supply_purchase_id']!,
          _supplyPurchaseIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpensesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpensesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      supplier: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier'],
      ),
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      ),
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      ),
      supplyPurchaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supply_purchase_id'],
      ),
    );
  }

  @override
  $ExpensesTableTable createAlias(String alias) {
    return $ExpensesTableTable(attachedDatabase, alias);
  }
}

class ExpensesTableData extends DataClass
    implements Insertable<ExpensesTableData> {
  final String id;
  final String category;
  final double amount;
  final DateTime date;
  final String? notes;
  final String? description;
  final String? supplier;
  final int? quantity;
  final double? unitCost;
  final String? supplyPurchaseId;
  const ExpensesTableData({
    required this.id,
    required this.category,
    required this.amount,
    required this.date,
    this.notes,
    this.description,
    this.supplier,
    this.quantity,
    this.unitCost,
    this.supplyPurchaseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['category'] = Variable<String>(category);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    if (!nullToAbsent || supplier != null) {
      map['supplier'] = Variable<String>(supplier);
    }
    if (!nullToAbsent || quantity != null) {
      map['quantity'] = Variable<int>(quantity);
    }
    if (!nullToAbsent || unitCost != null) {
      map['unit_cost'] = Variable<double>(unitCost);
    }
    if (!nullToAbsent || supplyPurchaseId != null) {
      map['supply_purchase_id'] = Variable<String>(supplyPurchaseId);
    }
    return map;
  }

  ExpensesTableCompanion toCompanion(bool nullToAbsent) {
    return ExpensesTableCompanion(
      id: Value(id),
      category: Value(category),
      amount: Value(amount),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      supplier: supplier == null && nullToAbsent
          ? const Value.absent()
          : Value(supplier),
      quantity: quantity == null && nullToAbsent
          ? const Value.absent()
          : Value(quantity),
      unitCost: unitCost == null && nullToAbsent
          ? const Value.absent()
          : Value(unitCost),
      supplyPurchaseId: supplyPurchaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplyPurchaseId),
    );
  }

  factory ExpensesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpensesTableData(
      id: serializer.fromJson<String>(json['id']),
      category: serializer.fromJson<String>(json['category']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      description: serializer.fromJson<String?>(json['description']),
      supplier: serializer.fromJson<String?>(json['supplier']),
      quantity: serializer.fromJson<int?>(json['quantity']),
      unitCost: serializer.fromJson<double?>(json['unitCost']),
      supplyPurchaseId: serializer.fromJson<String?>(json['supplyPurchaseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'category': serializer.toJson<String>(category),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'description': serializer.toJson<String?>(description),
      'supplier': serializer.toJson<String?>(supplier),
      'quantity': serializer.toJson<int?>(quantity),
      'unitCost': serializer.toJson<double?>(unitCost),
      'supplyPurchaseId': serializer.toJson<String?>(supplyPurchaseId),
    };
  }

  ExpensesTableData copyWith({
    String? id,
    String? category,
    double? amount,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    Value<String?> description = const Value.absent(),
    Value<String?> supplier = const Value.absent(),
    Value<int?> quantity = const Value.absent(),
    Value<double?> unitCost = const Value.absent(),
    Value<String?> supplyPurchaseId = const Value.absent(),
  }) => ExpensesTableData(
    id: id ?? this.id,
    category: category ?? this.category,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    description: description.present ? description.value : this.description,
    supplier: supplier.present ? supplier.value : this.supplier,
    quantity: quantity.present ? quantity.value : this.quantity,
    unitCost: unitCost.present ? unitCost.value : this.unitCost,
    supplyPurchaseId: supplyPurchaseId.present
        ? supplyPurchaseId.value
        : this.supplyPurchaseId,
  );
  ExpensesTableData copyWithCompanion(ExpensesTableCompanion data) {
    return ExpensesTableData(
      id: data.id.present ? data.id.value : this.id,
      category: data.category.present ? data.category.value : this.category,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      description: data.description.present
          ? data.description.value
          : this.description,
      supplier: data.supplier.present ? data.supplier.value : this.supplier,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      supplyPurchaseId: data.supplyPurchaseId.present
          ? data.supplyPurchaseId.value
          : this.supplyPurchaseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableData(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('description: $description, ')
          ..write('supplier: $supplier, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('supplyPurchaseId: $supplyPurchaseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    category,
    amount,
    date,
    notes,
    description,
    supplier,
    quantity,
    unitCost,
    supplyPurchaseId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpensesTableData &&
          other.id == this.id &&
          other.category == this.category &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.description == this.description &&
          other.supplier == this.supplier &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.supplyPurchaseId == this.supplyPurchaseId);
}

class ExpensesTableCompanion extends UpdateCompanion<ExpensesTableData> {
  final Value<String> id;
  final Value<String> category;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String?> description;
  final Value<String?> supplier;
  final Value<int?> quantity;
  final Value<double?> unitCost;
  final Value<String?> supplyPurchaseId;
  final Value<int> rowid;
  const ExpensesTableCompanion({
    this.id = const Value.absent(),
    this.category = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.description = const Value.absent(),
    this.supplier = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.supplyPurchaseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesTableCompanion.insert({
    required String id,
    required String category,
    required double amount,
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.description = const Value.absent(),
    this.supplier = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.supplyPurchaseId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       category = Value(category),
       amount = Value(amount);
  static Insertable<ExpensesTableData> custom({
    Expression<String>? id,
    Expression<String>? category,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? description,
    Expression<String>? supplier,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<String>? supplyPurchaseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (category != null) 'category': category,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (description != null) 'description': description,
      if (supplier != null) 'supplier': supplier,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (supplyPurchaseId != null) 'supply_purchase_id': supplyPurchaseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? category,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String?>? description,
    Value<String?>? supplier,
    Value<int?>? quantity,
    Value<double?>? unitCost,
    Value<String?>? supplyPurchaseId,
    Value<int>? rowid,
  }) {
    return ExpensesTableCompanion(
      id: id ?? this.id,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      description: description ?? this.description,
      supplier: supplier ?? this.supplier,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      supplyPurchaseId: supplyPurchaseId ?? this.supplyPurchaseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (supplier.present) {
      map['supplier'] = Variable<String>(supplier.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (supplyPurchaseId.present) {
      map['supply_purchase_id'] = Variable<String>(supplyPurchaseId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesTableCompanion(')
          ..write('id: $id, ')
          ..write('category: $category, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('description: $description, ')
          ..write('supplier: $supplier, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('supplyPurchaseId: $supplyPurchaseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DispenserSalesTableTable extends DispenserSalesTable
    with TableInfo<$DispenserSalesTableTable, DispenserSalesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DispenserSalesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, date, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'dispenser_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<DispenserSalesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DispenserSalesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DispenserSalesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $DispenserSalesTableTable createAlias(String alias) {
    return $DispenserSalesTableTable(attachedDatabase, alias);
  }
}

class DispenserSalesTableData extends DataClass
    implements Insertable<DispenserSalesTableData> {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  const DispenserSalesTableData({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DispenserSalesTableCompanion toCompanion(bool nullToAbsent) {
    return DispenserSalesTableCompanion(
      id: Value(id),
      amount: Value(amount),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory DispenserSalesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DispenserSalesTableData(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DispenserSalesTableData copyWith({
    String? id,
    double? amount,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
  }) => DispenserSalesTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
  );
  DispenserSalesTableData copyWithCompanion(DispenserSalesTableCompanion data) {
    return DispenserSalesTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DispenserSalesTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DispenserSalesTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.notes == this.notes);
}

class DispenserSalesTableCompanion
    extends UpdateCompanion<DispenserSalesTableData> {
  final Value<String> id;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<int> rowid;
  const DispenserSalesTableCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DispenserSalesTableCompanion.insert({
    required String id,
    required double amount,
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount);
  static Insertable<DispenserSalesTableData> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DispenserSalesTableCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return DispenserSalesTableCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DispenserSalesTableCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SettingsTableTable extends SettingsTable
    with TableInfo<$SettingsTableTable, SettingsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SettingsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<SettingsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  SettingsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SettingsTableData(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $SettingsTableTable createAlias(String alias) {
    return $SettingsTableTable(attachedDatabase, alias);
  }
}

class SettingsTableData extends DataClass
    implements Insertable<SettingsTableData> {
  final String key;
  final String value;
  const SettingsTableData({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  SettingsTableCompanion toCompanion(bool nullToAbsent) {
    return SettingsTableCompanion(key: Value(key), value: Value(value));
  }

  factory SettingsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SettingsTableData(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  SettingsTableData copyWith({String? key, String? value}) =>
      SettingsTableData(key: key ?? this.key, value: value ?? this.value);
  SettingsTableData copyWithCompanion(SettingsTableCompanion data) {
    return SettingsTableData(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableData(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SettingsTableData &&
          other.key == this.key &&
          other.value == this.value);
}

class SettingsTableCompanion extends UpdateCompanion<SettingsTableData> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const SettingsTableCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SettingsTableCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<SettingsTableData> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SettingsTableCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return SettingsTableCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SettingsTableCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsContributionsTableTable extends SavingsContributionsTable
    with
        TableInfo<
          $SavingsContributionsTableTable,
          SavingsContributionsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsContributionsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, amount, date, notes];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_contributions';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsContributionsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsContributionsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsContributionsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $SavingsContributionsTableTable createAlias(String alias) {
    return $SavingsContributionsTableTable(attachedDatabase, alias);
  }
}

class SavingsContributionsTableData extends DataClass
    implements Insertable<SavingsContributionsTableData> {
  final String id;
  final double amount;
  final DateTime date;
  final String? notes;
  const SavingsContributionsTableData({
    required this.id,
    required this.amount,
    required this.date,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['amount'] = Variable<double>(amount);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  SavingsContributionsTableCompanion toCompanion(bool nullToAbsent) {
    return SavingsContributionsTableCompanion(
      id: Value(id),
      amount: Value(amount),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory SavingsContributionsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsContributionsTableData(
      id: serializer.fromJson<String>(json['id']),
      amount: serializer.fromJson<double>(json['amount']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'amount': serializer.toJson<double>(amount),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  SavingsContributionsTableData copyWith({
    String? id,
    double? amount,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
  }) => SavingsContributionsTableData(
    id: id ?? this.id,
    amount: amount ?? this.amount,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
  );
  SavingsContributionsTableData copyWithCompanion(
    SavingsContributionsTableCompanion data,
  ) {
    return SavingsContributionsTableData(
      id: data.id.present ? data.id.value : this.id,
      amount: data.amount.present ? data.amount.value : this.amount,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsContributionsTableData(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, amount, date, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsContributionsTableData &&
          other.id == this.id &&
          other.amount == this.amount &&
          other.date == this.date &&
          other.notes == this.notes);
}

class SavingsContributionsTableCompanion
    extends UpdateCompanion<SavingsContributionsTableData> {
  final Value<String> id;
  final Value<double> amount;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<int> rowid;
  const SavingsContributionsTableCompanion({
    this.id = const Value.absent(),
    this.amount = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsContributionsTableCompanion.insert({
    required String id,
    required double amount,
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       amount = Value(amount);
  static Insertable<SavingsContributionsTableData> custom({
    Expression<String>? id,
    Expression<double>? amount,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (amount != null) 'amount': amount,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsContributionsTableCompanion copyWith({
    Value<String>? id,
    Value<double>? amount,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return SavingsContributionsTableCompanion(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsContributionsTableCompanion(')
          ..write('id: $id, ')
          ..write('amount: $amount, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SupplyPurchasesTableTable extends SupplyPurchasesTable
    with TableInfo<$SupplyPurchasesTableTable, SupplyPurchasesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SupplyPurchasesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _purchaseDateMeta = const VerificationMeta(
    'purchaseDate',
  );
  @override
  late final GeneratedColumn<DateTime> purchaseDate = GeneratedColumn<DateTime>(
    'purchase_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _supplierNameMeta = const VerificationMeta(
    'supplierName',
  );
  @override
  late final GeneratedColumn<String> supplierName = GeneratedColumn<String>(
    'supplier_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _supplierIdMeta = const VerificationMeta(
    'supplierId',
  );
  @override
  late final GeneratedColumn<String> supplierId = GeneratedColumn<String>(
    'supplier_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _unitCostMeta = const VerificationMeta(
    'unitCost',
  );
  @override
  late final GeneratedColumn<double> unitCost = GeneratedColumn<double>(
    'unit_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalCostMeta = const VerificationMeta(
    'totalCost',
  );
  @override
  late final GeneratedColumn<double> totalCost = GeneratedColumn<double>(
    'total_cost',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _expenseIdMeta = const VerificationMeta(
    'expenseId',
  );
  @override
  late final GeneratedColumn<String> expenseId = GeneratedColumn<String>(
    'expense_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bottleTransactionIdMeta =
      const VerificationMeta('bottleTransactionId');
  @override
  late final GeneratedColumn<String> bottleTransactionId =
      GeneratedColumn<String>(
        'bottle_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    purchaseDate,
    supplierName,
    supplierId,
    itemType,
    quantity,
    unitCost,
    totalCost,
    notes,
    expenseId,
    bottleTransactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'supply_purchases';
  @override
  VerificationContext validateIntegrity(
    Insertable<SupplyPurchasesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('purchase_date')) {
      context.handle(
        _purchaseDateMeta,
        purchaseDate.isAcceptableOrUnknown(
          data['purchase_date']!,
          _purchaseDateMeta,
        ),
      );
    }
    if (data.containsKey('supplier_name')) {
      context.handle(
        _supplierNameMeta,
        supplierName.isAcceptableOrUnknown(
          data['supplier_name']!,
          _supplierNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_supplierNameMeta);
    }
    if (data.containsKey('supplier_id')) {
      context.handle(
        _supplierIdMeta,
        supplierId.isAcceptableOrUnknown(data['supplier_id']!, _supplierIdMeta),
      );
    }
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('unit_cost')) {
      context.handle(
        _unitCostMeta,
        unitCost.isAcceptableOrUnknown(data['unit_cost']!, _unitCostMeta),
      );
    } else if (isInserting) {
      context.missing(_unitCostMeta);
    }
    if (data.containsKey('total_cost')) {
      context.handle(
        _totalCostMeta,
        totalCost.isAcceptableOrUnknown(data['total_cost']!, _totalCostMeta),
      );
    } else if (isInserting) {
      context.missing(_totalCostMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('expense_id')) {
      context.handle(
        _expenseIdMeta,
        expenseId.isAcceptableOrUnknown(data['expense_id']!, _expenseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_expenseIdMeta);
    }
    if (data.containsKey('bottle_transaction_id')) {
      context.handle(
        _bottleTransactionIdMeta,
        bottleTransactionId.isAcceptableOrUnknown(
          data['bottle_transaction_id']!,
          _bottleTransactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SupplyPurchasesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SupplyPurchasesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      purchaseDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}purchase_date'],
      )!,
      supplierName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_name'],
      )!,
      supplierId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}supplier_id'],
      ),
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      unitCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}unit_cost'],
      )!,
      totalCost: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_cost'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      expenseId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}expense_id'],
      )!,
      bottleTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bottle_transaction_id'],
      ),
    );
  }

  @override
  $SupplyPurchasesTableTable createAlias(String alias) {
    return $SupplyPurchasesTableTable(attachedDatabase, alias);
  }
}

class SupplyPurchasesTableData extends DataClass
    implements Insertable<SupplyPurchasesTableData> {
  final String id;
  final DateTime purchaseDate;
  final String supplierName;
  final String? supplierId;
  final String itemType;
  final int quantity;
  final double unitCost;
  final double totalCost;
  final String? notes;
  final String expenseId;
  final String? bottleTransactionId;
  const SupplyPurchasesTableData({
    required this.id,
    required this.purchaseDate,
    required this.supplierName,
    this.supplierId,
    required this.itemType,
    required this.quantity,
    required this.unitCost,
    required this.totalCost,
    this.notes,
    required this.expenseId,
    this.bottleTransactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['purchase_date'] = Variable<DateTime>(purchaseDate);
    map['supplier_name'] = Variable<String>(supplierName);
    if (!nullToAbsent || supplierId != null) {
      map['supplier_id'] = Variable<String>(supplierId);
    }
    map['item_type'] = Variable<String>(itemType);
    map['quantity'] = Variable<int>(quantity);
    map['unit_cost'] = Variable<double>(unitCost);
    map['total_cost'] = Variable<double>(totalCost);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['expense_id'] = Variable<String>(expenseId);
    if (!nullToAbsent || bottleTransactionId != null) {
      map['bottle_transaction_id'] = Variable<String>(bottleTransactionId);
    }
    return map;
  }

  SupplyPurchasesTableCompanion toCompanion(bool nullToAbsent) {
    return SupplyPurchasesTableCompanion(
      id: Value(id),
      purchaseDate: Value(purchaseDate),
      supplierName: Value(supplierName),
      supplierId: supplierId == null && nullToAbsent
          ? const Value.absent()
          : Value(supplierId),
      itemType: Value(itemType),
      quantity: Value(quantity),
      unitCost: Value(unitCost),
      totalCost: Value(totalCost),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      expenseId: Value(expenseId),
      bottleTransactionId: bottleTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(bottleTransactionId),
    );
  }

  factory SupplyPurchasesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SupplyPurchasesTableData(
      id: serializer.fromJson<String>(json['id']),
      purchaseDate: serializer.fromJson<DateTime>(json['purchaseDate']),
      supplierName: serializer.fromJson<String>(json['supplierName']),
      supplierId: serializer.fromJson<String?>(json['supplierId']),
      itemType: serializer.fromJson<String>(json['itemType']),
      quantity: serializer.fromJson<int>(json['quantity']),
      unitCost: serializer.fromJson<double>(json['unitCost']),
      totalCost: serializer.fromJson<double>(json['totalCost']),
      notes: serializer.fromJson<String?>(json['notes']),
      expenseId: serializer.fromJson<String>(json['expenseId']),
      bottleTransactionId: serializer.fromJson<String?>(
        json['bottleTransactionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'purchaseDate': serializer.toJson<DateTime>(purchaseDate),
      'supplierName': serializer.toJson<String>(supplierName),
      'supplierId': serializer.toJson<String?>(supplierId),
      'itemType': serializer.toJson<String>(itemType),
      'quantity': serializer.toJson<int>(quantity),
      'unitCost': serializer.toJson<double>(unitCost),
      'totalCost': serializer.toJson<double>(totalCost),
      'notes': serializer.toJson<String?>(notes),
      'expenseId': serializer.toJson<String>(expenseId),
      'bottleTransactionId': serializer.toJson<String?>(bottleTransactionId),
    };
  }

  SupplyPurchasesTableData copyWith({
    String? id,
    DateTime? purchaseDate,
    String? supplierName,
    Value<String?> supplierId = const Value.absent(),
    String? itemType,
    int? quantity,
    double? unitCost,
    double? totalCost,
    Value<String?> notes = const Value.absent(),
    String? expenseId,
    Value<String?> bottleTransactionId = const Value.absent(),
  }) => SupplyPurchasesTableData(
    id: id ?? this.id,
    purchaseDate: purchaseDate ?? this.purchaseDate,
    supplierName: supplierName ?? this.supplierName,
    supplierId: supplierId.present ? supplierId.value : this.supplierId,
    itemType: itemType ?? this.itemType,
    quantity: quantity ?? this.quantity,
    unitCost: unitCost ?? this.unitCost,
    totalCost: totalCost ?? this.totalCost,
    notes: notes.present ? notes.value : this.notes,
    expenseId: expenseId ?? this.expenseId,
    bottleTransactionId: bottleTransactionId.present
        ? bottleTransactionId.value
        : this.bottleTransactionId,
  );
  SupplyPurchasesTableData copyWithCompanion(
    SupplyPurchasesTableCompanion data,
  ) {
    return SupplyPurchasesTableData(
      id: data.id.present ? data.id.value : this.id,
      purchaseDate: data.purchaseDate.present
          ? data.purchaseDate.value
          : this.purchaseDate,
      supplierName: data.supplierName.present
          ? data.supplierName.value
          : this.supplierName,
      supplierId: data.supplierId.present
          ? data.supplierId.value
          : this.supplierId,
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      unitCost: data.unitCost.present ? data.unitCost.value : this.unitCost,
      totalCost: data.totalCost.present ? data.totalCost.value : this.totalCost,
      notes: data.notes.present ? data.notes.value : this.notes,
      expenseId: data.expenseId.present ? data.expenseId.value : this.expenseId,
      bottleTransactionId: data.bottleTransactionId.present
          ? data.bottleTransactionId.value
          : this.bottleTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SupplyPurchasesTableData(')
          ..write('id: $id, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('supplierName: $supplierName, ')
          ..write('supplierId: $supplierId, ')
          ..write('itemType: $itemType, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('notes: $notes, ')
          ..write('expenseId: $expenseId, ')
          ..write('bottleTransactionId: $bottleTransactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    purchaseDate,
    supplierName,
    supplierId,
    itemType,
    quantity,
    unitCost,
    totalCost,
    notes,
    expenseId,
    bottleTransactionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SupplyPurchasesTableData &&
          other.id == this.id &&
          other.purchaseDate == this.purchaseDate &&
          other.supplierName == this.supplierName &&
          other.supplierId == this.supplierId &&
          other.itemType == this.itemType &&
          other.quantity == this.quantity &&
          other.unitCost == this.unitCost &&
          other.totalCost == this.totalCost &&
          other.notes == this.notes &&
          other.expenseId == this.expenseId &&
          other.bottleTransactionId == this.bottleTransactionId);
}

class SupplyPurchasesTableCompanion
    extends UpdateCompanion<SupplyPurchasesTableData> {
  final Value<String> id;
  final Value<DateTime> purchaseDate;
  final Value<String> supplierName;
  final Value<String?> supplierId;
  final Value<String> itemType;
  final Value<int> quantity;
  final Value<double> unitCost;
  final Value<double> totalCost;
  final Value<String?> notes;
  final Value<String> expenseId;
  final Value<String?> bottleTransactionId;
  final Value<int> rowid;
  const SupplyPurchasesTableCompanion({
    this.id = const Value.absent(),
    this.purchaseDate = const Value.absent(),
    this.supplierName = const Value.absent(),
    this.supplierId = const Value.absent(),
    this.itemType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.unitCost = const Value.absent(),
    this.totalCost = const Value.absent(),
    this.notes = const Value.absent(),
    this.expenseId = const Value.absent(),
    this.bottleTransactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SupplyPurchasesTableCompanion.insert({
    required String id,
    this.purchaseDate = const Value.absent(),
    required String supplierName,
    this.supplierId = const Value.absent(),
    required String itemType,
    required int quantity,
    required double unitCost,
    required double totalCost,
    this.notes = const Value.absent(),
    required String expenseId,
    this.bottleTransactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       supplierName = Value(supplierName),
       itemType = Value(itemType),
       quantity = Value(quantity),
       unitCost = Value(unitCost),
       totalCost = Value(totalCost),
       expenseId = Value(expenseId);
  static Insertable<SupplyPurchasesTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? purchaseDate,
    Expression<String>? supplierName,
    Expression<String>? supplierId,
    Expression<String>? itemType,
    Expression<int>? quantity,
    Expression<double>? unitCost,
    Expression<double>? totalCost,
    Expression<String>? notes,
    Expression<String>? expenseId,
    Expression<String>? bottleTransactionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (purchaseDate != null) 'purchase_date': purchaseDate,
      if (supplierName != null) 'supplier_name': supplierName,
      if (supplierId != null) 'supplier_id': supplierId,
      if (itemType != null) 'item_type': itemType,
      if (quantity != null) 'quantity': quantity,
      if (unitCost != null) 'unit_cost': unitCost,
      if (totalCost != null) 'total_cost': totalCost,
      if (notes != null) 'notes': notes,
      if (expenseId != null) 'expense_id': expenseId,
      if (bottleTransactionId != null)
        'bottle_transaction_id': bottleTransactionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SupplyPurchasesTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? purchaseDate,
    Value<String>? supplierName,
    Value<String?>? supplierId,
    Value<String>? itemType,
    Value<int>? quantity,
    Value<double>? unitCost,
    Value<double>? totalCost,
    Value<String?>? notes,
    Value<String>? expenseId,
    Value<String?>? bottleTransactionId,
    Value<int>? rowid,
  }) {
    return SupplyPurchasesTableCompanion(
      id: id ?? this.id,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      supplierName: supplierName ?? this.supplierName,
      supplierId: supplierId ?? this.supplierId,
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      totalCost: totalCost ?? this.totalCost,
      notes: notes ?? this.notes,
      expenseId: expenseId ?? this.expenseId,
      bottleTransactionId: bottleTransactionId ?? this.bottleTransactionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (purchaseDate.present) {
      map['purchase_date'] = Variable<DateTime>(purchaseDate.value);
    }
    if (supplierName.present) {
      map['supplier_name'] = Variable<String>(supplierName.value);
    }
    if (supplierId.present) {
      map['supplier_id'] = Variable<String>(supplierId.value);
    }
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (unitCost.present) {
      map['unit_cost'] = Variable<double>(unitCost.value);
    }
    if (totalCost.present) {
      map['total_cost'] = Variable<double>(totalCost.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (expenseId.present) {
      map['expense_id'] = Variable<String>(expenseId.value);
    }
    if (bottleTransactionId.present) {
      map['bottle_transaction_id'] = Variable<String>(
        bottleTransactionId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SupplyPurchasesTableCompanion(')
          ..write('id: $id, ')
          ..write('purchaseDate: $purchaseDate, ')
          ..write('supplierName: $supplierName, ')
          ..write('supplierId: $supplierId, ')
          ..write('itemType: $itemType, ')
          ..write('quantity: $quantity, ')
          ..write('unitCost: $unitCost, ')
          ..write('totalCost: $totalCost, ')
          ..write('notes: $notes, ')
          ..write('expenseId: $expenseId, ')
          ..write('bottleTransactionId: $bottleTransactionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryStockTableTable extends InventoryStockTable
    with TableInfo<$InventoryStockTableTable, InventoryStockTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryStockTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _itemTypeMeta = const VerificationMeta(
    'itemType',
  );
  @override
  late final GeneratedColumn<String> itemType = GeneratedColumn<String>(
    'item_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [itemType, quantity];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_stock';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryStockTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('item_type')) {
      context.handle(
        _itemTypeMeta,
        itemType.isAcceptableOrUnknown(data['item_type']!, _itemTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_itemTypeMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {itemType};
  @override
  InventoryStockTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryStockTableData(
      itemType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}item_type'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
    );
  }

  @override
  $InventoryStockTableTable createAlias(String alias) {
    return $InventoryStockTableTable(attachedDatabase, alias);
  }
}

class InventoryStockTableData extends DataClass
    implements Insertable<InventoryStockTableData> {
  final String itemType;
  final int quantity;
  const InventoryStockTableData({
    required this.itemType,
    required this.quantity,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['item_type'] = Variable<String>(itemType);
    map['quantity'] = Variable<int>(quantity);
    return map;
  }

  InventoryStockTableCompanion toCompanion(bool nullToAbsent) {
    return InventoryStockTableCompanion(
      itemType: Value(itemType),
      quantity: Value(quantity),
    );
  }

  factory InventoryStockTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryStockTableData(
      itemType: serializer.fromJson<String>(json['itemType']),
      quantity: serializer.fromJson<int>(json['quantity']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'itemType': serializer.toJson<String>(itemType),
      'quantity': serializer.toJson<int>(quantity),
    };
  }

  InventoryStockTableData copyWith({String? itemType, int? quantity}) =>
      InventoryStockTableData(
        itemType: itemType ?? this.itemType,
        quantity: quantity ?? this.quantity,
      );
  InventoryStockTableData copyWithCompanion(InventoryStockTableCompanion data) {
    return InventoryStockTableData(
      itemType: data.itemType.present ? data.itemType.value : this.itemType,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryStockTableData(')
          ..write('itemType: $itemType, ')
          ..write('quantity: $quantity')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(itemType, quantity);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryStockTableData &&
          other.itemType == this.itemType &&
          other.quantity == this.quantity);
}

class InventoryStockTableCompanion
    extends UpdateCompanion<InventoryStockTableData> {
  final Value<String> itemType;
  final Value<int> quantity;
  final Value<int> rowid;
  const InventoryStockTableCompanion({
    this.itemType = const Value.absent(),
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryStockTableCompanion.insert({
    required String itemType,
    this.quantity = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : itemType = Value(itemType);
  static Insertable<InventoryStockTableData> custom({
    Expression<String>? itemType,
    Expression<int>? quantity,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (itemType != null) 'item_type': itemType,
      if (quantity != null) 'quantity': quantity,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryStockTableCompanion copyWith({
    Value<String>? itemType,
    Value<int>? quantity,
    Value<int>? rowid,
  }) {
    return InventoryStockTableCompanion(
      itemType: itemType ?? this.itemType,
      quantity: quantity ?? this.quantity,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (itemType.present) {
      map['item_type'] = Variable<String>(itemType.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryStockTableCompanion(')
          ..write('itemType: $itemType, ')
          ..write('quantity: $quantity, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SuppliersTableTable extends SuppliersTable
    with TableInfo<$SuppliersTableTable, SuppliersTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SuppliersTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contactPersonMeta = const VerificationMeta(
    'contactPerson',
  );
  @override
  late final GeneratedColumn<String> contactPerson = GeneratedColumn<String>(
    'contact_person',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mobileMeta = const VerificationMeta('mobile');
  @override
  late final GeneratedColumn<String> mobile = GeneratedColumn<String>(
    'mobile',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _addressMeta = const VerificationMeta(
    'address',
  );
  @override
  late final GeneratedColumn<String> address = GeneratedColumn<String>(
    'address',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    contactPerson,
    mobile,
    address,
    notes,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'suppliers';
  @override
  VerificationContext validateIntegrity(
    Insertable<SuppliersTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('contact_person')) {
      context.handle(
        _contactPersonMeta,
        contactPerson.isAcceptableOrUnknown(
          data['contact_person']!,
          _contactPersonMeta,
        ),
      );
    }
    if (data.containsKey('mobile')) {
      context.handle(
        _mobileMeta,
        mobile.isAcceptableOrUnknown(data['mobile']!, _mobileMeta),
      );
    }
    if (data.containsKey('address')) {
      context.handle(
        _addressMeta,
        address.isAcceptableOrUnknown(data['address']!, _addressMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SuppliersTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SuppliersTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      contactPerson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}contact_person'],
      ),
      mobile: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mobile'],
      ),
      address: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}address'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SuppliersTableTable createAlias(String alias) {
    return $SuppliersTableTable(attachedDatabase, alias);
  }
}

class SuppliersTableData extends DataClass
    implements Insertable<SuppliersTableData> {
  final String id;
  final String name;
  final String? contactPerson;
  final String? mobile;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  const SuppliersTableData({
    required this.id,
    required this.name,
    this.contactPerson,
    this.mobile,
    this.address,
    this.notes,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || contactPerson != null) {
      map['contact_person'] = Variable<String>(contactPerson);
    }
    if (!nullToAbsent || mobile != null) {
      map['mobile'] = Variable<String>(mobile);
    }
    if (!nullToAbsent || address != null) {
      map['address'] = Variable<String>(address);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SuppliersTableCompanion toCompanion(bool nullToAbsent) {
    return SuppliersTableCompanion(
      id: Value(id),
      name: Value(name),
      contactPerson: contactPerson == null && nullToAbsent
          ? const Value.absent()
          : Value(contactPerson),
      mobile: mobile == null && nullToAbsent
          ? const Value.absent()
          : Value(mobile),
      address: address == null && nullToAbsent
          ? const Value.absent()
          : Value(address),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
    );
  }

  factory SuppliersTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SuppliersTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      contactPerson: serializer.fromJson<String?>(json['contactPerson']),
      mobile: serializer.fromJson<String?>(json['mobile']),
      address: serializer.fromJson<String?>(json['address']),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'contactPerson': serializer.toJson<String?>(contactPerson),
      'mobile': serializer.toJson<String?>(mobile),
      'address': serializer.toJson<String?>(address),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SuppliersTableData copyWith({
    String? id,
    String? name,
    Value<String?> contactPerson = const Value.absent(),
    Value<String?> mobile = const Value.absent(),
    Value<String?> address = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
  }) => SuppliersTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    contactPerson: contactPerson.present
        ? contactPerson.value
        : this.contactPerson,
    mobile: mobile.present ? mobile.value : this.mobile,
    address: address.present ? address.value : this.address,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
  );
  SuppliersTableData copyWithCompanion(SuppliersTableCompanion data) {
    return SuppliersTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      contactPerson: data.contactPerson.present
          ? data.contactPerson.value
          : this.contactPerson,
      mobile: data.mobile.present ? data.mobile.value : this.mobile,
      address: data.address.present ? data.address.value : this.address,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('mobile: $mobile, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, contactPerson, mobile, address, notes, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SuppliersTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.contactPerson == this.contactPerson &&
          other.mobile == this.mobile &&
          other.address == this.address &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt);
}

class SuppliersTableCompanion extends UpdateCompanion<SuppliersTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> contactPerson;
  final Value<String?> mobile;
  final Value<String?> address;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SuppliersTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.contactPerson = const Value.absent(),
    this.mobile = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SuppliersTableCompanion.insert({
    required String id,
    required String name,
    this.contactPerson = const Value.absent(),
    this.mobile = const Value.absent(),
    this.address = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<SuppliersTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? contactPerson,
    Expression<String>? mobile,
    Expression<String>? address,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (contactPerson != null) 'contact_person': contactPerson,
      if (mobile != null) 'mobile': mobile,
      if (address != null) 'address': address,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SuppliersTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? contactPerson,
    Value<String?>? mobile,
    Value<String?>? address,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SuppliersTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      contactPerson: contactPerson ?? this.contactPerson,
      mobile: mobile ?? this.mobile,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (contactPerson.present) {
      map['contact_person'] = Variable<String>(contactPerson.value);
    }
    if (mobile.present) {
      map['mobile'] = Variable<String>(mobile.value);
    }
    if (address.present) {
      map['address'] = Variable<String>(address.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SuppliersTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('contactPerson: $contactPerson, ')
          ..write('mobile: $mobile, ')
          ..write('address: $address, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingsGoalsTableTable extends SavingsGoalsTable
    with TableInfo<$SavingsGoalsTableTable, SavingsGoalsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingsGoalsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetAmountMeta = const VerificationMeta(
    'targetAmount',
  );
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
    'target_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetDateMeta = const VerificationMeta(
    'targetDate',
  );
  @override
  late final GeneratedColumn<DateTime> targetDate = GeneratedColumn<DateTime>(
    'target_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    targetAmount,
    targetDate,
    notes,
    isActive,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'savings_goals';
  @override
  VerificationContext validateIntegrity(
    Insertable<SavingsGoalsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
        _targetAmountMeta,
        targetAmount.isAcceptableOrUnknown(
          data['target_amount']!,
          _targetAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('target_date')) {
      context.handle(
        _targetDateMeta,
        targetDate.isAcceptableOrUnknown(data['target_date']!, _targetDateMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingsGoalsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingsGoalsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      targetAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}target_amount'],
      )!,
      targetDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}target_date'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SavingsGoalsTableTable createAlias(String alias) {
    return $SavingsGoalsTableTable(attachedDatabase, alias);
  }
}

class SavingsGoalsTableData extends DataClass
    implements Insertable<SavingsGoalsTableData> {
  final String id;
  final String name;
  final double targetAmount;
  final DateTime? targetDate;
  final String? notes;
  final bool isActive;
  final DateTime createdAt;
  const SavingsGoalsTableData({
    required this.id,
    required this.name,
    required this.targetAmount,
    this.targetDate,
    this.notes,
    required this.isActive,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    if (!nullToAbsent || targetDate != null) {
      map['target_date'] = Variable<DateTime>(targetDate);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavingsGoalsTableCompanion toCompanion(bool nullToAbsent) {
    return SavingsGoalsTableCompanion(
      id: Value(id),
      name: Value(name),
      targetAmount: Value(targetAmount),
      targetDate: targetDate == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDate),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
    );
  }

  factory SavingsGoalsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingsGoalsTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      targetDate: serializer.fromJson<DateTime?>(json['targetDate']),
      notes: serializer.fromJson<String?>(json['notes']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'targetDate': serializer.toJson<DateTime?>(targetDate),
      'notes': serializer.toJson<String?>(notes),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavingsGoalsTableData copyWith({
    String? id,
    String? name,
    double? targetAmount,
    Value<DateTime?> targetDate = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
  }) => SavingsGoalsTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    targetAmount: targetAmount ?? this.targetAmount,
    targetDate: targetDate.present ? targetDate.value : this.targetDate,
    notes: notes.present ? notes.value : this.notes,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
  );
  SavingsGoalsTableData copyWithCompanion(SavingsGoalsTableCompanion data) {
    return SavingsGoalsTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      targetDate: data.targetDate.present
          ? data.targetDate.value
          : this.targetDate,
      notes: data.notes.present ? data.notes.value : this.notes,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    targetAmount,
    targetDate,
    notes,
    isActive,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingsGoalsTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.targetDate == this.targetDate &&
          other.notes == this.notes &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt);
}

class SavingsGoalsTableCompanion
    extends UpdateCompanion<SavingsGoalsTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<DateTime?> targetDate;
  final Value<String?> notes;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavingsGoalsTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.targetDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingsGoalsTableCompanion.insert({
    required String id,
    required String name,
    required double targetAmount,
    this.targetDate = const Value.absent(),
    this.notes = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       targetAmount = Value(targetAmount);
  static Insertable<SavingsGoalsTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<DateTime>? targetDate,
    Expression<String>? notes,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (targetDate != null) 'target_date': targetDate,
      if (notes != null) 'notes': notes,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingsGoalsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<double>? targetAmount,
    Value<DateTime?>? targetDate,
    Value<String?>? notes,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return SavingsGoalsTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      targetDate: targetDate ?? this.targetDate,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (targetDate.present) {
      map['target_date'] = Variable<DateTime>(targetDate.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingsGoalsTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('targetDate: $targetDate, ')
          ..write('notes: $notes, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryAuditsTableTable extends InventoryAuditsTable
    with TableInfo<$InventoryAuditsTableTable, InventoryAuditsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryAuditsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _auditDateMeta = const VerificationMeta(
    'auditDate',
  );
  @override
  late final GeneratedColumn<DateTime> auditDate = GeneratedColumn<DateTime>(
    'audit_date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _systemCountMeta = const VerificationMeta(
    'systemCount',
  );
  @override
  late final GeneratedColumn<int> systemCount = GeneratedColumn<int>(
    'system_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _physicalCountMeta = const VerificationMeta(
    'physicalCount',
  );
  @override
  late final GeneratedColumn<int> physicalCount = GeneratedColumn<int>(
    'physical_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _differenceMeta = const VerificationMeta(
    'difference',
  );
  @override
  late final GeneratedColumn<int> difference = GeneratedColumn<int>(
    'difference',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actionTakenMeta = const VerificationMeta(
    'actionTaken',
  );
  @override
  late final GeneratedColumn<String> actionTaken = GeneratedColumn<String>(
    'action_taken',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    auditDate,
    systemCount,
    physicalCount,
    difference,
    actionTaken,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_audits';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryAuditsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('audit_date')) {
      context.handle(
        _auditDateMeta,
        auditDate.isAcceptableOrUnknown(data['audit_date']!, _auditDateMeta),
      );
    }
    if (data.containsKey('system_count')) {
      context.handle(
        _systemCountMeta,
        systemCount.isAcceptableOrUnknown(
          data['system_count']!,
          _systemCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_systemCountMeta);
    }
    if (data.containsKey('physical_count')) {
      context.handle(
        _physicalCountMeta,
        physicalCount.isAcceptableOrUnknown(
          data['physical_count']!,
          _physicalCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_physicalCountMeta);
    }
    if (data.containsKey('difference')) {
      context.handle(
        _differenceMeta,
        difference.isAcceptableOrUnknown(data['difference']!, _differenceMeta),
      );
    } else if (isInserting) {
      context.missing(_differenceMeta);
    }
    if (data.containsKey('action_taken')) {
      context.handle(
        _actionTakenMeta,
        actionTaken.isAcceptableOrUnknown(
          data['action_taken']!,
          _actionTakenMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actionTakenMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryAuditsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryAuditsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      auditDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}audit_date'],
      )!,
      systemCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}system_count'],
      )!,
      physicalCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}physical_count'],
      )!,
      difference: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difference'],
      )!,
      actionTaken: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}action_taken'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $InventoryAuditsTableTable createAlias(String alias) {
    return $InventoryAuditsTableTable(attachedDatabase, alias);
  }
}

class InventoryAuditsTableData extends DataClass
    implements Insertable<InventoryAuditsTableData> {
  final String id;
  final DateTime auditDate;
  final int systemCount;
  final int physicalCount;
  final int difference;
  final String actionTaken;
  final String? notes;
  const InventoryAuditsTableData({
    required this.id,
    required this.auditDate,
    required this.systemCount,
    required this.physicalCount,
    required this.difference,
    required this.actionTaken,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['audit_date'] = Variable<DateTime>(auditDate);
    map['system_count'] = Variable<int>(systemCount);
    map['physical_count'] = Variable<int>(physicalCount);
    map['difference'] = Variable<int>(difference);
    map['action_taken'] = Variable<String>(actionTaken);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InventoryAuditsTableCompanion toCompanion(bool nullToAbsent) {
    return InventoryAuditsTableCompanion(
      id: Value(id),
      auditDate: Value(auditDate),
      systemCount: Value(systemCount),
      physicalCount: Value(physicalCount),
      difference: Value(difference),
      actionTaken: Value(actionTaken),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory InventoryAuditsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryAuditsTableData(
      id: serializer.fromJson<String>(json['id']),
      auditDate: serializer.fromJson<DateTime>(json['auditDate']),
      systemCount: serializer.fromJson<int>(json['systemCount']),
      physicalCount: serializer.fromJson<int>(json['physicalCount']),
      difference: serializer.fromJson<int>(json['difference']),
      actionTaken: serializer.fromJson<String>(json['actionTaken']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'auditDate': serializer.toJson<DateTime>(auditDate),
      'systemCount': serializer.toJson<int>(systemCount),
      'physicalCount': serializer.toJson<int>(physicalCount),
      'difference': serializer.toJson<int>(difference),
      'actionTaken': serializer.toJson<String>(actionTaken),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InventoryAuditsTableData copyWith({
    String? id,
    DateTime? auditDate,
    int? systemCount,
    int? physicalCount,
    int? difference,
    String? actionTaken,
    Value<String?> notes = const Value.absent(),
  }) => InventoryAuditsTableData(
    id: id ?? this.id,
    auditDate: auditDate ?? this.auditDate,
    systemCount: systemCount ?? this.systemCount,
    physicalCount: physicalCount ?? this.physicalCount,
    difference: difference ?? this.difference,
    actionTaken: actionTaken ?? this.actionTaken,
    notes: notes.present ? notes.value : this.notes,
  );
  InventoryAuditsTableData copyWithCompanion(
    InventoryAuditsTableCompanion data,
  ) {
    return InventoryAuditsTableData(
      id: data.id.present ? data.id.value : this.id,
      auditDate: data.auditDate.present ? data.auditDate.value : this.auditDate,
      systemCount: data.systemCount.present
          ? data.systemCount.value
          : this.systemCount,
      physicalCount: data.physicalCount.present
          ? data.physicalCount.value
          : this.physicalCount,
      difference: data.difference.present
          ? data.difference.value
          : this.difference,
      actionTaken: data.actionTaken.present
          ? data.actionTaken.value
          : this.actionTaken,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAuditsTableData(')
          ..write('id: $id, ')
          ..write('auditDate: $auditDate, ')
          ..write('systemCount: $systemCount, ')
          ..write('physicalCount: $physicalCount, ')
          ..write('difference: $difference, ')
          ..write('actionTaken: $actionTaken, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    auditDate,
    systemCount,
    physicalCount,
    difference,
    actionTaken,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryAuditsTableData &&
          other.id == this.id &&
          other.auditDate == this.auditDate &&
          other.systemCount == this.systemCount &&
          other.physicalCount == this.physicalCount &&
          other.difference == this.difference &&
          other.actionTaken == this.actionTaken &&
          other.notes == this.notes);
}

class InventoryAuditsTableCompanion
    extends UpdateCompanion<InventoryAuditsTableData> {
  final Value<String> id;
  final Value<DateTime> auditDate;
  final Value<int> systemCount;
  final Value<int> physicalCount;
  final Value<int> difference;
  final Value<String> actionTaken;
  final Value<String?> notes;
  final Value<int> rowid;
  const InventoryAuditsTableCompanion({
    this.id = const Value.absent(),
    this.auditDate = const Value.absent(),
    this.systemCount = const Value.absent(),
    this.physicalCount = const Value.absent(),
    this.difference = const Value.absent(),
    this.actionTaken = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryAuditsTableCompanion.insert({
    required String id,
    this.auditDate = const Value.absent(),
    required int systemCount,
    required int physicalCount,
    required int difference,
    required String actionTaken,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       systemCount = Value(systemCount),
       physicalCount = Value(physicalCount),
       difference = Value(difference),
       actionTaken = Value(actionTaken);
  static Insertable<InventoryAuditsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? auditDate,
    Expression<int>? systemCount,
    Expression<int>? physicalCount,
    Expression<int>? difference,
    Expression<String>? actionTaken,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (auditDate != null) 'audit_date': auditDate,
      if (systemCount != null) 'system_count': systemCount,
      if (physicalCount != null) 'physical_count': physicalCount,
      if (difference != null) 'difference': difference,
      if (actionTaken != null) 'action_taken': actionTaken,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryAuditsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? auditDate,
    Value<int>? systemCount,
    Value<int>? physicalCount,
    Value<int>? difference,
    Value<String>? actionTaken,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return InventoryAuditsTableCompanion(
      id: id ?? this.id,
      auditDate: auditDate ?? this.auditDate,
      systemCount: systemCount ?? this.systemCount,
      physicalCount: physicalCount ?? this.physicalCount,
      difference: difference ?? this.difference,
      actionTaken: actionTaken ?? this.actionTaken,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (auditDate.present) {
      map['audit_date'] = Variable<DateTime>(auditDate.value);
    }
    if (systemCount.present) {
      map['system_count'] = Variable<int>(systemCount.value);
    }
    if (physicalCount.present) {
      map['physical_count'] = Variable<int>(physicalCount.value);
    }
    if (difference.present) {
      map['difference'] = Variable<int>(difference.value);
    }
    if (actionTaken.present) {
      map['action_taken'] = Variable<String>(actionTaken.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAuditsTableCompanion(')
          ..write('id: $id, ')
          ..write('auditDate: $auditDate, ')
          ..write('systemCount: $systemCount, ')
          ..write('physicalCount: $physicalCount, ')
          ..write('difference: $difference, ')
          ..write('actionTaken: $actionTaken, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $InventoryAdjustmentsTableTable extends InventoryAdjustmentsTable
    with
        TableInfo<
          $InventoryAdjustmentsTableTable,
          InventoryAdjustmentsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InventoryAdjustmentsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _adjustmentDateMeta = const VerificationMeta(
    'adjustmentDate',
  );
  @override
  late final GeneratedColumn<DateTime> adjustmentDate =
      GeneratedColumn<DateTime>(
        'adjustment_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
        defaultValue: currentDateAndTime,
      );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    adjustmentDate,
    quantity,
    reason,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inventory_adjustments';
  @override
  VerificationContext validateIntegrity(
    Insertable<InventoryAdjustmentsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('adjustment_date')) {
      context.handle(
        _adjustmentDateMeta,
        adjustmentDate.isAcceptableOrUnknown(
          data['adjustment_date']!,
          _adjustmentDateMeta,
        ),
      );
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    } else if (isInserting) {
      context.missing(_quantityMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    } else if (isInserting) {
      context.missing(_reasonMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InventoryAdjustmentsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InventoryAdjustmentsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      adjustmentDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}adjustment_date'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $InventoryAdjustmentsTableTable createAlias(String alias) {
    return $InventoryAdjustmentsTableTable(attachedDatabase, alias);
  }
}

class InventoryAdjustmentsTableData extends DataClass
    implements Insertable<InventoryAdjustmentsTableData> {
  final String id;
  final DateTime adjustmentDate;
  final int quantity;
  final String reason;
  final String? notes;
  const InventoryAdjustmentsTableData({
    required this.id,
    required this.adjustmentDate,
    required this.quantity,
    required this.reason,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['adjustment_date'] = Variable<DateTime>(adjustmentDate);
    map['quantity'] = Variable<int>(quantity);
    map['reason'] = Variable<String>(reason);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  InventoryAdjustmentsTableCompanion toCompanion(bool nullToAbsent) {
    return InventoryAdjustmentsTableCompanion(
      id: Value(id),
      adjustmentDate: Value(adjustmentDate),
      quantity: Value(quantity),
      reason: Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory InventoryAdjustmentsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InventoryAdjustmentsTableData(
      id: serializer.fromJson<String>(json['id']),
      adjustmentDate: serializer.fromJson<DateTime>(json['adjustmentDate']),
      quantity: serializer.fromJson<int>(json['quantity']),
      reason: serializer.fromJson<String>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'adjustmentDate': serializer.toJson<DateTime>(adjustmentDate),
      'quantity': serializer.toJson<int>(quantity),
      'reason': serializer.toJson<String>(reason),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  InventoryAdjustmentsTableData copyWith({
    String? id,
    DateTime? adjustmentDate,
    int? quantity,
    String? reason,
    Value<String?> notes = const Value.absent(),
  }) => InventoryAdjustmentsTableData(
    id: id ?? this.id,
    adjustmentDate: adjustmentDate ?? this.adjustmentDate,
    quantity: quantity ?? this.quantity,
    reason: reason ?? this.reason,
    notes: notes.present ? notes.value : this.notes,
  );
  InventoryAdjustmentsTableData copyWithCompanion(
    InventoryAdjustmentsTableCompanion data,
  ) {
    return InventoryAdjustmentsTableData(
      id: data.id.present ? data.id.value : this.id,
      adjustmentDate: data.adjustmentDate.present
          ? data.adjustmentDate.value
          : this.adjustmentDate,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAdjustmentsTableData(')
          ..write('id: $id, ')
          ..write('adjustmentDate: $adjustmentDate, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, adjustmentDate, quantity, reason, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InventoryAdjustmentsTableData &&
          other.id == this.id &&
          other.adjustmentDate == this.adjustmentDate &&
          other.quantity == this.quantity &&
          other.reason == this.reason &&
          other.notes == this.notes);
}

class InventoryAdjustmentsTableCompanion
    extends UpdateCompanion<InventoryAdjustmentsTableData> {
  final Value<String> id;
  final Value<DateTime> adjustmentDate;
  final Value<int> quantity;
  final Value<String> reason;
  final Value<String?> notes;
  final Value<int> rowid;
  const InventoryAdjustmentsTableCompanion({
    this.id = const Value.absent(),
    this.adjustmentDate = const Value.absent(),
    this.quantity = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  InventoryAdjustmentsTableCompanion.insert({
    required String id,
    this.adjustmentDate = const Value.absent(),
    required int quantity,
    required String reason,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       quantity = Value(quantity),
       reason = Value(reason);
  static Insertable<InventoryAdjustmentsTableData> custom({
    Expression<String>? id,
    Expression<DateTime>? adjustmentDate,
    Expression<int>? quantity,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (adjustmentDate != null) 'adjustment_date': adjustmentDate,
      if (quantity != null) 'quantity': quantity,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  InventoryAdjustmentsTableCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? adjustmentDate,
    Value<int>? quantity,
    Value<String>? reason,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return InventoryAdjustmentsTableCompanion(
      id: id ?? this.id,
      adjustmentDate: adjustmentDate ?? this.adjustmentDate,
      quantity: quantity ?? this.quantity,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (adjustmentDate.present) {
      map['adjustment_date'] = Variable<DateTime>(adjustmentDate.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InventoryAdjustmentsTableCompanion(')
          ..write('id: $id, ')
          ..write('adjustmentDate: $adjustmentDate, ')
          ..write('quantity: $quantity, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerDepositsTableTable extends CustomerDepositsTable
    with TableInfo<$CustomerDepositsTableTable, CustomerDepositsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerDepositsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
    'amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _transactionTypeMeta = const VerificationMeta(
    'transactionType',
  );
  @override
  late final GeneratedColumn<String> transactionType = GeneratedColumn<String>(
    'transaction_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<String> deliveryId = GeneratedColumn<String>(
    'delivery_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    amount,
    transactionType,
    createdAt,
    notes,
    deliveryId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_deposits';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerDepositsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(
        _amountMeta,
        amount.isAcceptableOrUnknown(data['amount']!, _amountMeta),
      );
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('transaction_type')) {
      context.handle(
        _transactionTypeMeta,
        transactionType.isAcceptableOrUnknown(
          data['transaction_type']!,
          _transactionTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_transactionTypeMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerDepositsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerDepositsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      amount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}amount'],
      )!,
      transactionType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}transaction_type'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_id'],
      ),
    );
  }

  @override
  $CustomerDepositsTableTable createAlias(String alias) {
    return $CustomerDepositsTableTable(attachedDatabase, alias);
  }
}

class CustomerDepositsTableData extends DataClass
    implements Insertable<CustomerDepositsTableData> {
  final String id;
  final String customerId;
  final double amount;
  final String transactionType;
  final DateTime createdAt;
  final String? notes;
  final String? deliveryId;
  const CustomerDepositsTableData({
    required this.id,
    required this.customerId,
    required this.amount,
    required this.transactionType,
    required this.createdAt,
    this.notes,
    this.deliveryId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['amount'] = Variable<double>(amount);
    map['transaction_type'] = Variable<String>(transactionType);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || deliveryId != null) {
      map['delivery_id'] = Variable<String>(deliveryId);
    }
    return map;
  }

  CustomerDepositsTableCompanion toCompanion(bool nullToAbsent) {
    return CustomerDepositsTableCompanion(
      id: Value(id),
      customerId: Value(customerId),
      amount: Value(amount),
      transactionType: Value(transactionType),
      createdAt: Value(createdAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deliveryId: deliveryId == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryId),
    );
  }

  factory CustomerDepositsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerDepositsTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      amount: serializer.fromJson<double>(json['amount']),
      transactionType: serializer.fromJson<String>(json['transactionType']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      notes: serializer.fromJson<String?>(json['notes']),
      deliveryId: serializer.fromJson<String?>(json['deliveryId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'amount': serializer.toJson<double>(amount),
      'transactionType': serializer.toJson<String>(transactionType),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'notes': serializer.toJson<String?>(notes),
      'deliveryId': serializer.toJson<String?>(deliveryId),
    };
  }

  CustomerDepositsTableData copyWith({
    String? id,
    String? customerId,
    double? amount,
    String? transactionType,
    DateTime? createdAt,
    Value<String?> notes = const Value.absent(),
    Value<String?> deliveryId = const Value.absent(),
  }) => CustomerDepositsTableData(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    amount: amount ?? this.amount,
    transactionType: transactionType ?? this.transactionType,
    createdAt: createdAt ?? this.createdAt,
    notes: notes.present ? notes.value : this.notes,
    deliveryId: deliveryId.present ? deliveryId.value : this.deliveryId,
  );
  CustomerDepositsTableData copyWithCompanion(
    CustomerDepositsTableCompanion data,
  ) {
    return CustomerDepositsTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      amount: data.amount.present ? data.amount.value : this.amount,
      transactionType: data.transactionType.present
          ? data.transactionType.value
          : this.transactionType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      notes: data.notes.present ? data.notes.value : this.notes,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDepositsTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('amount: $amount, ')
          ..write('transactionType: $transactionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes, ')
          ..write('deliveryId: $deliveryId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    amount,
    transactionType,
    createdAt,
    notes,
    deliveryId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerDepositsTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.amount == this.amount &&
          other.transactionType == this.transactionType &&
          other.createdAt == this.createdAt &&
          other.notes == this.notes &&
          other.deliveryId == this.deliveryId);
}

class CustomerDepositsTableCompanion
    extends UpdateCompanion<CustomerDepositsTableData> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<double> amount;
  final Value<String> transactionType;
  final Value<DateTime> createdAt;
  final Value<String?> notes;
  final Value<String?> deliveryId;
  final Value<int> rowid;
  const CustomerDepositsTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.amount = const Value.absent(),
    this.transactionType = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerDepositsTableCompanion.insert({
    required String id,
    required String customerId,
    required double amount,
    required String transactionType,
    this.createdAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       amount = Value(amount),
       transactionType = Value(transactionType);
  static Insertable<CustomerDepositsTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<double>? amount,
    Expression<String>? transactionType,
    Expression<DateTime>? createdAt,
    Expression<String>? notes,
    Expression<String>? deliveryId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (amount != null) 'amount': amount,
      if (transactionType != null) 'transaction_type': transactionType,
      if (createdAt != null) 'created_at': createdAt,
      if (notes != null) 'notes': notes,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerDepositsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<double>? amount,
    Value<String>? transactionType,
    Value<DateTime>? createdAt,
    Value<String?>? notes,
    Value<String?>? deliveryId,
    Value<int>? rowid,
  }) {
    return CustomerDepositsTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      amount: amount ?? this.amount,
      transactionType: transactionType ?? this.transactionType,
      createdAt: createdAt ?? this.createdAt,
      notes: notes ?? this.notes,
      deliveryId: deliveryId ?? this.deliveryId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (transactionType.present) {
      map['transaction_type'] = Variable<String>(transactionType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<String>(deliveryId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerDepositsTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('amount: $amount, ')
          ..write('transactionType: $transactionType, ')
          ..write('createdAt: $createdAt, ')
          ..write('notes: $notes, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CopilotMessagesTableTable extends CopilotMessagesTable
    with TableInfo<$CopilotMessagesTableTable, CopilotMessagesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CopilotMessagesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _intentMeta = const VerificationMeta('intent');
  @override
  late final GeneratedColumn<String> intent = GeneratedColumn<String>(
    'intent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    question,
    answer,
    intent,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'copilot_messages';
  @override
  VerificationContext validateIntegrity(
    Insertable<CopilotMessagesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('intent')) {
      context.handle(
        _intentMeta,
        intent.isAcceptableOrUnknown(data['intent']!, _intentMeta),
      );
    } else if (isInserting) {
      context.missing(_intentMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CopilotMessagesTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CopilotMessagesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      intent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}intent'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CopilotMessagesTableTable createAlias(String alias) {
    return $CopilotMessagesTableTable(attachedDatabase, alias);
  }
}

class CopilotMessagesTableData extends DataClass
    implements Insertable<CopilotMessagesTableData> {
  final int id;
  final String question;
  final String answer;
  final String intent;
  final int createdAt;
  const CopilotMessagesTableData({
    required this.id,
    required this.question,
    required this.answer,
    required this.intent,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['question'] = Variable<String>(question);
    map['answer'] = Variable<String>(answer);
    map['intent'] = Variable<String>(intent);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  CopilotMessagesTableCompanion toCompanion(bool nullToAbsent) {
    return CopilotMessagesTableCompanion(
      id: Value(id),
      question: Value(question),
      answer: Value(answer),
      intent: Value(intent),
      createdAt: Value(createdAt),
    );
  }

  factory CopilotMessagesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CopilotMessagesTableData(
      id: serializer.fromJson<int>(json['id']),
      question: serializer.fromJson<String>(json['question']),
      answer: serializer.fromJson<String>(json['answer']),
      intent: serializer.fromJson<String>(json['intent']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'question': serializer.toJson<String>(question),
      'answer': serializer.toJson<String>(answer),
      'intent': serializer.toJson<String>(intent),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  CopilotMessagesTableData copyWith({
    int? id,
    String? question,
    String? answer,
    String? intent,
    int? createdAt,
  }) => CopilotMessagesTableData(
    id: id ?? this.id,
    question: question ?? this.question,
    answer: answer ?? this.answer,
    intent: intent ?? this.intent,
    createdAt: createdAt ?? this.createdAt,
  );
  CopilotMessagesTableData copyWithCompanion(
    CopilotMessagesTableCompanion data,
  ) {
    return CopilotMessagesTableData(
      id: data.id.present ? data.id.value : this.id,
      question: data.question.present ? data.question.value : this.question,
      answer: data.answer.present ? data.answer.value : this.answer,
      intent: data.intent.present ? data.intent.value : this.intent,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CopilotMessagesTableData(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('answer: $answer, ')
          ..write('intent: $intent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, question, answer, intent, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CopilotMessagesTableData &&
          other.id == this.id &&
          other.question == this.question &&
          other.answer == this.answer &&
          other.intent == this.intent &&
          other.createdAt == this.createdAt);
}

class CopilotMessagesTableCompanion
    extends UpdateCompanion<CopilotMessagesTableData> {
  final Value<int> id;
  final Value<String> question;
  final Value<String> answer;
  final Value<String> intent;
  final Value<int> createdAt;
  const CopilotMessagesTableCompanion({
    this.id = const Value.absent(),
    this.question = const Value.absent(),
    this.answer = const Value.absent(),
    this.intent = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  CopilotMessagesTableCompanion.insert({
    this.id = const Value.absent(),
    required String question,
    required String answer,
    required String intent,
    required int createdAt,
  }) : question = Value(question),
       answer = Value(answer),
       intent = Value(intent),
       createdAt = Value(createdAt);
  static Insertable<CopilotMessagesTableData> custom({
    Expression<int>? id,
    Expression<String>? question,
    Expression<String>? answer,
    Expression<String>? intent,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (question != null) 'question': question,
      if (answer != null) 'answer': answer,
      if (intent != null) 'intent': intent,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  CopilotMessagesTableCompanion copyWith({
    Value<int>? id,
    Value<String>? question,
    Value<String>? answer,
    Value<String>? intent,
    Value<int>? createdAt,
  }) {
    return CopilotMessagesTableCompanion(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      intent: intent ?? this.intent,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (intent.present) {
      map['intent'] = Variable<String>(intent.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CopilotMessagesTableCompanion(')
          ..write('id: $id, ')
          ..write('question: $question, ')
          ..write('answer: $answer, ')
          ..write('intent: $intent, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $CustomerBottleReconciliationsTableTable
    extends CustomerBottleReconciliationsTable
    with
        TableInfo<
          $CustomerBottleReconciliationsTableTable,
          CustomerBottleReconciliationsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerBottleReconciliationsTableTable(
    this.attachedDatabase, [
    this._alias,
  ]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _expectedCountMeta = const VerificationMeta(
    'expectedCount',
  );
  @override
  late final GeneratedColumn<int> expectedCount = GeneratedColumn<int>(
    'expected_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _actualCountMeta = const VerificationMeta(
    'actualCount',
  );
  @override
  late final GeneratedColumn<int> actualCount = GeneratedColumn<int>(
    'actual_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _varianceMeta = const VerificationMeta(
    'variance',
  );
  @override
  late final GeneratedColumn<int> variance = GeneratedColumn<int>(
    'variance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _reasonMeta = const VerificationMeta('reason');
  @override
  late final GeneratedColumn<String> reason = GeneratedColumn<String>(
    'reason',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _adjustmentAppliedMeta = const VerificationMeta(
    'adjustmentApplied',
  );
  @override
  late final GeneratedColumn<bool> adjustmentApplied = GeneratedColumn<bool>(
    'adjustment_applied',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("adjustment_applied" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    expectedCount,
    actualCount,
    variance,
    reason,
    notes,
    adjustmentApplied,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_bottle_reconciliations';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerBottleReconciliationsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('expected_count')) {
      context.handle(
        _expectedCountMeta,
        expectedCount.isAcceptableOrUnknown(
          data['expected_count']!,
          _expectedCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_expectedCountMeta);
    }
    if (data.containsKey('actual_count')) {
      context.handle(
        _actualCountMeta,
        actualCount.isAcceptableOrUnknown(
          data['actual_count']!,
          _actualCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_actualCountMeta);
    }
    if (data.containsKey('variance')) {
      context.handle(
        _varianceMeta,
        variance.isAcceptableOrUnknown(data['variance']!, _varianceMeta),
      );
    } else if (isInserting) {
      context.missing(_varianceMeta);
    }
    if (data.containsKey('reason')) {
      context.handle(
        _reasonMeta,
        reason.isAcceptableOrUnknown(data['reason']!, _reasonMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('adjustment_applied')) {
      context.handle(
        _adjustmentAppliedMeta,
        adjustmentApplied.isAcceptableOrUnknown(
          data['adjustment_applied']!,
          _adjustmentAppliedMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerBottleReconciliationsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerBottleReconciliationsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      expectedCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}expected_count'],
      )!,
      actualCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}actual_count'],
      )!,
      variance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}variance'],
      )!,
      reason: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reason'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      adjustmentApplied: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}adjustment_applied'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $CustomerBottleReconciliationsTableTable createAlias(String alias) {
    return $CustomerBottleReconciliationsTableTable(attachedDatabase, alias);
  }
}

class CustomerBottleReconciliationsTableData extends DataClass
    implements Insertable<CustomerBottleReconciliationsTableData> {
  final String id;
  final String customerId;
  final int expectedCount;
  final int actualCount;
  final int variance;
  final String? reason;
  final String? notes;
  final bool adjustmentApplied;
  final DateTime createdAt;
  const CustomerBottleReconciliationsTableData({
    required this.id,
    required this.customerId,
    required this.expectedCount,
    required this.actualCount,
    required this.variance,
    this.reason,
    this.notes,
    required this.adjustmentApplied,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['expected_count'] = Variable<int>(expectedCount);
    map['actual_count'] = Variable<int>(actualCount);
    map['variance'] = Variable<int>(variance);
    if (!nullToAbsent || reason != null) {
      map['reason'] = Variable<String>(reason);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['adjustment_applied'] = Variable<bool>(adjustmentApplied);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  CustomerBottleReconciliationsTableCompanion toCompanion(bool nullToAbsent) {
    return CustomerBottleReconciliationsTableCompanion(
      id: Value(id),
      customerId: Value(customerId),
      expectedCount: Value(expectedCount),
      actualCount: Value(actualCount),
      variance: Value(variance),
      reason: reason == null && nullToAbsent
          ? const Value.absent()
          : Value(reason),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      adjustmentApplied: Value(adjustmentApplied),
      createdAt: Value(createdAt),
    );
  }

  factory CustomerBottleReconciliationsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerBottleReconciliationsTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      expectedCount: serializer.fromJson<int>(json['expectedCount']),
      actualCount: serializer.fromJson<int>(json['actualCount']),
      variance: serializer.fromJson<int>(json['variance']),
      reason: serializer.fromJson<String?>(json['reason']),
      notes: serializer.fromJson<String?>(json['notes']),
      adjustmentApplied: serializer.fromJson<bool>(json['adjustmentApplied']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'expectedCount': serializer.toJson<int>(expectedCount),
      'actualCount': serializer.toJson<int>(actualCount),
      'variance': serializer.toJson<int>(variance),
      'reason': serializer.toJson<String?>(reason),
      'notes': serializer.toJson<String?>(notes),
      'adjustmentApplied': serializer.toJson<bool>(adjustmentApplied),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  CustomerBottleReconciliationsTableData copyWith({
    String? id,
    String? customerId,
    int? expectedCount,
    int? actualCount,
    int? variance,
    Value<String?> reason = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    bool? adjustmentApplied,
    DateTime? createdAt,
  }) => CustomerBottleReconciliationsTableData(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    expectedCount: expectedCount ?? this.expectedCount,
    actualCount: actualCount ?? this.actualCount,
    variance: variance ?? this.variance,
    reason: reason.present ? reason.value : this.reason,
    notes: notes.present ? notes.value : this.notes,
    adjustmentApplied: adjustmentApplied ?? this.adjustmentApplied,
    createdAt: createdAt ?? this.createdAt,
  );
  CustomerBottleReconciliationsTableData copyWithCompanion(
    CustomerBottleReconciliationsTableCompanion data,
  ) {
    return CustomerBottleReconciliationsTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      expectedCount: data.expectedCount.present
          ? data.expectedCount.value
          : this.expectedCount,
      actualCount: data.actualCount.present
          ? data.actualCount.value
          : this.actualCount,
      variance: data.variance.present ? data.variance.value : this.variance,
      reason: data.reason.present ? data.reason.value : this.reason,
      notes: data.notes.present ? data.notes.value : this.notes,
      adjustmentApplied: data.adjustmentApplied.present
          ? data.adjustmentApplied.value
          : this.adjustmentApplied,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerBottleReconciliationsTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('expectedCount: $expectedCount, ')
          ..write('actualCount: $actualCount, ')
          ..write('variance: $variance, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('adjustmentApplied: $adjustmentApplied, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    expectedCount,
    actualCount,
    variance,
    reason,
    notes,
    adjustmentApplied,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerBottleReconciliationsTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.expectedCount == this.expectedCount &&
          other.actualCount == this.actualCount &&
          other.variance == this.variance &&
          other.reason == this.reason &&
          other.notes == this.notes &&
          other.adjustmentApplied == this.adjustmentApplied &&
          other.createdAt == this.createdAt);
}

class CustomerBottleReconciliationsTableCompanion
    extends UpdateCompanion<CustomerBottleReconciliationsTableData> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<int> expectedCount;
  final Value<int> actualCount;
  final Value<int> variance;
  final Value<String?> reason;
  final Value<String?> notes;
  final Value<bool> adjustmentApplied;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const CustomerBottleReconciliationsTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.expectedCount = const Value.absent(),
    this.actualCount = const Value.absent(),
    this.variance = const Value.absent(),
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.adjustmentApplied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerBottleReconciliationsTableCompanion.insert({
    required String id,
    required String customerId,
    required int expectedCount,
    required int actualCount,
    required int variance,
    this.reason = const Value.absent(),
    this.notes = const Value.absent(),
    this.adjustmentApplied = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       expectedCount = Value(expectedCount),
       actualCount = Value(actualCount),
       variance = Value(variance);
  static Insertable<CustomerBottleReconciliationsTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<int>? expectedCount,
    Expression<int>? actualCount,
    Expression<int>? variance,
    Expression<String>? reason,
    Expression<String>? notes,
    Expression<bool>? adjustmentApplied,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (expectedCount != null) 'expected_count': expectedCount,
      if (actualCount != null) 'actual_count': actualCount,
      if (variance != null) 'variance': variance,
      if (reason != null) 'reason': reason,
      if (notes != null) 'notes': notes,
      if (adjustmentApplied != null) 'adjustment_applied': adjustmentApplied,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerBottleReconciliationsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<int>? expectedCount,
    Value<int>? actualCount,
    Value<int>? variance,
    Value<String?>? reason,
    Value<String?>? notes,
    Value<bool>? adjustmentApplied,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return CustomerBottleReconciliationsTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      expectedCount: expectedCount ?? this.expectedCount,
      actualCount: actualCount ?? this.actualCount,
      variance: variance ?? this.variance,
      reason: reason ?? this.reason,
      notes: notes ?? this.notes,
      adjustmentApplied: adjustmentApplied ?? this.adjustmentApplied,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (expectedCount.present) {
      map['expected_count'] = Variable<int>(expectedCount.value);
    }
    if (actualCount.present) {
      map['actual_count'] = Variable<int>(actualCount.value);
    }
    if (variance.present) {
      map['variance'] = Variable<int>(variance.value);
    }
    if (reason.present) {
      map['reason'] = Variable<String>(reason.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (adjustmentApplied.present) {
      map['adjustment_applied'] = Variable<bool>(adjustmentApplied.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerBottleReconciliationsTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('expectedCount: $expectedCount, ')
          ..write('actualCount: $actualCount, ')
          ..write('variance: $variance, ')
          ..write('reason: $reason, ')
          ..write('notes: $notes, ')
          ..write('adjustmentApplied: $adjustmentApplied, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $CustomerOwnedBottleLogsTableTable extends CustomerOwnedBottleLogsTable
    with
        TableInfo<
          $CustomerOwnedBottleLogsTableTable,
          CustomerOwnedBottleLogsTableData
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CustomerOwnedBottleLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _eventTypeMeta = const VerificationMeta(
    'eventType',
  );
  @override
  late final GeneratedColumn<String> eventType = GeneratedColumn<String>(
    'event_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessOwnedDeltaMeta =
      const VerificationMeta('businessOwnedDelta');
  @override
  late final GeneratedColumn<int> businessOwnedDelta = GeneratedColumn<int>(
    'business_owned_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _customerOwnedDeltaMeta =
      const VerificationMeta('customerOwnedDelta');
  @override
  late final GeneratedColumn<int> customerOwnedDelta = GeneratedColumn<int>(
    'customer_owned_delta',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _businessOwnedAfterMeta =
      const VerificationMeta('businessOwnedAfter');
  @override
  late final GeneratedColumn<int> businessOwnedAfter = GeneratedColumn<int>(
    'business_owned_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerOwnedAfterMeta =
      const VerificationMeta('customerOwnedAfter');
  @override
  late final GeneratedColumn<int> customerOwnedAfter = GeneratedColumn<int>(
    'customer_owned_after',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _deliveryIdMeta = const VerificationMeta(
    'deliveryId',
  );
  @override
  late final GeneratedColumn<String> deliveryId = GeneratedColumn<String>(
    'delivery_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _bottleTransactionIdMeta =
      const VerificationMeta('bottleTransactionId');
  @override
  late final GeneratedColumn<String> bottleTransactionId =
      GeneratedColumn<String>(
        'bottle_transaction_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    eventType,
    businessOwnedDelta,
    customerOwnedDelta,
    businessOwnedAfter,
    customerOwnedAfter,
    date,
    notes,
    deliveryId,
    bottleTransactionId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'customer_owned_bottle_logs';
  @override
  VerificationContext validateIntegrity(
    Insertable<CustomerOwnedBottleLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    } else if (isInserting) {
      context.missing(_customerIdMeta);
    }
    if (data.containsKey('event_type')) {
      context.handle(
        _eventTypeMeta,
        eventType.isAcceptableOrUnknown(data['event_type']!, _eventTypeMeta),
      );
    } else if (isInserting) {
      context.missing(_eventTypeMeta);
    }
    if (data.containsKey('business_owned_delta')) {
      context.handle(
        _businessOwnedDeltaMeta,
        businessOwnedDelta.isAcceptableOrUnknown(
          data['business_owned_delta']!,
          _businessOwnedDeltaMeta,
        ),
      );
    }
    if (data.containsKey('customer_owned_delta')) {
      context.handle(
        _customerOwnedDeltaMeta,
        customerOwnedDelta.isAcceptableOrUnknown(
          data['customer_owned_delta']!,
          _customerOwnedDeltaMeta,
        ),
      );
    }
    if (data.containsKey('business_owned_after')) {
      context.handle(
        _businessOwnedAfterMeta,
        businessOwnedAfter.isAcceptableOrUnknown(
          data['business_owned_after']!,
          _businessOwnedAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_businessOwnedAfterMeta);
    }
    if (data.containsKey('customer_owned_after')) {
      context.handle(
        _customerOwnedAfterMeta,
        customerOwnedAfter.isAcceptableOrUnknown(
          data['customer_owned_after']!,
          _customerOwnedAfterMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_customerOwnedAfterMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('delivery_id')) {
      context.handle(
        _deliveryIdMeta,
        deliveryId.isAcceptableOrUnknown(data['delivery_id']!, _deliveryIdMeta),
      );
    }
    if (data.containsKey('bottle_transaction_id')) {
      context.handle(
        _bottleTransactionIdMeta,
        bottleTransactionId.isAcceptableOrUnknown(
          data['bottle_transaction_id']!,
          _bottleTransactionIdMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CustomerOwnedBottleLogsTableData map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CustomerOwnedBottleLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      )!,
      eventType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_type'],
      )!,
      businessOwnedDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_owned_delta'],
      )!,
      customerOwnedDelta: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_owned_delta'],
      )!,
      businessOwnedAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_owned_after'],
      )!,
      customerOwnedAfter: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_owned_after'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      deliveryId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}delivery_id'],
      ),
      bottleTransactionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}bottle_transaction_id'],
      ),
    );
  }

  @override
  $CustomerOwnedBottleLogsTableTable createAlias(String alias) {
    return $CustomerOwnedBottleLogsTableTable(attachedDatabase, alias);
  }
}

class CustomerOwnedBottleLogsTableData extends DataClass
    implements Insertable<CustomerOwnedBottleLogsTableData> {
  final String id;
  final String customerId;

  /// set_balance | adjust_balance | collected | delivery_filled
  final String eventType;
  final int businessOwnedDelta;
  final int customerOwnedDelta;
  final int businessOwnedAfter;
  final int customerOwnedAfter;
  final DateTime date;
  final String? notes;
  final String? deliveryId;
  final String? bottleTransactionId;
  const CustomerOwnedBottleLogsTableData({
    required this.id,
    required this.customerId,
    required this.eventType,
    required this.businessOwnedDelta,
    required this.customerOwnedDelta,
    required this.businessOwnedAfter,
    required this.customerOwnedAfter,
    required this.date,
    this.notes,
    this.deliveryId,
    this.bottleTransactionId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['customer_id'] = Variable<String>(customerId);
    map['event_type'] = Variable<String>(eventType);
    map['business_owned_delta'] = Variable<int>(businessOwnedDelta);
    map['customer_owned_delta'] = Variable<int>(customerOwnedDelta);
    map['business_owned_after'] = Variable<int>(businessOwnedAfter);
    map['customer_owned_after'] = Variable<int>(customerOwnedAfter);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || deliveryId != null) {
      map['delivery_id'] = Variable<String>(deliveryId);
    }
    if (!nullToAbsent || bottleTransactionId != null) {
      map['bottle_transaction_id'] = Variable<String>(bottleTransactionId);
    }
    return map;
  }

  CustomerOwnedBottleLogsTableCompanion toCompanion(bool nullToAbsent) {
    return CustomerOwnedBottleLogsTableCompanion(
      id: Value(id),
      customerId: Value(customerId),
      eventType: Value(eventType),
      businessOwnedDelta: Value(businessOwnedDelta),
      customerOwnedDelta: Value(customerOwnedDelta),
      businessOwnedAfter: Value(businessOwnedAfter),
      customerOwnedAfter: Value(customerOwnedAfter),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      deliveryId: deliveryId == null && nullToAbsent
          ? const Value.absent()
          : Value(deliveryId),
      bottleTransactionId: bottleTransactionId == null && nullToAbsent
          ? const Value.absent()
          : Value(bottleTransactionId),
    );
  }

  factory CustomerOwnedBottleLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CustomerOwnedBottleLogsTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String>(json['customerId']),
      eventType: serializer.fromJson<String>(json['eventType']),
      businessOwnedDelta: serializer.fromJson<int>(json['businessOwnedDelta']),
      customerOwnedDelta: serializer.fromJson<int>(json['customerOwnedDelta']),
      businessOwnedAfter: serializer.fromJson<int>(json['businessOwnedAfter']),
      customerOwnedAfter: serializer.fromJson<int>(json['customerOwnedAfter']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      deliveryId: serializer.fromJson<String?>(json['deliveryId']),
      bottleTransactionId: serializer.fromJson<String?>(
        json['bottleTransactionId'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String>(customerId),
      'eventType': serializer.toJson<String>(eventType),
      'businessOwnedDelta': serializer.toJson<int>(businessOwnedDelta),
      'customerOwnedDelta': serializer.toJson<int>(customerOwnedDelta),
      'businessOwnedAfter': serializer.toJson<int>(businessOwnedAfter),
      'customerOwnedAfter': serializer.toJson<int>(customerOwnedAfter),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'deliveryId': serializer.toJson<String?>(deliveryId),
      'bottleTransactionId': serializer.toJson<String?>(bottleTransactionId),
    };
  }

  CustomerOwnedBottleLogsTableData copyWith({
    String? id,
    String? customerId,
    String? eventType,
    int? businessOwnedDelta,
    int? customerOwnedDelta,
    int? businessOwnedAfter,
    int? customerOwnedAfter,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    Value<String?> deliveryId = const Value.absent(),
    Value<String?> bottleTransactionId = const Value.absent(),
  }) => CustomerOwnedBottleLogsTableData(
    id: id ?? this.id,
    customerId: customerId ?? this.customerId,
    eventType: eventType ?? this.eventType,
    businessOwnedDelta: businessOwnedDelta ?? this.businessOwnedDelta,
    customerOwnedDelta: customerOwnedDelta ?? this.customerOwnedDelta,
    businessOwnedAfter: businessOwnedAfter ?? this.businessOwnedAfter,
    customerOwnedAfter: customerOwnedAfter ?? this.customerOwnedAfter,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    deliveryId: deliveryId.present ? deliveryId.value : this.deliveryId,
    bottleTransactionId: bottleTransactionId.present
        ? bottleTransactionId.value
        : this.bottleTransactionId,
  );
  CustomerOwnedBottleLogsTableData copyWithCompanion(
    CustomerOwnedBottleLogsTableCompanion data,
  ) {
    return CustomerOwnedBottleLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      businessOwnedDelta: data.businessOwnedDelta.present
          ? data.businessOwnedDelta.value
          : this.businessOwnedDelta,
      customerOwnedDelta: data.customerOwnedDelta.present
          ? data.customerOwnedDelta.value
          : this.customerOwnedDelta,
      businessOwnedAfter: data.businessOwnedAfter.present
          ? data.businessOwnedAfter.value
          : this.businessOwnedAfter,
      customerOwnedAfter: data.customerOwnedAfter.present
          ? data.customerOwnedAfter.value
          : this.customerOwnedAfter,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      deliveryId: data.deliveryId.present
          ? data.deliveryId.value
          : this.deliveryId,
      bottleTransactionId: data.bottleTransactionId.present
          ? data.bottleTransactionId.value
          : this.bottleTransactionId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CustomerOwnedBottleLogsTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('eventType: $eventType, ')
          ..write('businessOwnedDelta: $businessOwnedDelta, ')
          ..write('customerOwnedDelta: $customerOwnedDelta, ')
          ..write('businessOwnedAfter: $businessOwnedAfter, ')
          ..write('customerOwnedAfter: $customerOwnedAfter, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('bottleTransactionId: $bottleTransactionId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    eventType,
    businessOwnedDelta,
    customerOwnedDelta,
    businessOwnedAfter,
    customerOwnedAfter,
    date,
    notes,
    deliveryId,
    bottleTransactionId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CustomerOwnedBottleLogsTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.eventType == this.eventType &&
          other.businessOwnedDelta == this.businessOwnedDelta &&
          other.customerOwnedDelta == this.customerOwnedDelta &&
          other.businessOwnedAfter == this.businessOwnedAfter &&
          other.customerOwnedAfter == this.customerOwnedAfter &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.deliveryId == this.deliveryId &&
          other.bottleTransactionId == this.bottleTransactionId);
}

class CustomerOwnedBottleLogsTableCompanion
    extends UpdateCompanion<CustomerOwnedBottleLogsTableData> {
  final Value<String> id;
  final Value<String> customerId;
  final Value<String> eventType;
  final Value<int> businessOwnedDelta;
  final Value<int> customerOwnedDelta;
  final Value<int> businessOwnedAfter;
  final Value<int> customerOwnedAfter;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String?> deliveryId;
  final Value<String?> bottleTransactionId;
  final Value<int> rowid;
  const CustomerOwnedBottleLogsTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.eventType = const Value.absent(),
    this.businessOwnedDelta = const Value.absent(),
    this.customerOwnedDelta = const Value.absent(),
    this.businessOwnedAfter = const Value.absent(),
    this.customerOwnedAfter = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.bottleTransactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CustomerOwnedBottleLogsTableCompanion.insert({
    required String id,
    required String customerId,
    required String eventType,
    this.businessOwnedDelta = const Value.absent(),
    this.customerOwnedDelta = const Value.absent(),
    required int businessOwnedAfter,
    required int customerOwnedAfter,
    required DateTime date,
    this.notes = const Value.absent(),
    this.deliveryId = const Value.absent(),
    this.bottleTransactionId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       customerId = Value(customerId),
       eventType = Value(eventType),
       businessOwnedAfter = Value(businessOwnedAfter),
       customerOwnedAfter = Value(customerOwnedAfter),
       date = Value(date);
  static Insertable<CustomerOwnedBottleLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? eventType,
    Expression<int>? businessOwnedDelta,
    Expression<int>? customerOwnedDelta,
    Expression<int>? businessOwnedAfter,
    Expression<int>? customerOwnedAfter,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? deliveryId,
    Expression<String>? bottleTransactionId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (eventType != null) 'event_type': eventType,
      if (businessOwnedDelta != null)
        'business_owned_delta': businessOwnedDelta,
      if (customerOwnedDelta != null)
        'customer_owned_delta': customerOwnedDelta,
      if (businessOwnedAfter != null)
        'business_owned_after': businessOwnedAfter,
      if (customerOwnedAfter != null)
        'customer_owned_after': customerOwnedAfter,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (deliveryId != null) 'delivery_id': deliveryId,
      if (bottleTransactionId != null)
        'bottle_transaction_id': bottleTransactionId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CustomerOwnedBottleLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? customerId,
    Value<String>? eventType,
    Value<int>? businessOwnedDelta,
    Value<int>? customerOwnedDelta,
    Value<int>? businessOwnedAfter,
    Value<int>? customerOwnedAfter,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String?>? deliveryId,
    Value<String?>? bottleTransactionId,
    Value<int>? rowid,
  }) {
    return CustomerOwnedBottleLogsTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      eventType: eventType ?? this.eventType,
      businessOwnedDelta: businessOwnedDelta ?? this.businessOwnedDelta,
      customerOwnedDelta: customerOwnedDelta ?? this.customerOwnedDelta,
      businessOwnedAfter: businessOwnedAfter ?? this.businessOwnedAfter,
      customerOwnedAfter: customerOwnedAfter ?? this.customerOwnedAfter,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      deliveryId: deliveryId ?? this.deliveryId,
      bottleTransactionId: bottleTransactionId ?? this.bottleTransactionId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(eventType.value);
    }
    if (businessOwnedDelta.present) {
      map['business_owned_delta'] = Variable<int>(businessOwnedDelta.value);
    }
    if (customerOwnedDelta.present) {
      map['customer_owned_delta'] = Variable<int>(customerOwnedDelta.value);
    }
    if (businessOwnedAfter.present) {
      map['business_owned_after'] = Variable<int>(businessOwnedAfter.value);
    }
    if (customerOwnedAfter.present) {
      map['customer_owned_after'] = Variable<int>(customerOwnedAfter.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (deliveryId.present) {
      map['delivery_id'] = Variable<String>(deliveryId.value);
    }
    if (bottleTransactionId.present) {
      map['bottle_transaction_id'] = Variable<String>(
        bottleTransactionId.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CustomerOwnedBottleLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('eventType: $eventType, ')
          ..write('businessOwnedDelta: $businessOwnedDelta, ')
          ..write('customerOwnedDelta: $customerOwnedDelta, ')
          ..write('businessOwnedAfter: $businessOwnedAfter, ')
          ..write('customerOwnedAfter: $customerOwnedAfter, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('deliveryId: $deliveryId, ')
          ..write('bottleTransactionId: $bottleTransactionId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WalkInSalesTableTable extends WalkInSalesTable
    with TableInfo<$WalkInSalesTableTable, WalkInSalesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WalkInSalesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _customerIdMeta = const VerificationMeta(
    'customerId',
  );
  @override
  late final GeneratedColumn<String> customerId = GeneratedColumn<String>(
    'customer_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _walkInTypeMeta = const VerificationMeta(
    'walkInType',
  );
  @override
  late final GeneratedColumn<String> walkInType = GeneratedColumn<String>(
    'walk_in_type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _businessOwnedQuantityMeta =
      const VerificationMeta('businessOwnedQuantity');
  @override
  late final GeneratedColumn<int> businessOwnedQuantity = GeneratedColumn<int>(
    'business_owned_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _customerOwnedQuantityMeta =
      const VerificationMeta('customerOwnedQuantity');
  @override
  late final GeneratedColumn<int> customerOwnedQuantity = GeneratedColumn<int>(
    'customer_owned_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _returnedEmptyQuantityMeta =
      const VerificationMeta('returnedEmptyQuantity');
  @override
  late final GeneratedColumn<int> returnedEmptyQuantity = GeneratedColumn<int>(
    'returned_empty_quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _pricePerBottleMeta = const VerificationMeta(
    'pricePerBottle',
  );
  @override
  late final GeneratedColumn<double> pricePerBottle = GeneratedColumn<double>(
    'price_per_bottle',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _totalAmountMeta = const VerificationMeta(
    'totalAmount',
  );
  @override
  late final GeneratedColumn<double> totalAmount = GeneratedColumn<double>(
    'total_amount',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _paymentMethodMeta = const VerificationMeta(
    'paymentMethod',
  );
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
    'payment_method',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('Cash'),
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    customerId,
    walkInType,
    businessOwnedQuantity,
    customerOwnedQuantity,
    returnedEmptyQuantity,
    pricePerBottle,
    totalAmount,
    paymentMethod,
    notes,
    date,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'walk_in_sales';
  @override
  VerificationContext validateIntegrity(
    Insertable<WalkInSalesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('customer_id')) {
      context.handle(
        _customerIdMeta,
        customerId.isAcceptableOrUnknown(data['customer_id']!, _customerIdMeta),
      );
    }
    if (data.containsKey('walk_in_type')) {
      context.handle(
        _walkInTypeMeta,
        walkInType.isAcceptableOrUnknown(
          data['walk_in_type']!,
          _walkInTypeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_walkInTypeMeta);
    }
    if (data.containsKey('business_owned_quantity')) {
      context.handle(
        _businessOwnedQuantityMeta,
        businessOwnedQuantity.isAcceptableOrUnknown(
          data['business_owned_quantity']!,
          _businessOwnedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('customer_owned_quantity')) {
      context.handle(
        _customerOwnedQuantityMeta,
        customerOwnedQuantity.isAcceptableOrUnknown(
          data['customer_owned_quantity']!,
          _customerOwnedQuantityMeta,
        ),
      );
    }
    if (data.containsKey('returned_empty_quantity')) {
      context.handle(
        _returnedEmptyQuantityMeta,
        returnedEmptyQuantity.isAcceptableOrUnknown(
          data['returned_empty_quantity']!,
          _returnedEmptyQuantityMeta,
        ),
      );
    }
    if (data.containsKey('price_per_bottle')) {
      context.handle(
        _pricePerBottleMeta,
        pricePerBottle.isAcceptableOrUnknown(
          data['price_per_bottle']!,
          _pricePerBottleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_pricePerBottleMeta);
    }
    if (data.containsKey('total_amount')) {
      context.handle(
        _totalAmountMeta,
        totalAmount.isAcceptableOrUnknown(
          data['total_amount']!,
          _totalAmountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_totalAmountMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
        _paymentMethodMeta,
        paymentMethod.isAcceptableOrUnknown(
          data['payment_method']!,
          _paymentMethodMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WalkInSalesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WalkInSalesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      customerId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}customer_id'],
      ),
      walkInType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}walk_in_type'],
      )!,
      businessOwnedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}business_owned_quantity'],
      )!,
      customerOwnedQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}customer_owned_quantity'],
      )!,
      returnedEmptyQuantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}returned_empty_quantity'],
      )!,
      pricePerBottle: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price_per_bottle'],
      )!,
      totalAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}total_amount'],
      )!,
      paymentMethod: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payment_method'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $WalkInSalesTableTable createAlias(String alias) {
    return $WalkInSalesTableTable(attachedDatabase, alias);
  }
}

class WalkInSalesTableData extends DataClass
    implements Insertable<WalkInSalesTableData> {
  final String id;
  final String? customerId;
  final String walkInType;
  final int businessOwnedQuantity;
  final int customerOwnedQuantity;
  final int returnedEmptyQuantity;
  final double pricePerBottle;
  final double totalAmount;
  final String paymentMethod;
  final String? notes;
  final DateTime date;
  final DateTime createdAt;
  final DateTime updatedAt;
  const WalkInSalesTableData({
    required this.id,
    this.customerId,
    required this.walkInType,
    required this.businessOwnedQuantity,
    required this.customerOwnedQuantity,
    required this.returnedEmptyQuantity,
    required this.pricePerBottle,
    required this.totalAmount,
    required this.paymentMethod,
    this.notes,
    required this.date,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || customerId != null) {
      map['customer_id'] = Variable<String>(customerId);
    }
    map['walk_in_type'] = Variable<String>(walkInType);
    map['business_owned_quantity'] = Variable<int>(businessOwnedQuantity);
    map['customer_owned_quantity'] = Variable<int>(customerOwnedQuantity);
    map['returned_empty_quantity'] = Variable<int>(returnedEmptyQuantity);
    map['price_per_bottle'] = Variable<double>(pricePerBottle);
    map['total_amount'] = Variable<double>(totalAmount);
    map['payment_method'] = Variable<String>(paymentMethod);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  WalkInSalesTableCompanion toCompanion(bool nullToAbsent) {
    return WalkInSalesTableCompanion(
      id: Value(id),
      customerId: customerId == null && nullToAbsent
          ? const Value.absent()
          : Value(customerId),
      walkInType: Value(walkInType),
      businessOwnedQuantity: Value(businessOwnedQuantity),
      customerOwnedQuantity: Value(customerOwnedQuantity),
      returnedEmptyQuantity: Value(returnedEmptyQuantity),
      pricePerBottle: Value(pricePerBottle),
      totalAmount: Value(totalAmount),
      paymentMethod: Value(paymentMethod),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      date: Value(date),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory WalkInSalesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WalkInSalesTableData(
      id: serializer.fromJson<String>(json['id']),
      customerId: serializer.fromJson<String?>(json['customerId']),
      walkInType: serializer.fromJson<String>(json['walkInType']),
      businessOwnedQuantity: serializer.fromJson<int>(
        json['businessOwnedQuantity'],
      ),
      customerOwnedQuantity: serializer.fromJson<int>(
        json['customerOwnedQuantity'],
      ),
      returnedEmptyQuantity: serializer.fromJson<int>(
        json['returnedEmptyQuantity'],
      ),
      pricePerBottle: serializer.fromJson<double>(json['pricePerBottle']),
      totalAmount: serializer.fromJson<double>(json['totalAmount']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      notes: serializer.fromJson<String?>(json['notes']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'customerId': serializer.toJson<String?>(customerId),
      'walkInType': serializer.toJson<String>(walkInType),
      'businessOwnedQuantity': serializer.toJson<int>(businessOwnedQuantity),
      'customerOwnedQuantity': serializer.toJson<int>(customerOwnedQuantity),
      'returnedEmptyQuantity': serializer.toJson<int>(returnedEmptyQuantity),
      'pricePerBottle': serializer.toJson<double>(pricePerBottle),
      'totalAmount': serializer.toJson<double>(totalAmount),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'notes': serializer.toJson<String?>(notes),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  WalkInSalesTableData copyWith({
    String? id,
    Value<String?> customerId = const Value.absent(),
    String? walkInType,
    int? businessOwnedQuantity,
    int? customerOwnedQuantity,
    int? returnedEmptyQuantity,
    double? pricePerBottle,
    double? totalAmount,
    String? paymentMethod,
    Value<String?> notes = const Value.absent(),
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => WalkInSalesTableData(
    id: id ?? this.id,
    customerId: customerId.present ? customerId.value : this.customerId,
    walkInType: walkInType ?? this.walkInType,
    businessOwnedQuantity: businessOwnedQuantity ?? this.businessOwnedQuantity,
    customerOwnedQuantity: customerOwnedQuantity ?? this.customerOwnedQuantity,
    returnedEmptyQuantity: returnedEmptyQuantity ?? this.returnedEmptyQuantity,
    pricePerBottle: pricePerBottle ?? this.pricePerBottle,
    totalAmount: totalAmount ?? this.totalAmount,
    paymentMethod: paymentMethod ?? this.paymentMethod,
    notes: notes.present ? notes.value : this.notes,
    date: date ?? this.date,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  WalkInSalesTableData copyWithCompanion(WalkInSalesTableCompanion data) {
    return WalkInSalesTableData(
      id: data.id.present ? data.id.value : this.id,
      customerId: data.customerId.present
          ? data.customerId.value
          : this.customerId,
      walkInType: data.walkInType.present
          ? data.walkInType.value
          : this.walkInType,
      businessOwnedQuantity: data.businessOwnedQuantity.present
          ? data.businessOwnedQuantity.value
          : this.businessOwnedQuantity,
      customerOwnedQuantity: data.customerOwnedQuantity.present
          ? data.customerOwnedQuantity.value
          : this.customerOwnedQuantity,
      returnedEmptyQuantity: data.returnedEmptyQuantity.present
          ? data.returnedEmptyQuantity.value
          : this.returnedEmptyQuantity,
      pricePerBottle: data.pricePerBottle.present
          ? data.pricePerBottle.value
          : this.pricePerBottle,
      totalAmount: data.totalAmount.present
          ? data.totalAmount.value
          : this.totalAmount,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      notes: data.notes.present ? data.notes.value : this.notes,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WalkInSalesTableData(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('walkInType: $walkInType, ')
          ..write('businessOwnedQuantity: $businessOwnedQuantity, ')
          ..write('customerOwnedQuantity: $customerOwnedQuantity, ')
          ..write('returnedEmptyQuantity: $returnedEmptyQuantity, ')
          ..write('pricePerBottle: $pricePerBottle, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    customerId,
    walkInType,
    businessOwnedQuantity,
    customerOwnedQuantity,
    returnedEmptyQuantity,
    pricePerBottle,
    totalAmount,
    paymentMethod,
    notes,
    date,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WalkInSalesTableData &&
          other.id == this.id &&
          other.customerId == this.customerId &&
          other.walkInType == this.walkInType &&
          other.businessOwnedQuantity == this.businessOwnedQuantity &&
          other.customerOwnedQuantity == this.customerOwnedQuantity &&
          other.returnedEmptyQuantity == this.returnedEmptyQuantity &&
          other.pricePerBottle == this.pricePerBottle &&
          other.totalAmount == this.totalAmount &&
          other.paymentMethod == this.paymentMethod &&
          other.notes == this.notes &&
          other.date == this.date &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class WalkInSalesTableCompanion extends UpdateCompanion<WalkInSalesTableData> {
  final Value<String> id;
  final Value<String?> customerId;
  final Value<String> walkInType;
  final Value<int> businessOwnedQuantity;
  final Value<int> customerOwnedQuantity;
  final Value<int> returnedEmptyQuantity;
  final Value<double> pricePerBottle;
  final Value<double> totalAmount;
  final Value<String> paymentMethod;
  final Value<String?> notes;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const WalkInSalesTableCompanion({
    this.id = const Value.absent(),
    this.customerId = const Value.absent(),
    this.walkInType = const Value.absent(),
    this.businessOwnedQuantity = const Value.absent(),
    this.customerOwnedQuantity = const Value.absent(),
    this.returnedEmptyQuantity = const Value.absent(),
    this.pricePerBottle = const Value.absent(),
    this.totalAmount = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WalkInSalesTableCompanion.insert({
    required String id,
    this.customerId = const Value.absent(),
    required String walkInType,
    this.businessOwnedQuantity = const Value.absent(),
    this.customerOwnedQuantity = const Value.absent(),
    this.returnedEmptyQuantity = const Value.absent(),
    required double pricePerBottle,
    required double totalAmount,
    this.paymentMethod = const Value.absent(),
    this.notes = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       walkInType = Value(walkInType),
       pricePerBottle = Value(pricePerBottle),
       totalAmount = Value(totalAmount);
  static Insertable<WalkInSalesTableData> custom({
    Expression<String>? id,
    Expression<String>? customerId,
    Expression<String>? walkInType,
    Expression<int>? businessOwnedQuantity,
    Expression<int>? customerOwnedQuantity,
    Expression<int>? returnedEmptyQuantity,
    Expression<double>? pricePerBottle,
    Expression<double>? totalAmount,
    Expression<String>? paymentMethod,
    Expression<String>? notes,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (customerId != null) 'customer_id': customerId,
      if (walkInType != null) 'walk_in_type': walkInType,
      if (businessOwnedQuantity != null)
        'business_owned_quantity': businessOwnedQuantity,
      if (customerOwnedQuantity != null)
        'customer_owned_quantity': customerOwnedQuantity,
      if (returnedEmptyQuantity != null)
        'returned_empty_quantity': returnedEmptyQuantity,
      if (pricePerBottle != null) 'price_per_bottle': pricePerBottle,
      if (totalAmount != null) 'total_amount': totalAmount,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (notes != null) 'notes': notes,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WalkInSalesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? customerId,
    Value<String>? walkInType,
    Value<int>? businessOwnedQuantity,
    Value<int>? customerOwnedQuantity,
    Value<int>? returnedEmptyQuantity,
    Value<double>? pricePerBottle,
    Value<double>? totalAmount,
    Value<String>? paymentMethod,
    Value<String?>? notes,
    Value<DateTime>? date,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return WalkInSalesTableCompanion(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      walkInType: walkInType ?? this.walkInType,
      businessOwnedQuantity:
          businessOwnedQuantity ?? this.businessOwnedQuantity,
      customerOwnedQuantity:
          customerOwnedQuantity ?? this.customerOwnedQuantity,
      returnedEmptyQuantity:
          returnedEmptyQuantity ?? this.returnedEmptyQuantity,
      pricePerBottle: pricePerBottle ?? this.pricePerBottle,
      totalAmount: totalAmount ?? this.totalAmount,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (customerId.present) {
      map['customer_id'] = Variable<String>(customerId.value);
    }
    if (walkInType.present) {
      map['walk_in_type'] = Variable<String>(walkInType.value);
    }
    if (businessOwnedQuantity.present) {
      map['business_owned_quantity'] = Variable<int>(
        businessOwnedQuantity.value,
      );
    }
    if (customerOwnedQuantity.present) {
      map['customer_owned_quantity'] = Variable<int>(
        customerOwnedQuantity.value,
      );
    }
    if (returnedEmptyQuantity.present) {
      map['returned_empty_quantity'] = Variable<int>(
        returnedEmptyQuantity.value,
      );
    }
    if (pricePerBottle.present) {
      map['price_per_bottle'] = Variable<double>(pricePerBottle.value);
    }
    if (totalAmount.present) {
      map['total_amount'] = Variable<double>(totalAmount.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WalkInSalesTableCompanion(')
          ..write('id: $id, ')
          ..write('customerId: $customerId, ')
          ..write('walkInType: $walkInType, ')
          ..write('businessOwnedQuantity: $businessOwnedQuantity, ')
          ..write('customerOwnedQuantity: $customerOwnedQuantity, ')
          ..write('returnedEmptyQuantity: $returnedEmptyQuantity, ')
          ..write('pricePerBottle: $pricePerBottle, ')
          ..write('totalAmount: $totalAmount, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('notes: $notes, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CustomersTableTable customersTable = $CustomersTableTable(this);
  late final $DeliveriesTableTable deliveriesTable = $DeliveriesTableTable(
    this,
  );
  late final $BottleTransactionsTableTable bottleTransactionsTable =
      $BottleTransactionsTableTable(this);
  late final $PaymentsTableTable paymentsTable = $PaymentsTableTable(this);
  late final $ExpensesTableTable expensesTable = $ExpensesTableTable(this);
  late final $DispenserSalesTableTable dispenserSalesTable =
      $DispenserSalesTableTable(this);
  late final $SettingsTableTable settingsTable = $SettingsTableTable(this);
  late final $SavingsContributionsTableTable savingsContributionsTable =
      $SavingsContributionsTableTable(this);
  late final $SupplyPurchasesTableTable supplyPurchasesTable =
      $SupplyPurchasesTableTable(this);
  late final $InventoryStockTableTable inventoryStockTable =
      $InventoryStockTableTable(this);
  late final $SuppliersTableTable suppliersTable = $SuppliersTableTable(this);
  late final $SavingsGoalsTableTable savingsGoalsTable =
      $SavingsGoalsTableTable(this);
  late final $InventoryAuditsTableTable inventoryAuditsTable =
      $InventoryAuditsTableTable(this);
  late final $InventoryAdjustmentsTableTable inventoryAdjustmentsTable =
      $InventoryAdjustmentsTableTable(this);
  late final $CustomerDepositsTableTable customerDepositsTable =
      $CustomerDepositsTableTable(this);
  late final $CopilotMessagesTableTable copilotMessagesTable =
      $CopilotMessagesTableTable(this);
  late final $CustomerBottleReconciliationsTableTable
  customerBottleReconciliationsTable = $CustomerBottleReconciliationsTableTable(
    this,
  );
  late final $CustomerOwnedBottleLogsTableTable customerOwnedBottleLogsTable =
      $CustomerOwnedBottleLogsTableTable(this);
  late final $WalkInSalesTableTable walkInSalesTable = $WalkInSalesTableTable(
    this,
  );
  late final CustomersDao customersDao = CustomersDao(this as AppDatabase);
  late final DeliveriesDao deliveriesDao = DeliveriesDao(this as AppDatabase);
  late final BottleTransactionsDao bottleTransactionsDao =
      BottleTransactionsDao(this as AppDatabase);
  late final PaymentsDao paymentsDao = PaymentsDao(this as AppDatabase);
  late final ExpensesDao expensesDao = ExpensesDao(this as AppDatabase);
  late final DispenserSalesDao dispenserSalesDao = DispenserSalesDao(
    this as AppDatabase,
  );
  late final SettingsDao settingsDao = SettingsDao(this as AppDatabase);
  late final SavingsDao savingsDao = SavingsDao(this as AppDatabase);
  late final SupplyPurchasesDao supplyPurchasesDao = SupplyPurchasesDao(
    this as AppDatabase,
  );
  late final InventoryStockDao inventoryStockDao = InventoryStockDao(
    this as AppDatabase,
  );
  late final SuppliersDao suppliersDao = SuppliersDao(this as AppDatabase);
  late final SavingsGoalsDao savingsGoalsDao = SavingsGoalsDao(
    this as AppDatabase,
  );
  late final InventoryAuditsDao inventoryAuditsDao = InventoryAuditsDao(
    this as AppDatabase,
  );
  late final InventoryAdjustmentsDao inventoryAdjustmentsDao =
      InventoryAdjustmentsDao(this as AppDatabase);
  late final CustomerDepositsDao customerDepositsDao = CustomerDepositsDao(
    this as AppDatabase,
  );
  late final CopilotMessagesDao copilotMessagesDao = CopilotMessagesDao(
    this as AppDatabase,
  );
  late final CustomerBottleReconciliationsDao customerBottleReconciliationsDao =
      CustomerBottleReconciliationsDao(this as AppDatabase);
  late final CustomerOwnedBottleLogsDao customerOwnedBottleLogsDao =
      CustomerOwnedBottleLogsDao(this as AppDatabase);
  late final WalkInSalesDao walkInSalesDao = WalkInSalesDao(
    this as AppDatabase,
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    customersTable,
    deliveriesTable,
    bottleTransactionsTable,
    paymentsTable,
    expensesTable,
    dispenserSalesTable,
    settingsTable,
    savingsContributionsTable,
    supplyPurchasesTable,
    inventoryStockTable,
    suppliersTable,
    savingsGoalsTable,
    inventoryAuditsTable,
    inventoryAdjustmentsTable,
    customerDepositsTable,
    copilotMessagesTable,
    customerBottleReconciliationsTable,
    customerOwnedBottleLogsTable,
    walkInSalesTable,
  ];
}

typedef $$CustomersTableTableCreateCompanionBuilder =
    CustomersTableCompanion Function({
      required String id,
      required String name,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> notes,
      Value<int?> pendingPhysicalBottleCount,
      Value<int> customerOwnedBottlesHeld,
      Value<DateTime?> lastPhysicalCountDate,
      Value<bool> lastPhysicalCountVerified,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CustomersTableTableUpdateCompanionBuilder =
    CustomersTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> phone,
      Value<String?> address,
      Value<String?> notes,
      Value<int?> pendingPhysicalBottleCount,
      Value<int> customerOwnedBottlesHeld,
      Value<DateTime?> lastPhysicalCountDate,
      Value<bool> lastPhysicalCountVerified,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomersTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pendingPhysicalBottleCount => $composableBuilder(
    column: $table.pendingPhysicalBottleCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerOwnedBottlesHeld => $composableBuilder(
    column: $table.customerOwnedBottlesHeld,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPhysicalCountDate => $composableBuilder(
    column: $table.lastPhysicalCountDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get lastPhysicalCountVerified => $composableBuilder(
    column: $table.lastPhysicalCountVerified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get phone => $composableBuilder(
    column: $table.phone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pendingPhysicalBottleCount => $composableBuilder(
    column: $table.pendingPhysicalBottleCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerOwnedBottlesHeld => $composableBuilder(
    column: $table.customerOwnedBottlesHeld,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPhysicalCountDate => $composableBuilder(
    column: $table.lastPhysicalCountDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get lastPhysicalCountVerified => $composableBuilder(
    column: $table.lastPhysicalCountVerified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomersTableTable> {
  $$CustomersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get phone =>
      $composableBuilder(column: $table.phone, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get pendingPhysicalBottleCount => $composableBuilder(
    column: $table.pendingPhysicalBottleCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerOwnedBottlesHeld => $composableBuilder(
    column: $table.customerOwnedBottlesHeld,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastPhysicalCountDate => $composableBuilder(
    column: $table.lastPhysicalCountDate,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get lastPhysicalCountVerified => $composableBuilder(
    column: $table.lastPhysicalCountVerified,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomersTableTable,
          CustomersTableData,
          $$CustomersTableTableFilterComposer,
          $$CustomersTableTableOrderingComposer,
          $$CustomersTableTableAnnotationComposer,
          $$CustomersTableTableCreateCompanionBuilder,
          $$CustomersTableTableUpdateCompanionBuilder,
          (
            CustomersTableData,
            BaseReferences<
              _$AppDatabase,
              $CustomersTableTable,
              CustomersTableData
            >,
          ),
          CustomersTableData,
          PrefetchHooks Function()
        > {
  $$CustomersTableTableTableManager(
    _$AppDatabase db,
    $CustomersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CustomersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CustomersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> pendingPhysicalBottleCount = const Value.absent(),
                Value<int> customerOwnedBottlesHeld = const Value.absent(),
                Value<DateTime?> lastPhysicalCountDate = const Value.absent(),
                Value<bool> lastPhysicalCountVerified = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersTableCompanion(
                id: id,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                pendingPhysicalBottleCount: pendingPhysicalBottleCount,
                customerOwnedBottlesHeld: customerOwnedBottlesHeld,
                lastPhysicalCountDate: lastPhysicalCountDate,
                lastPhysicalCountVerified: lastPhysicalCountVerified,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> phone = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int?> pendingPhysicalBottleCount = const Value.absent(),
                Value<int> customerOwnedBottlesHeld = const Value.absent(),
                Value<DateTime?> lastPhysicalCountDate = const Value.absent(),
                Value<bool> lastPhysicalCountVerified = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomersTableCompanion.insert(
                id: id,
                name: name,
                phone: phone,
                address: address,
                notes: notes,
                pendingPhysicalBottleCount: pendingPhysicalBottleCount,
                customerOwnedBottlesHeld: customerOwnedBottlesHeld,
                lastPhysicalCountDate: lastPhysicalCountDate,
                lastPhysicalCountVerified: lastPhysicalCountVerified,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomersTableTable,
      CustomersTableData,
      $$CustomersTableTableFilterComposer,
      $$CustomersTableTableOrderingComposer,
      $$CustomersTableTableAnnotationComposer,
      $$CustomersTableTableCreateCompanionBuilder,
      $$CustomersTableTableUpdateCompanionBuilder,
      (
        CustomersTableData,
        BaseReferences<_$AppDatabase, $CustomersTableTable, CustomersTableData>,
      ),
      CustomersTableData,
      PrefetchHooks Function()
    >;
typedef $$DeliveriesTableTableCreateCompanionBuilder =
    DeliveriesTableCompanion Function({
      required String id,
      required String customerId,
      required int quantity,
      required double pricePerBottle,
      required double totalAmount,
      Value<String> paymentStatus,
      Value<double> amountPaid,
      Value<double> depositApplied,
      Value<double> remainingBalance,
      Value<DateTime> deliveryDate,
      Value<String?> deliveryTime,
      Value<String> deliveryStatus,
      Value<int> collectedEmptyBottles,
      Value<int> customerOwnedBottlesFilled,
      Value<String?> notes,
      Value<String?> receiptNumber,
      Value<int> rowid,
    });
typedef $$DeliveriesTableTableUpdateCompanionBuilder =
    DeliveriesTableCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<int> quantity,
      Value<double> pricePerBottle,
      Value<double> totalAmount,
      Value<String> paymentStatus,
      Value<double> amountPaid,
      Value<double> depositApplied,
      Value<double> remainingBalance,
      Value<DateTime> deliveryDate,
      Value<String?> deliveryTime,
      Value<String> deliveryStatus,
      Value<int> collectedEmptyBottles,
      Value<int> customerOwnedBottlesFilled,
      Value<String?> notes,
      Value<String?> receiptNumber,
      Value<int> rowid,
    });

class $$DeliveriesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerBottle => $composableBuilder(
    column: $table.pricePerBottle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get depositApplied => $composableBuilder(
    column: $table.depositApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get collectedEmptyBottles => $composableBuilder(
    column: $table.collectedEmptyBottles,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerOwnedBottlesFilled => $composableBuilder(
    column: $table.customerOwnedBottlesFilled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DeliveriesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerBottle => $composableBuilder(
    column: $table.pricePerBottle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get depositApplied => $composableBuilder(
    column: $table.depositApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get collectedEmptyBottles => $composableBuilder(
    column: $table.collectedEmptyBottles,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerOwnedBottlesFilled => $composableBuilder(
    column: $table.customerOwnedBottlesFilled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DeliveriesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeliveriesTableTable> {
  $$DeliveriesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get pricePerBottle => $composableBuilder(
    column: $table.pricePerBottle,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentStatus => $composableBuilder(
    column: $table.paymentStatus,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amountPaid => $composableBuilder(
    column: $table.amountPaid,
    builder: (column) => column,
  );

  GeneratedColumn<double> get depositApplied => $composableBuilder(
    column: $table.depositApplied,
    builder: (column) => column,
  );

  GeneratedColumn<double> get remainingBalance => $composableBuilder(
    column: $table.remainingBalance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get deliveryDate => $composableBuilder(
    column: $table.deliveryDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryTime => $composableBuilder(
    column: $table.deliveryTime,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryStatus => $composableBuilder(
    column: $table.deliveryStatus,
    builder: (column) => column,
  );

  GeneratedColumn<int> get collectedEmptyBottles => $composableBuilder(
    column: $table.collectedEmptyBottles,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerOwnedBottlesFilled => $composableBuilder(
    column: $table.customerOwnedBottlesFilled,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get receiptNumber => $composableBuilder(
    column: $table.receiptNumber,
    builder: (column) => column,
  );
}

class $$DeliveriesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeliveriesTableTable,
          DeliveriesTableData,
          $$DeliveriesTableTableFilterComposer,
          $$DeliveriesTableTableOrderingComposer,
          $$DeliveriesTableTableAnnotationComposer,
          $$DeliveriesTableTableCreateCompanionBuilder,
          $$DeliveriesTableTableUpdateCompanionBuilder,
          (
            DeliveriesTableData,
            BaseReferences<
              _$AppDatabase,
              $DeliveriesTableTable,
              DeliveriesTableData
            >,
          ),
          DeliveriesTableData,
          PrefetchHooks Function()
        > {
  $$DeliveriesTableTableTableManager(
    _$AppDatabase db,
    $DeliveriesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeliveriesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeliveriesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeliveriesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> pricePerBottle = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> paymentStatus = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> depositApplied = const Value.absent(),
                Value<double> remainingBalance = const Value.absent(),
                Value<DateTime> deliveryDate = const Value.absent(),
                Value<String?> deliveryTime = const Value.absent(),
                Value<String> deliveryStatus = const Value.absent(),
                Value<int> collectedEmptyBottles = const Value.absent(),
                Value<int> customerOwnedBottlesFilled = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> receiptNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveriesTableCompanion(
                id: id,
                customerId: customerId,
                quantity: quantity,
                pricePerBottle: pricePerBottle,
                totalAmount: totalAmount,
                paymentStatus: paymentStatus,
                amountPaid: amountPaid,
                depositApplied: depositApplied,
                remainingBalance: remainingBalance,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                deliveryStatus: deliveryStatus,
                collectedEmptyBottles: collectedEmptyBottles,
                customerOwnedBottlesFilled: customerOwnedBottlesFilled,
                notes: notes,
                receiptNumber: receiptNumber,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required int quantity,
                required double pricePerBottle,
                required double totalAmount,
                Value<String> paymentStatus = const Value.absent(),
                Value<double> amountPaid = const Value.absent(),
                Value<double> depositApplied = const Value.absent(),
                Value<double> remainingBalance = const Value.absent(),
                Value<DateTime> deliveryDate = const Value.absent(),
                Value<String?> deliveryTime = const Value.absent(),
                Value<String> deliveryStatus = const Value.absent(),
                Value<int> collectedEmptyBottles = const Value.absent(),
                Value<int> customerOwnedBottlesFilled = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> receiptNumber = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeliveriesTableCompanion.insert(
                id: id,
                customerId: customerId,
                quantity: quantity,
                pricePerBottle: pricePerBottle,
                totalAmount: totalAmount,
                paymentStatus: paymentStatus,
                amountPaid: amountPaid,
                depositApplied: depositApplied,
                remainingBalance: remainingBalance,
                deliveryDate: deliveryDate,
                deliveryTime: deliveryTime,
                deliveryStatus: deliveryStatus,
                collectedEmptyBottles: collectedEmptyBottles,
                customerOwnedBottlesFilled: customerOwnedBottlesFilled,
                notes: notes,
                receiptNumber: receiptNumber,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DeliveriesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeliveriesTableTable,
      DeliveriesTableData,
      $$DeliveriesTableTableFilterComposer,
      $$DeliveriesTableTableOrderingComposer,
      $$DeliveriesTableTableAnnotationComposer,
      $$DeliveriesTableTableCreateCompanionBuilder,
      $$DeliveriesTableTableUpdateCompanionBuilder,
      (
        DeliveriesTableData,
        BaseReferences<
          _$AppDatabase,
          $DeliveriesTableTable,
          DeliveriesTableData
        >,
      ),
      DeliveriesTableData,
      PrefetchHooks Function()
    >;
typedef $$BottleTransactionsTableTableCreateCompanionBuilder =
    BottleTransactionsTableCompanion Function({
      required String id,
      Value<String?> customerId,
      required String transactionType,
      required int quantity,
      Value<DateTime> date,
      Value<String?> reason,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$BottleTransactionsTableTableUpdateCompanionBuilder =
    BottleTransactionsTableCompanion Function({
      Value<String> id,
      Value<String?> customerId,
      Value<String> transactionType,
      Value<int> quantity,
      Value<DateTime> date,
      Value<String?> reason,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$BottleTransactionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $BottleTransactionsTableTable> {
  $$BottleTransactionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BottleTransactionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BottleTransactionsTableTable> {
  $$BottleTransactionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BottleTransactionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BottleTransactionsTableTable> {
  $$BottleTransactionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$BottleTransactionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BottleTransactionsTableTable,
          BottleTransactionsTableData,
          $$BottleTransactionsTableTableFilterComposer,
          $$BottleTransactionsTableTableOrderingComposer,
          $$BottleTransactionsTableTableAnnotationComposer,
          $$BottleTransactionsTableTableCreateCompanionBuilder,
          $$BottleTransactionsTableTableUpdateCompanionBuilder,
          (
            BottleTransactionsTableData,
            BaseReferences<
              _$AppDatabase,
              $BottleTransactionsTableTable,
              BottleTransactionsTableData
            >,
          ),
          BottleTransactionsTableData,
          PrefetchHooks Function()
        > {
  $$BottleTransactionsTableTableTableManager(
    _$AppDatabase db,
    $BottleTransactionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BottleTransactionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BottleTransactionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BottleTransactionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BottleTransactionsTableCompanion(
                id: id,
                customerId: customerId,
                transactionType: transactionType,
                quantity: quantity,
                date: date,
                reason: reason,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> customerId = const Value.absent(),
                required String transactionType,
                required int quantity,
                Value<DateTime> date = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BottleTransactionsTableCompanion.insert(
                id: id,
                customerId: customerId,
                transactionType: transactionType,
                quantity: quantity,
                date: date,
                reason: reason,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BottleTransactionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BottleTransactionsTableTable,
      BottleTransactionsTableData,
      $$BottleTransactionsTableTableFilterComposer,
      $$BottleTransactionsTableTableOrderingComposer,
      $$BottleTransactionsTableTableAnnotationComposer,
      $$BottleTransactionsTableTableCreateCompanionBuilder,
      $$BottleTransactionsTableTableUpdateCompanionBuilder,
      (
        BottleTransactionsTableData,
        BaseReferences<
          _$AppDatabase,
          $BottleTransactionsTableTable,
          BottleTransactionsTableData
        >,
      ),
      BottleTransactionsTableData,
      PrefetchHooks Function()
    >;
typedef $$PaymentsTableTableCreateCompanionBuilder =
    PaymentsTableCompanion Function({
      required String id,
      required String customerId,
      Value<String?> deliveryId,
      required double amount,
      Value<DateTime> paymentDate,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$PaymentsTableTableUpdateCompanionBuilder =
    PaymentsTableCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String?> deliveryId,
      Value<double> amount,
      Value<DateTime> paymentDate,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$PaymentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PaymentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PaymentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $PaymentsTableTable> {
  $$PaymentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get paymentDate => $composableBuilder(
    column: $table.paymentDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$PaymentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PaymentsTableTable,
          PaymentsTableData,
          $$PaymentsTableTableFilterComposer,
          $$PaymentsTableTableOrderingComposer,
          $$PaymentsTableTableAnnotationComposer,
          $$PaymentsTableTableCreateCompanionBuilder,
          $$PaymentsTableTableUpdateCompanionBuilder,
          (
            PaymentsTableData,
            BaseReferences<
              _$AppDatabase,
              $PaymentsTableTable,
              PaymentsTableData
            >,
          ),
          PaymentsTableData,
          PrefetchHooks Function()
        > {
  $$PaymentsTableTableTableManager(_$AppDatabase db, $PaymentsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PaymentsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PaymentsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PaymentsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String?> deliveryId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion(
                id: id,
                customerId: customerId,
                deliveryId: deliveryId,
                amount: amount,
                paymentDate: paymentDate,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                Value<String?> deliveryId = const Value.absent(),
                required double amount,
                Value<DateTime> paymentDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PaymentsTableCompanion.insert(
                id: id,
                customerId: customerId,
                deliveryId: deliveryId,
                amount: amount,
                paymentDate: paymentDate,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PaymentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PaymentsTableTable,
      PaymentsTableData,
      $$PaymentsTableTableFilterComposer,
      $$PaymentsTableTableOrderingComposer,
      $$PaymentsTableTableAnnotationComposer,
      $$PaymentsTableTableCreateCompanionBuilder,
      $$PaymentsTableTableUpdateCompanionBuilder,
      (
        PaymentsTableData,
        BaseReferences<_$AppDatabase, $PaymentsTableTable, PaymentsTableData>,
      ),
      PaymentsTableData,
      PrefetchHooks Function()
    >;
typedef $$ExpensesTableTableCreateCompanionBuilder =
    ExpensesTableCompanion Function({
      required String id,
      required String category,
      required double amount,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String?> description,
      Value<String?> supplier,
      Value<int?> quantity,
      Value<double?> unitCost,
      Value<String?> supplyPurchaseId,
      Value<int> rowid,
    });
typedef $$ExpensesTableTableUpdateCompanionBuilder =
    ExpensesTableCompanion Function({
      Value<String> id,
      Value<String> category,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String?> description,
      Value<String?> supplier,
      Value<int?> quantity,
      Value<double?> unitCost,
      Value<String?> supplyPurchaseId,
      Value<int> rowid,
    });

class $$ExpensesTableTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplyPurchaseId => $composableBuilder(
    column: $table.supplyPurchaseId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExpensesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplier => $composableBuilder(
    column: $table.supplier,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplyPurchaseId => $composableBuilder(
    column: $table.supplyPurchaseId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExpensesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTableTable> {
  $$ExpensesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplier =>
      $composableBuilder(column: $table.supplier, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<String> get supplyPurchaseId => $composableBuilder(
    column: $table.supplyPurchaseId,
    builder: (column) => column,
  );
}

class $$ExpensesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ExpensesTableTable,
          ExpensesTableData,
          $$ExpensesTableTableFilterComposer,
          $$ExpensesTableTableOrderingComposer,
          $$ExpensesTableTableAnnotationComposer,
          $$ExpensesTableTableCreateCompanionBuilder,
          $$ExpensesTableTableUpdateCompanionBuilder,
          (
            ExpensesTableData,
            BaseReferences<
              _$AppDatabase,
              $ExpensesTableTable,
              ExpensesTableData
            >,
          ),
          ExpensesTableData,
          PrefetchHooks Function()
        > {
  $$ExpensesTableTableTableManager(_$AppDatabase db, $ExpensesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<int?> quantity = const Value.absent(),
                Value<double?> unitCost = const Value.absent(),
                Value<String?> supplyPurchaseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion(
                id: id,
                category: category,
                amount: amount,
                date: date,
                notes: notes,
                description: description,
                supplier: supplier,
                quantity: quantity,
                unitCost: unitCost,
                supplyPurchaseId: supplyPurchaseId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String category,
                required double amount,
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String?> supplier = const Value.absent(),
                Value<int?> quantity = const Value.absent(),
                Value<double?> unitCost = const Value.absent(),
                Value<String?> supplyPurchaseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExpensesTableCompanion.insert(
                id: id,
                category: category,
                amount: amount,
                date: date,
                notes: notes,
                description: description,
                supplier: supplier,
                quantity: quantity,
                unitCost: unitCost,
                supplyPurchaseId: supplyPurchaseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExpensesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ExpensesTableTable,
      ExpensesTableData,
      $$ExpensesTableTableFilterComposer,
      $$ExpensesTableTableOrderingComposer,
      $$ExpensesTableTableAnnotationComposer,
      $$ExpensesTableTableCreateCompanionBuilder,
      $$ExpensesTableTableUpdateCompanionBuilder,
      (
        ExpensesTableData,
        BaseReferences<_$AppDatabase, $ExpensesTableTable, ExpensesTableData>,
      ),
      ExpensesTableData,
      PrefetchHooks Function()
    >;
typedef $$DispenserSalesTableTableCreateCompanionBuilder =
    DispenserSalesTableCompanion Function({
      required String id,
      required double amount,
      Value<DateTime> date,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$DispenserSalesTableTableUpdateCompanionBuilder =
    DispenserSalesTableCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$DispenserSalesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DispenserSalesTableTable> {
  $$DispenserSalesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DispenserSalesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DispenserSalesTableTable> {
  $$DispenserSalesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DispenserSalesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DispenserSalesTableTable> {
  $$DispenserSalesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$DispenserSalesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DispenserSalesTableTable,
          DispenserSalesTableData,
          $$DispenserSalesTableTableFilterComposer,
          $$DispenserSalesTableTableOrderingComposer,
          $$DispenserSalesTableTableAnnotationComposer,
          $$DispenserSalesTableTableCreateCompanionBuilder,
          $$DispenserSalesTableTableUpdateCompanionBuilder,
          (
            DispenserSalesTableData,
            BaseReferences<
              _$AppDatabase,
              $DispenserSalesTableTable,
              DispenserSalesTableData
            >,
          ),
          DispenserSalesTableData,
          PrefetchHooks Function()
        > {
  $$DispenserSalesTableTableTableManager(
    _$AppDatabase db,
    $DispenserSalesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DispenserSalesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DispenserSalesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DispenserSalesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DispenserSalesTableCompanion(
                id: id,
                amount: amount,
                date: date,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DispenserSalesTableCompanion.insert(
                id: id,
                amount: amount,
                date: date,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DispenserSalesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DispenserSalesTableTable,
      DispenserSalesTableData,
      $$DispenserSalesTableTableFilterComposer,
      $$DispenserSalesTableTableOrderingComposer,
      $$DispenserSalesTableTableAnnotationComposer,
      $$DispenserSalesTableTableCreateCompanionBuilder,
      $$DispenserSalesTableTableUpdateCompanionBuilder,
      (
        DispenserSalesTableData,
        BaseReferences<
          _$AppDatabase,
          $DispenserSalesTableTable,
          DispenserSalesTableData
        >,
      ),
      DispenserSalesTableData,
      PrefetchHooks Function()
    >;
typedef $$SettingsTableTableCreateCompanionBuilder =
    SettingsTableCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$SettingsTableTableUpdateCompanionBuilder =
    SettingsTableCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$SettingsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SettingsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SettingsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SettingsTableTable> {
  $$SettingsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$SettingsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SettingsTableTable,
          SettingsTableData,
          $$SettingsTableTableFilterComposer,
          $$SettingsTableTableOrderingComposer,
          $$SettingsTableTableAnnotationComposer,
          $$SettingsTableTableCreateCompanionBuilder,
          $$SettingsTableTableUpdateCompanionBuilder,
          (
            SettingsTableData,
            BaseReferences<
              _$AppDatabase,
              $SettingsTableTable,
              SettingsTableData
            >,
          ),
          SettingsTableData,
          PrefetchHooks Function()
        > {
  $$SettingsTableTableTableManager(_$AppDatabase db, $SettingsTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SettingsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SettingsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SettingsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> key = const Value.absent(),
                Value<String> value = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) =>
                  SettingsTableCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => SettingsTableCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SettingsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SettingsTableTable,
      SettingsTableData,
      $$SettingsTableTableFilterComposer,
      $$SettingsTableTableOrderingComposer,
      $$SettingsTableTableAnnotationComposer,
      $$SettingsTableTableCreateCompanionBuilder,
      $$SettingsTableTableUpdateCompanionBuilder,
      (
        SettingsTableData,
        BaseReferences<_$AppDatabase, $SettingsTableTable, SettingsTableData>,
      ),
      SettingsTableData,
      PrefetchHooks Function()
    >;
typedef $$SavingsContributionsTableTableCreateCompanionBuilder =
    SavingsContributionsTableCompanion Function({
      required String id,
      required double amount,
      Value<DateTime> date,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$SavingsContributionsTableTableUpdateCompanionBuilder =
    SavingsContributionsTableCompanion Function({
      Value<String> id,
      Value<double> amount,
      Value<DateTime> date,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$SavingsContributionsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsContributionsTableTable> {
  $$SavingsContributionsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsContributionsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsContributionsTableTable> {
  $$SavingsContributionsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsContributionsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsContributionsTableTable> {
  $$SavingsContributionsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$SavingsContributionsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsContributionsTableTable,
          SavingsContributionsTableData,
          $$SavingsContributionsTableTableFilterComposer,
          $$SavingsContributionsTableTableOrderingComposer,
          $$SavingsContributionsTableTableAnnotationComposer,
          $$SavingsContributionsTableTableCreateCompanionBuilder,
          $$SavingsContributionsTableTableUpdateCompanionBuilder,
          (
            SavingsContributionsTableData,
            BaseReferences<
              _$AppDatabase,
              $SavingsContributionsTableTable,
              SavingsContributionsTableData
            >,
          ),
          SavingsContributionsTableData,
          PrefetchHooks Function()
        > {
  $$SavingsContributionsTableTableTableManager(
    _$AppDatabase db,
    $SavingsContributionsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsContributionsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$SavingsContributionsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SavingsContributionsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsContributionsTableCompanion(
                id: id,
                amount: amount,
                date: date,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required double amount,
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsContributionsTableCompanion.insert(
                id: id,
                amount: amount,
                date: date,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsContributionsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsContributionsTableTable,
      SavingsContributionsTableData,
      $$SavingsContributionsTableTableFilterComposer,
      $$SavingsContributionsTableTableOrderingComposer,
      $$SavingsContributionsTableTableAnnotationComposer,
      $$SavingsContributionsTableTableCreateCompanionBuilder,
      $$SavingsContributionsTableTableUpdateCompanionBuilder,
      (
        SavingsContributionsTableData,
        BaseReferences<
          _$AppDatabase,
          $SavingsContributionsTableTable,
          SavingsContributionsTableData
        >,
      ),
      SavingsContributionsTableData,
      PrefetchHooks Function()
    >;
typedef $$SupplyPurchasesTableTableCreateCompanionBuilder =
    SupplyPurchasesTableCompanion Function({
      required String id,
      Value<DateTime> purchaseDate,
      required String supplierName,
      Value<String?> supplierId,
      required String itemType,
      required int quantity,
      required double unitCost,
      required double totalCost,
      Value<String?> notes,
      required String expenseId,
      Value<String?> bottleTransactionId,
      Value<int> rowid,
    });
typedef $$SupplyPurchasesTableTableUpdateCompanionBuilder =
    SupplyPurchasesTableCompanion Function({
      Value<String> id,
      Value<DateTime> purchaseDate,
      Value<String> supplierName,
      Value<String?> supplierId,
      Value<String> itemType,
      Value<int> quantity,
      Value<double> unitCost,
      Value<double> totalCost,
      Value<String?> notes,
      Value<String> expenseId,
      Value<String?> bottleTransactionId,
      Value<int> rowid,
    });

class $$SupplyPurchasesTableTableFilterComposer
    extends Composer<_$AppDatabase, $SupplyPurchasesTableTable> {
  $$SupplyPurchasesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bottleTransactionId => $composableBuilder(
    column: $table.bottleTransactionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SupplyPurchasesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SupplyPurchasesTableTable> {
  $$SupplyPurchasesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get unitCost => $composableBuilder(
    column: $table.unitCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalCost => $composableBuilder(
    column: $table.totalCost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get expenseId => $composableBuilder(
    column: $table.expenseId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bottleTransactionId => $composableBuilder(
    column: $table.bottleTransactionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SupplyPurchasesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SupplyPurchasesTableTable> {
  $$SupplyPurchasesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get purchaseDate => $composableBuilder(
    column: $table.purchaseDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierName => $composableBuilder(
    column: $table.supplierName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get supplierId => $composableBuilder(
    column: $table.supplierId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<double> get unitCost =>
      $composableBuilder(column: $table.unitCost, builder: (column) => column);

  GeneratedColumn<double> get totalCost =>
      $composableBuilder(column: $table.totalCost, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get expenseId =>
      $composableBuilder(column: $table.expenseId, builder: (column) => column);

  GeneratedColumn<String> get bottleTransactionId => $composableBuilder(
    column: $table.bottleTransactionId,
    builder: (column) => column,
  );
}

class $$SupplyPurchasesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SupplyPurchasesTableTable,
          SupplyPurchasesTableData,
          $$SupplyPurchasesTableTableFilterComposer,
          $$SupplyPurchasesTableTableOrderingComposer,
          $$SupplyPurchasesTableTableAnnotationComposer,
          $$SupplyPurchasesTableTableCreateCompanionBuilder,
          $$SupplyPurchasesTableTableUpdateCompanionBuilder,
          (
            SupplyPurchasesTableData,
            BaseReferences<
              _$AppDatabase,
              $SupplyPurchasesTableTable,
              SupplyPurchasesTableData
            >,
          ),
          SupplyPurchasesTableData,
          PrefetchHooks Function()
        > {
  $$SupplyPurchasesTableTableTableManager(
    _$AppDatabase db,
    $SupplyPurchasesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SupplyPurchasesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SupplyPurchasesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SupplyPurchasesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> purchaseDate = const Value.absent(),
                Value<String> supplierName = const Value.absent(),
                Value<String?> supplierId = const Value.absent(),
                Value<String> itemType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<double> unitCost = const Value.absent(),
                Value<double> totalCost = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> expenseId = const Value.absent(),
                Value<String?> bottleTransactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplyPurchasesTableCompanion(
                id: id,
                purchaseDate: purchaseDate,
                supplierName: supplierName,
                supplierId: supplierId,
                itemType: itemType,
                quantity: quantity,
                unitCost: unitCost,
                totalCost: totalCost,
                notes: notes,
                expenseId: expenseId,
                bottleTransactionId: bottleTransactionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> purchaseDate = const Value.absent(),
                required String supplierName,
                Value<String?> supplierId = const Value.absent(),
                required String itemType,
                required int quantity,
                required double unitCost,
                required double totalCost,
                Value<String?> notes = const Value.absent(),
                required String expenseId,
                Value<String?> bottleTransactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SupplyPurchasesTableCompanion.insert(
                id: id,
                purchaseDate: purchaseDate,
                supplierName: supplierName,
                supplierId: supplierId,
                itemType: itemType,
                quantity: quantity,
                unitCost: unitCost,
                totalCost: totalCost,
                notes: notes,
                expenseId: expenseId,
                bottleTransactionId: bottleTransactionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SupplyPurchasesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SupplyPurchasesTableTable,
      SupplyPurchasesTableData,
      $$SupplyPurchasesTableTableFilterComposer,
      $$SupplyPurchasesTableTableOrderingComposer,
      $$SupplyPurchasesTableTableAnnotationComposer,
      $$SupplyPurchasesTableTableCreateCompanionBuilder,
      $$SupplyPurchasesTableTableUpdateCompanionBuilder,
      (
        SupplyPurchasesTableData,
        BaseReferences<
          _$AppDatabase,
          $SupplyPurchasesTableTable,
          SupplyPurchasesTableData
        >,
      ),
      SupplyPurchasesTableData,
      PrefetchHooks Function()
    >;
typedef $$InventoryStockTableTableCreateCompanionBuilder =
    InventoryStockTableCompanion Function({
      required String itemType,
      Value<int> quantity,
      Value<int> rowid,
    });
typedef $$InventoryStockTableTableUpdateCompanionBuilder =
    InventoryStockTableCompanion Function({
      Value<String> itemType,
      Value<int> quantity,
      Value<int> rowid,
    });

class $$InventoryStockTableTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryStockTableTable> {
  $$InventoryStockTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryStockTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryStockTableTable> {
  $$InventoryStockTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get itemType => $composableBuilder(
    column: $table.itemType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryStockTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryStockTableTable> {
  $$InventoryStockTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get itemType =>
      $composableBuilder(column: $table.itemType, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);
}

class $$InventoryStockTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryStockTableTable,
          InventoryStockTableData,
          $$InventoryStockTableTableFilterComposer,
          $$InventoryStockTableTableOrderingComposer,
          $$InventoryStockTableTableAnnotationComposer,
          $$InventoryStockTableTableCreateCompanionBuilder,
          $$InventoryStockTableTableUpdateCompanionBuilder,
          (
            InventoryStockTableData,
            BaseReferences<
              _$AppDatabase,
              $InventoryStockTableTable,
              InventoryStockTableData
            >,
          ),
          InventoryStockTableData,
          PrefetchHooks Function()
        > {
  $$InventoryStockTableTableTableManager(
    _$AppDatabase db,
    $InventoryStockTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryStockTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryStockTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryStockTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> itemType = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryStockTableCompanion(
                itemType: itemType,
                quantity: quantity,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String itemType,
                Value<int> quantity = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryStockTableCompanion.insert(
                itemType: itemType,
                quantity: quantity,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryStockTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryStockTableTable,
      InventoryStockTableData,
      $$InventoryStockTableTableFilterComposer,
      $$InventoryStockTableTableOrderingComposer,
      $$InventoryStockTableTableAnnotationComposer,
      $$InventoryStockTableTableCreateCompanionBuilder,
      $$InventoryStockTableTableUpdateCompanionBuilder,
      (
        InventoryStockTableData,
        BaseReferences<
          _$AppDatabase,
          $InventoryStockTableTable,
          InventoryStockTableData
        >,
      ),
      InventoryStockTableData,
      PrefetchHooks Function()
    >;
typedef $$SuppliersTableTableCreateCompanionBuilder =
    SuppliersTableCompanion Function({
      required String id,
      required String name,
      Value<String?> contactPerson,
      Value<String?> mobile,
      Value<String?> address,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SuppliersTableTableUpdateCompanionBuilder =
    SuppliersTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> contactPerson,
      Value<String?> mobile,
      Value<String?> address,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SuppliersTableTableFilterComposer
    extends Composer<_$AppDatabase, $SuppliersTableTable> {
  $$SuppliersTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SuppliersTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SuppliersTableTable> {
  $$SuppliersTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mobile => $composableBuilder(
    column: $table.mobile,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get address => $composableBuilder(
    column: $table.address,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SuppliersTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SuppliersTableTable> {
  $$SuppliersTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get contactPerson => $composableBuilder(
    column: $table.contactPerson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mobile =>
      $composableBuilder(column: $table.mobile, builder: (column) => column);

  GeneratedColumn<String> get address =>
      $composableBuilder(column: $table.address, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SuppliersTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SuppliersTableTable,
          SuppliersTableData,
          $$SuppliersTableTableFilterComposer,
          $$SuppliersTableTableOrderingComposer,
          $$SuppliersTableTableAnnotationComposer,
          $$SuppliersTableTableCreateCompanionBuilder,
          $$SuppliersTableTableUpdateCompanionBuilder,
          (
            SuppliersTableData,
            BaseReferences<
              _$AppDatabase,
              $SuppliersTableTable,
              SuppliersTableData
            >,
          ),
          SuppliersTableData,
          PrefetchHooks Function()
        > {
  $$SuppliersTableTableTableManager(
    _$AppDatabase db,
    $SuppliersTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SuppliersTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SuppliersTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SuppliersTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersTableCompanion(
                id: id,
                name: name,
                contactPerson: contactPerson,
                mobile: mobile,
                address: address,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> contactPerson = const Value.absent(),
                Value<String?> mobile = const Value.absent(),
                Value<String?> address = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SuppliersTableCompanion.insert(
                id: id,
                name: name,
                contactPerson: contactPerson,
                mobile: mobile,
                address: address,
                notes: notes,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SuppliersTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SuppliersTableTable,
      SuppliersTableData,
      $$SuppliersTableTableFilterComposer,
      $$SuppliersTableTableOrderingComposer,
      $$SuppliersTableTableAnnotationComposer,
      $$SuppliersTableTableCreateCompanionBuilder,
      $$SuppliersTableTableUpdateCompanionBuilder,
      (
        SuppliersTableData,
        BaseReferences<_$AppDatabase, $SuppliersTableTable, SuppliersTableData>,
      ),
      SuppliersTableData,
      PrefetchHooks Function()
    >;
typedef $$SavingsGoalsTableTableCreateCompanionBuilder =
    SavingsGoalsTableCompanion Function({
      required String id,
      required String name,
      required double targetAmount,
      Value<DateTime?> targetDate,
      Value<String?> notes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$SavingsGoalsTableTableUpdateCompanionBuilder =
    SavingsGoalsTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<double> targetAmount,
      Value<DateTime?> targetDate,
      Value<String?> notes,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$SavingsGoalsTableTableFilterComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTableTable> {
  $$SavingsGoalsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SavingsGoalsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTableTable> {
  $$SavingsGoalsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SavingsGoalsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingsGoalsTableTable> {
  $$SavingsGoalsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
    column: $table.targetAmount,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get targetDate => $composableBuilder(
    column: $table.targetDate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SavingsGoalsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SavingsGoalsTableTable,
          SavingsGoalsTableData,
          $$SavingsGoalsTableTableFilterComposer,
          $$SavingsGoalsTableTableOrderingComposer,
          $$SavingsGoalsTableTableAnnotationComposer,
          $$SavingsGoalsTableTableCreateCompanionBuilder,
          $$SavingsGoalsTableTableUpdateCompanionBuilder,
          (
            SavingsGoalsTableData,
            BaseReferences<
              _$AppDatabase,
              $SavingsGoalsTableTable,
              SavingsGoalsTableData
            >,
          ),
          SavingsGoalsTableData,
          PrefetchHooks Function()
        > {
  $$SavingsGoalsTableTableTableManager(
    _$AppDatabase db,
    $SavingsGoalsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingsGoalsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingsGoalsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingsGoalsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<double> targetAmount = const Value.absent(),
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsTableCompanion(
                id: id,
                name: name,
                targetAmount: targetAmount,
                targetDate: targetDate,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required double targetAmount,
                Value<DateTime?> targetDate = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SavingsGoalsTableCompanion.insert(
                id: id,
                name: name,
                targetAmount: targetAmount,
                targetDate: targetDate,
                notes: notes,
                isActive: isActive,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SavingsGoalsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SavingsGoalsTableTable,
      SavingsGoalsTableData,
      $$SavingsGoalsTableTableFilterComposer,
      $$SavingsGoalsTableTableOrderingComposer,
      $$SavingsGoalsTableTableAnnotationComposer,
      $$SavingsGoalsTableTableCreateCompanionBuilder,
      $$SavingsGoalsTableTableUpdateCompanionBuilder,
      (
        SavingsGoalsTableData,
        BaseReferences<
          _$AppDatabase,
          $SavingsGoalsTableTable,
          SavingsGoalsTableData
        >,
      ),
      SavingsGoalsTableData,
      PrefetchHooks Function()
    >;
typedef $$InventoryAuditsTableTableCreateCompanionBuilder =
    InventoryAuditsTableCompanion Function({
      required String id,
      Value<DateTime> auditDate,
      required int systemCount,
      required int physicalCount,
      required int difference,
      required String actionTaken,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$InventoryAuditsTableTableUpdateCompanionBuilder =
    InventoryAuditsTableCompanion Function({
      Value<String> id,
      Value<DateTime> auditDate,
      Value<int> systemCount,
      Value<int> physicalCount,
      Value<int> difference,
      Value<String> actionTaken,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$InventoryAuditsTableTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryAuditsTableTable> {
  $$InventoryAuditsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get auditDate => $composableBuilder(
    column: $table.auditDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systemCount => $composableBuilder(
    column: $table.systemCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get physicalCount => $composableBuilder(
    column: $table.physicalCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actionTaken => $composableBuilder(
    column: $table.actionTaken,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryAuditsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryAuditsTableTable> {
  $$InventoryAuditsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get auditDate => $composableBuilder(
    column: $table.auditDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systemCount => $composableBuilder(
    column: $table.systemCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get physicalCount => $composableBuilder(
    column: $table.physicalCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actionTaken => $composableBuilder(
    column: $table.actionTaken,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryAuditsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryAuditsTableTable> {
  $$InventoryAuditsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get auditDate =>
      $composableBuilder(column: $table.auditDate, builder: (column) => column);

  GeneratedColumn<int> get systemCount => $composableBuilder(
    column: $table.systemCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get physicalCount => $composableBuilder(
    column: $table.physicalCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difference => $composableBuilder(
    column: $table.difference,
    builder: (column) => column,
  );

  GeneratedColumn<String> get actionTaken => $composableBuilder(
    column: $table.actionTaken,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$InventoryAuditsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryAuditsTableTable,
          InventoryAuditsTableData,
          $$InventoryAuditsTableTableFilterComposer,
          $$InventoryAuditsTableTableOrderingComposer,
          $$InventoryAuditsTableTableAnnotationComposer,
          $$InventoryAuditsTableTableCreateCompanionBuilder,
          $$InventoryAuditsTableTableUpdateCompanionBuilder,
          (
            InventoryAuditsTableData,
            BaseReferences<
              _$AppDatabase,
              $InventoryAuditsTableTable,
              InventoryAuditsTableData
            >,
          ),
          InventoryAuditsTableData,
          PrefetchHooks Function()
        > {
  $$InventoryAuditsTableTableTableManager(
    _$AppDatabase db,
    $InventoryAuditsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryAuditsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InventoryAuditsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryAuditsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> auditDate = const Value.absent(),
                Value<int> systemCount = const Value.absent(),
                Value<int> physicalCount = const Value.absent(),
                Value<int> difference = const Value.absent(),
                Value<String> actionTaken = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryAuditsTableCompanion(
                id: id,
                auditDate: auditDate,
                systemCount: systemCount,
                physicalCount: physicalCount,
                difference: difference,
                actionTaken: actionTaken,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> auditDate = const Value.absent(),
                required int systemCount,
                required int physicalCount,
                required int difference,
                required String actionTaken,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryAuditsTableCompanion.insert(
                id: id,
                auditDate: auditDate,
                systemCount: systemCount,
                physicalCount: physicalCount,
                difference: difference,
                actionTaken: actionTaken,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryAuditsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryAuditsTableTable,
      InventoryAuditsTableData,
      $$InventoryAuditsTableTableFilterComposer,
      $$InventoryAuditsTableTableOrderingComposer,
      $$InventoryAuditsTableTableAnnotationComposer,
      $$InventoryAuditsTableTableCreateCompanionBuilder,
      $$InventoryAuditsTableTableUpdateCompanionBuilder,
      (
        InventoryAuditsTableData,
        BaseReferences<
          _$AppDatabase,
          $InventoryAuditsTableTable,
          InventoryAuditsTableData
        >,
      ),
      InventoryAuditsTableData,
      PrefetchHooks Function()
    >;
typedef $$InventoryAdjustmentsTableTableCreateCompanionBuilder =
    InventoryAdjustmentsTableCompanion Function({
      required String id,
      Value<DateTime> adjustmentDate,
      required int quantity,
      required String reason,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$InventoryAdjustmentsTableTableUpdateCompanionBuilder =
    InventoryAdjustmentsTableCompanion Function({
      Value<String> id,
      Value<DateTime> adjustmentDate,
      Value<int> quantity,
      Value<String> reason,
      Value<String?> notes,
      Value<int> rowid,
    });

class $$InventoryAdjustmentsTableTableFilterComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentsTableTable> {
  $$InventoryAdjustmentsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get adjustmentDate => $composableBuilder(
    column: $table.adjustmentDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InventoryAdjustmentsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentsTableTable> {
  $$InventoryAdjustmentsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get adjustmentDate => $composableBuilder(
    column: $table.adjustmentDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InventoryAdjustmentsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $InventoryAdjustmentsTableTable> {
  $$InventoryAdjustmentsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get adjustmentDate => $composableBuilder(
    column: $table.adjustmentDate,
    builder: (column) => column,
  );

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);
}

class $$InventoryAdjustmentsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InventoryAdjustmentsTableTable,
          InventoryAdjustmentsTableData,
          $$InventoryAdjustmentsTableTableFilterComposer,
          $$InventoryAdjustmentsTableTableOrderingComposer,
          $$InventoryAdjustmentsTableTableAnnotationComposer,
          $$InventoryAdjustmentsTableTableCreateCompanionBuilder,
          $$InventoryAdjustmentsTableTableUpdateCompanionBuilder,
          (
            InventoryAdjustmentsTableData,
            BaseReferences<
              _$AppDatabase,
              $InventoryAdjustmentsTableTable,
              InventoryAdjustmentsTableData
            >,
          ),
          InventoryAdjustmentsTableData,
          PrefetchHooks Function()
        > {
  $$InventoryAdjustmentsTableTableTableManager(
    _$AppDatabase db,
    $InventoryAdjustmentsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InventoryAdjustmentsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$InventoryAdjustmentsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InventoryAdjustmentsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> adjustmentDate = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<String> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryAdjustmentsTableCompanion(
                id: id,
                adjustmentDate: adjustmentDate,
                quantity: quantity,
                reason: reason,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<DateTime> adjustmentDate = const Value.absent(),
                required int quantity,
                required String reason,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => InventoryAdjustmentsTableCompanion.insert(
                id: id,
                adjustmentDate: adjustmentDate,
                quantity: quantity,
                reason: reason,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InventoryAdjustmentsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InventoryAdjustmentsTableTable,
      InventoryAdjustmentsTableData,
      $$InventoryAdjustmentsTableTableFilterComposer,
      $$InventoryAdjustmentsTableTableOrderingComposer,
      $$InventoryAdjustmentsTableTableAnnotationComposer,
      $$InventoryAdjustmentsTableTableCreateCompanionBuilder,
      $$InventoryAdjustmentsTableTableUpdateCompanionBuilder,
      (
        InventoryAdjustmentsTableData,
        BaseReferences<
          _$AppDatabase,
          $InventoryAdjustmentsTableTable,
          InventoryAdjustmentsTableData
        >,
      ),
      InventoryAdjustmentsTableData,
      PrefetchHooks Function()
    >;
typedef $$CustomerDepositsTableTableCreateCompanionBuilder =
    CustomerDepositsTableCompanion Function({
      required String id,
      required String customerId,
      required double amount,
      required String transactionType,
      Value<DateTime> createdAt,
      Value<String?> notes,
      Value<String?> deliveryId,
      Value<int> rowid,
    });
typedef $$CustomerDepositsTableTableUpdateCompanionBuilder =
    CustomerDepositsTableCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<double> amount,
      Value<String> transactionType,
      Value<DateTime> createdAt,
      Value<String?> notes,
      Value<String?> deliveryId,
      Value<int> rowid,
    });

class $$CustomerDepositsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerDepositsTableTable> {
  $$CustomerDepositsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomerDepositsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerDepositsTableTable> {
  $$CustomerDepositsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get amount => $composableBuilder(
    column: $table.amount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomerDepositsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerDepositsTableTable> {
  $$CustomerDepositsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get transactionType => $composableBuilder(
    column: $table.transactionType,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => column,
  );
}

class $$CustomerDepositsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerDepositsTableTable,
          CustomerDepositsTableData,
          $$CustomerDepositsTableTableFilterComposer,
          $$CustomerDepositsTableTableOrderingComposer,
          $$CustomerDepositsTableTableAnnotationComposer,
          $$CustomerDepositsTableTableCreateCompanionBuilder,
          $$CustomerDepositsTableTableUpdateCompanionBuilder,
          (
            CustomerDepositsTableData,
            BaseReferences<
              _$AppDatabase,
              $CustomerDepositsTableTable,
              CustomerDepositsTableData
            >,
          ),
          CustomerDepositsTableData,
          PrefetchHooks Function()
        > {
  $$CustomerDepositsTableTableTableManager(
    _$AppDatabase db,
    $CustomerDepositsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerDepositsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerDepositsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerDepositsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<double> amount = const Value.absent(),
                Value<String> transactionType = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> deliveryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerDepositsTableCompanion(
                id: id,
                customerId: customerId,
                amount: amount,
                transactionType: transactionType,
                createdAt: createdAt,
                notes: notes,
                deliveryId: deliveryId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required double amount,
                required String transactionType,
                Value<DateTime> createdAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> deliveryId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerDepositsTableCompanion.insert(
                id: id,
                customerId: customerId,
                amount: amount,
                transactionType: transactionType,
                createdAt: createdAt,
                notes: notes,
                deliveryId: deliveryId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomerDepositsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerDepositsTableTable,
      CustomerDepositsTableData,
      $$CustomerDepositsTableTableFilterComposer,
      $$CustomerDepositsTableTableOrderingComposer,
      $$CustomerDepositsTableTableAnnotationComposer,
      $$CustomerDepositsTableTableCreateCompanionBuilder,
      $$CustomerDepositsTableTableUpdateCompanionBuilder,
      (
        CustomerDepositsTableData,
        BaseReferences<
          _$AppDatabase,
          $CustomerDepositsTableTable,
          CustomerDepositsTableData
        >,
      ),
      CustomerDepositsTableData,
      PrefetchHooks Function()
    >;
typedef $$CopilotMessagesTableTableCreateCompanionBuilder =
    CopilotMessagesTableCompanion Function({
      Value<int> id,
      required String question,
      required String answer,
      required String intent,
      required int createdAt,
    });
typedef $$CopilotMessagesTableTableUpdateCompanionBuilder =
    CopilotMessagesTableCompanion Function({
      Value<int> id,
      Value<String> question,
      Value<String> answer,
      Value<String> intent,
      Value<int> createdAt,
    });

class $$CopilotMessagesTableTableFilterComposer
    extends Composer<_$AppDatabase, $CopilotMessagesTableTable> {
  $$CopilotMessagesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CopilotMessagesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CopilotMessagesTableTable> {
  $$CopilotMessagesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intent => $composableBuilder(
    column: $table.intent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CopilotMessagesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CopilotMessagesTableTable> {
  $$CopilotMessagesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<String> get intent =>
      $composableBuilder(column: $table.intent, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CopilotMessagesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CopilotMessagesTableTable,
          CopilotMessagesTableData,
          $$CopilotMessagesTableTableFilterComposer,
          $$CopilotMessagesTableTableOrderingComposer,
          $$CopilotMessagesTableTableAnnotationComposer,
          $$CopilotMessagesTableTableCreateCompanionBuilder,
          $$CopilotMessagesTableTableUpdateCompanionBuilder,
          (
            CopilotMessagesTableData,
            BaseReferences<
              _$AppDatabase,
              $CopilotMessagesTableTable,
              CopilotMessagesTableData
            >,
          ),
          CopilotMessagesTableData,
          PrefetchHooks Function()
        > {
  $$CopilotMessagesTableTableTableManager(
    _$AppDatabase db,
    $CopilotMessagesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CopilotMessagesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CopilotMessagesTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CopilotMessagesTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<String> intent = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => CopilotMessagesTableCompanion(
                id: id,
                question: question,
                answer: answer,
                intent: intent,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String question,
                required String answer,
                required String intent,
                required int createdAt,
              }) => CopilotMessagesTableCompanion.insert(
                id: id,
                question: question,
                answer: answer,
                intent: intent,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CopilotMessagesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CopilotMessagesTableTable,
      CopilotMessagesTableData,
      $$CopilotMessagesTableTableFilterComposer,
      $$CopilotMessagesTableTableOrderingComposer,
      $$CopilotMessagesTableTableAnnotationComposer,
      $$CopilotMessagesTableTableCreateCompanionBuilder,
      $$CopilotMessagesTableTableUpdateCompanionBuilder,
      (
        CopilotMessagesTableData,
        BaseReferences<
          _$AppDatabase,
          $CopilotMessagesTableTable,
          CopilotMessagesTableData
        >,
      ),
      CopilotMessagesTableData,
      PrefetchHooks Function()
    >;
typedef $$CustomerBottleReconciliationsTableTableCreateCompanionBuilder =
    CustomerBottleReconciliationsTableCompanion Function({
      required String id,
      required String customerId,
      required int expectedCount,
      required int actualCount,
      required int variance,
      Value<String?> reason,
      Value<String?> notes,
      Value<bool> adjustmentApplied,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$CustomerBottleReconciliationsTableTableUpdateCompanionBuilder =
    CustomerBottleReconciliationsTableCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<int> expectedCount,
      Value<int> actualCount,
      Value<int> variance,
      Value<String?> reason,
      Value<String?> notes,
      Value<bool> adjustmentApplied,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$CustomerBottleReconciliationsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerBottleReconciliationsTableTable> {
  $$CustomerBottleReconciliationsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get expectedCount => $composableBuilder(
    column: $table.expectedCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get actualCount => $composableBuilder(
    column: $table.actualCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get variance => $composableBuilder(
    column: $table.variance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get adjustmentApplied => $composableBuilder(
    column: $table.adjustmentApplied,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomerBottleReconciliationsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerBottleReconciliationsTableTable> {
  $$CustomerBottleReconciliationsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get expectedCount => $composableBuilder(
    column: $table.expectedCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get actualCount => $composableBuilder(
    column: $table.actualCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get variance => $composableBuilder(
    column: $table.variance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reason => $composableBuilder(
    column: $table.reason,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get adjustmentApplied => $composableBuilder(
    column: $table.adjustmentApplied,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomerBottleReconciliationsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerBottleReconciliationsTableTable> {
  $$CustomerBottleReconciliationsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get expectedCount => $composableBuilder(
    column: $table.expectedCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get actualCount => $composableBuilder(
    column: $table.actualCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get variance =>
      $composableBuilder(column: $table.variance, builder: (column) => column);

  GeneratedColumn<String> get reason =>
      $composableBuilder(column: $table.reason, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<bool> get adjustmentApplied => $composableBuilder(
    column: $table.adjustmentApplied,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$CustomerBottleReconciliationsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerBottleReconciliationsTableTable,
          CustomerBottleReconciliationsTableData,
          $$CustomerBottleReconciliationsTableTableFilterComposer,
          $$CustomerBottleReconciliationsTableTableOrderingComposer,
          $$CustomerBottleReconciliationsTableTableAnnotationComposer,
          $$CustomerBottleReconciliationsTableTableCreateCompanionBuilder,
          $$CustomerBottleReconciliationsTableTableUpdateCompanionBuilder,
          (
            CustomerBottleReconciliationsTableData,
            BaseReferences<
              _$AppDatabase,
              $CustomerBottleReconciliationsTableTable,
              CustomerBottleReconciliationsTableData
            >,
          ),
          CustomerBottleReconciliationsTableData,
          PrefetchHooks Function()
        > {
  $$CustomerBottleReconciliationsTableTableTableManager(
    _$AppDatabase db,
    $CustomerBottleReconciliationsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerBottleReconciliationsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerBottleReconciliationsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerBottleReconciliationsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<int> expectedCount = const Value.absent(),
                Value<int> actualCount = const Value.absent(),
                Value<int> variance = const Value.absent(),
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> adjustmentApplied = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerBottleReconciliationsTableCompanion(
                id: id,
                customerId: customerId,
                expectedCount: expectedCount,
                actualCount: actualCount,
                variance: variance,
                reason: reason,
                notes: notes,
                adjustmentApplied: adjustmentApplied,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required int expectedCount,
                required int actualCount,
                required int variance,
                Value<String?> reason = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<bool> adjustmentApplied = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerBottleReconciliationsTableCompanion.insert(
                id: id,
                customerId: customerId,
                expectedCount: expectedCount,
                actualCount: actualCount,
                variance: variance,
                reason: reason,
                notes: notes,
                adjustmentApplied: adjustmentApplied,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomerBottleReconciliationsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerBottleReconciliationsTableTable,
      CustomerBottleReconciliationsTableData,
      $$CustomerBottleReconciliationsTableTableFilterComposer,
      $$CustomerBottleReconciliationsTableTableOrderingComposer,
      $$CustomerBottleReconciliationsTableTableAnnotationComposer,
      $$CustomerBottleReconciliationsTableTableCreateCompanionBuilder,
      $$CustomerBottleReconciliationsTableTableUpdateCompanionBuilder,
      (
        CustomerBottleReconciliationsTableData,
        BaseReferences<
          _$AppDatabase,
          $CustomerBottleReconciliationsTableTable,
          CustomerBottleReconciliationsTableData
        >,
      ),
      CustomerBottleReconciliationsTableData,
      PrefetchHooks Function()
    >;
typedef $$CustomerOwnedBottleLogsTableTableCreateCompanionBuilder =
    CustomerOwnedBottleLogsTableCompanion Function({
      required String id,
      required String customerId,
      required String eventType,
      Value<int> businessOwnedDelta,
      Value<int> customerOwnedDelta,
      required int businessOwnedAfter,
      required int customerOwnedAfter,
      required DateTime date,
      Value<String?> notes,
      Value<String?> deliveryId,
      Value<String?> bottleTransactionId,
      Value<int> rowid,
    });
typedef $$CustomerOwnedBottleLogsTableTableUpdateCompanionBuilder =
    CustomerOwnedBottleLogsTableCompanion Function({
      Value<String> id,
      Value<String> customerId,
      Value<String> eventType,
      Value<int> businessOwnedDelta,
      Value<int> customerOwnedDelta,
      Value<int> businessOwnedAfter,
      Value<int> customerOwnedAfter,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String?> deliveryId,
      Value<String?> bottleTransactionId,
      Value<int> rowid,
    });

class $$CustomerOwnedBottleLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $CustomerOwnedBottleLogsTableTable> {
  $$CustomerOwnedBottleLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get businessOwnedDelta => $composableBuilder(
    column: $table.businessOwnedDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerOwnedDelta => $composableBuilder(
    column: $table.customerOwnedDelta,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get businessOwnedAfter => $composableBuilder(
    column: $table.businessOwnedAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerOwnedAfter => $composableBuilder(
    column: $table.customerOwnedAfter,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get bottleTransactionId => $composableBuilder(
    column: $table.bottleTransactionId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$CustomerOwnedBottleLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $CustomerOwnedBottleLogsTableTable> {
  $$CustomerOwnedBottleLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get businessOwnedDelta => $composableBuilder(
    column: $table.businessOwnedDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerOwnedDelta => $composableBuilder(
    column: $table.customerOwnedDelta,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get businessOwnedAfter => $composableBuilder(
    column: $table.businessOwnedAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerOwnedAfter => $composableBuilder(
    column: $table.customerOwnedAfter,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get bottleTransactionId => $composableBuilder(
    column: $table.bottleTransactionId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$CustomerOwnedBottleLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $CustomerOwnedBottleLogsTableTable> {
  $$CustomerOwnedBottleLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get businessOwnedDelta => $composableBuilder(
    column: $table.businessOwnedDelta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerOwnedDelta => $composableBuilder(
    column: $table.customerOwnedDelta,
    builder: (column) => column,
  );

  GeneratedColumn<int> get businessOwnedAfter => $composableBuilder(
    column: $table.businessOwnedAfter,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerOwnedAfter => $composableBuilder(
    column: $table.customerOwnedAfter,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get deliveryId => $composableBuilder(
    column: $table.deliveryId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get bottleTransactionId => $composableBuilder(
    column: $table.bottleTransactionId,
    builder: (column) => column,
  );
}

class $$CustomerOwnedBottleLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $CustomerOwnedBottleLogsTableTable,
          CustomerOwnedBottleLogsTableData,
          $$CustomerOwnedBottleLogsTableTableFilterComposer,
          $$CustomerOwnedBottleLogsTableTableOrderingComposer,
          $$CustomerOwnedBottleLogsTableTableAnnotationComposer,
          $$CustomerOwnedBottleLogsTableTableCreateCompanionBuilder,
          $$CustomerOwnedBottleLogsTableTableUpdateCompanionBuilder,
          (
            CustomerOwnedBottleLogsTableData,
            BaseReferences<
              _$AppDatabase,
              $CustomerOwnedBottleLogsTableTable,
              CustomerOwnedBottleLogsTableData
            >,
          ),
          CustomerOwnedBottleLogsTableData,
          PrefetchHooks Function()
        > {
  $$CustomerOwnedBottleLogsTableTableTableManager(
    _$AppDatabase db,
    $CustomerOwnedBottleLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CustomerOwnedBottleLogsTableTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$CustomerOwnedBottleLogsTableTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$CustomerOwnedBottleLogsTableTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> customerId = const Value.absent(),
                Value<String> eventType = const Value.absent(),
                Value<int> businessOwnedDelta = const Value.absent(),
                Value<int> customerOwnedDelta = const Value.absent(),
                Value<int> businessOwnedAfter = const Value.absent(),
                Value<int> customerOwnedAfter = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String?> deliveryId = const Value.absent(),
                Value<String?> bottleTransactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerOwnedBottleLogsTableCompanion(
                id: id,
                customerId: customerId,
                eventType: eventType,
                businessOwnedDelta: businessOwnedDelta,
                customerOwnedDelta: customerOwnedDelta,
                businessOwnedAfter: businessOwnedAfter,
                customerOwnedAfter: customerOwnedAfter,
                date: date,
                notes: notes,
                deliveryId: deliveryId,
                bottleTransactionId: bottleTransactionId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String customerId,
                required String eventType,
                Value<int> businessOwnedDelta = const Value.absent(),
                Value<int> customerOwnedDelta = const Value.absent(),
                required int businessOwnedAfter,
                required int customerOwnedAfter,
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<String?> deliveryId = const Value.absent(),
                Value<String?> bottleTransactionId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => CustomerOwnedBottleLogsTableCompanion.insert(
                id: id,
                customerId: customerId,
                eventType: eventType,
                businessOwnedDelta: businessOwnedDelta,
                customerOwnedDelta: customerOwnedDelta,
                businessOwnedAfter: businessOwnedAfter,
                customerOwnedAfter: customerOwnedAfter,
                date: date,
                notes: notes,
                deliveryId: deliveryId,
                bottleTransactionId: bottleTransactionId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$CustomerOwnedBottleLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $CustomerOwnedBottleLogsTableTable,
      CustomerOwnedBottleLogsTableData,
      $$CustomerOwnedBottleLogsTableTableFilterComposer,
      $$CustomerOwnedBottleLogsTableTableOrderingComposer,
      $$CustomerOwnedBottleLogsTableTableAnnotationComposer,
      $$CustomerOwnedBottleLogsTableTableCreateCompanionBuilder,
      $$CustomerOwnedBottleLogsTableTableUpdateCompanionBuilder,
      (
        CustomerOwnedBottleLogsTableData,
        BaseReferences<
          _$AppDatabase,
          $CustomerOwnedBottleLogsTableTable,
          CustomerOwnedBottleLogsTableData
        >,
      ),
      CustomerOwnedBottleLogsTableData,
      PrefetchHooks Function()
    >;
typedef $$WalkInSalesTableTableCreateCompanionBuilder =
    WalkInSalesTableCompanion Function({
      required String id,
      Value<String?> customerId,
      required String walkInType,
      Value<int> businessOwnedQuantity,
      Value<int> customerOwnedQuantity,
      Value<int> returnedEmptyQuantity,
      required double pricePerBottle,
      required double totalAmount,
      Value<String> paymentMethod,
      Value<String?> notes,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });
typedef $$WalkInSalesTableTableUpdateCompanionBuilder =
    WalkInSalesTableCompanion Function({
      Value<String> id,
      Value<String?> customerId,
      Value<String> walkInType,
      Value<int> businessOwnedQuantity,
      Value<int> customerOwnedQuantity,
      Value<int> returnedEmptyQuantity,
      Value<double> pricePerBottle,
      Value<double> totalAmount,
      Value<String> paymentMethod,
      Value<String?> notes,
      Value<DateTime> date,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$WalkInSalesTableTableFilterComposer
    extends Composer<_$AppDatabase, $WalkInSalesTableTable> {
  $$WalkInSalesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get walkInType => $composableBuilder(
    column: $table.walkInType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get businessOwnedQuantity => $composableBuilder(
    column: $table.businessOwnedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get customerOwnedQuantity => $composableBuilder(
    column: $table.customerOwnedQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get returnedEmptyQuantity => $composableBuilder(
    column: $table.returnedEmptyQuantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get pricePerBottle => $composableBuilder(
    column: $table.pricePerBottle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WalkInSalesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $WalkInSalesTableTable> {
  $$WalkInSalesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get walkInType => $composableBuilder(
    column: $table.walkInType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get businessOwnedQuantity => $composableBuilder(
    column: $table.businessOwnedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get customerOwnedQuantity => $composableBuilder(
    column: $table.customerOwnedQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get returnedEmptyQuantity => $composableBuilder(
    column: $table.returnedEmptyQuantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get pricePerBottle => $composableBuilder(
    column: $table.pricePerBottle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WalkInSalesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $WalkInSalesTableTable> {
  $$WalkInSalesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get customerId => $composableBuilder(
    column: $table.customerId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get walkInType => $composableBuilder(
    column: $table.walkInType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get businessOwnedQuantity => $composableBuilder(
    column: $table.businessOwnedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get customerOwnedQuantity => $composableBuilder(
    column: $table.customerOwnedQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get returnedEmptyQuantity => $composableBuilder(
    column: $table.returnedEmptyQuantity,
    builder: (column) => column,
  );

  GeneratedColumn<double> get pricePerBottle => $composableBuilder(
    column: $table.pricePerBottle,
    builder: (column) => column,
  );

  GeneratedColumn<double> get totalAmount => $composableBuilder(
    column: $table.totalAmount,
    builder: (column) => column,
  );

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
    column: $table.paymentMethod,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$WalkInSalesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $WalkInSalesTableTable,
          WalkInSalesTableData,
          $$WalkInSalesTableTableFilterComposer,
          $$WalkInSalesTableTableOrderingComposer,
          $$WalkInSalesTableTableAnnotationComposer,
          $$WalkInSalesTableTableCreateCompanionBuilder,
          $$WalkInSalesTableTableUpdateCompanionBuilder,
          (
            WalkInSalesTableData,
            BaseReferences<
              _$AppDatabase,
              $WalkInSalesTableTable,
              WalkInSalesTableData
            >,
          ),
          WalkInSalesTableData,
          PrefetchHooks Function()
        > {
  $$WalkInSalesTableTableTableManager(
    _$AppDatabase db,
    $WalkInSalesTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WalkInSalesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WalkInSalesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WalkInSalesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> customerId = const Value.absent(),
                Value<String> walkInType = const Value.absent(),
                Value<int> businessOwnedQuantity = const Value.absent(),
                Value<int> customerOwnedQuantity = const Value.absent(),
                Value<int> returnedEmptyQuantity = const Value.absent(),
                Value<double> pricePerBottle = const Value.absent(),
                Value<double> totalAmount = const Value.absent(),
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalkInSalesTableCompanion(
                id: id,
                customerId: customerId,
                walkInType: walkInType,
                businessOwnedQuantity: businessOwnedQuantity,
                customerOwnedQuantity: customerOwnedQuantity,
                returnedEmptyQuantity: returnedEmptyQuantity,
                pricePerBottle: pricePerBottle,
                totalAmount: totalAmount,
                paymentMethod: paymentMethod,
                notes: notes,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> customerId = const Value.absent(),
                required String walkInType,
                Value<int> businessOwnedQuantity = const Value.absent(),
                Value<int> customerOwnedQuantity = const Value.absent(),
                Value<int> returnedEmptyQuantity = const Value.absent(),
                required double pricePerBottle,
                required double totalAmount,
                Value<String> paymentMethod = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WalkInSalesTableCompanion.insert(
                id: id,
                customerId: customerId,
                walkInType: walkInType,
                businessOwnedQuantity: businessOwnedQuantity,
                customerOwnedQuantity: customerOwnedQuantity,
                returnedEmptyQuantity: returnedEmptyQuantity,
                pricePerBottle: pricePerBottle,
                totalAmount: totalAmount,
                paymentMethod: paymentMethod,
                notes: notes,
                date: date,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WalkInSalesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $WalkInSalesTableTable,
      WalkInSalesTableData,
      $$WalkInSalesTableTableFilterComposer,
      $$WalkInSalesTableTableOrderingComposer,
      $$WalkInSalesTableTableAnnotationComposer,
      $$WalkInSalesTableTableCreateCompanionBuilder,
      $$WalkInSalesTableTableUpdateCompanionBuilder,
      (
        WalkInSalesTableData,
        BaseReferences<
          _$AppDatabase,
          $WalkInSalesTableTable,
          WalkInSalesTableData
        >,
      ),
      WalkInSalesTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CustomersTableTableTableManager get customersTable =>
      $$CustomersTableTableTableManager(_db, _db.customersTable);
  $$DeliveriesTableTableTableManager get deliveriesTable =>
      $$DeliveriesTableTableTableManager(_db, _db.deliveriesTable);
  $$BottleTransactionsTableTableTableManager get bottleTransactionsTable =>
      $$BottleTransactionsTableTableTableManager(
        _db,
        _db.bottleTransactionsTable,
      );
  $$PaymentsTableTableTableManager get paymentsTable =>
      $$PaymentsTableTableTableManager(_db, _db.paymentsTable);
  $$ExpensesTableTableTableManager get expensesTable =>
      $$ExpensesTableTableTableManager(_db, _db.expensesTable);
  $$DispenserSalesTableTableTableManager get dispenserSalesTable =>
      $$DispenserSalesTableTableTableManager(_db, _db.dispenserSalesTable);
  $$SettingsTableTableTableManager get settingsTable =>
      $$SettingsTableTableTableManager(_db, _db.settingsTable);
  $$SavingsContributionsTableTableTableManager get savingsContributionsTable =>
      $$SavingsContributionsTableTableTableManager(
        _db,
        _db.savingsContributionsTable,
      );
  $$SupplyPurchasesTableTableTableManager get supplyPurchasesTable =>
      $$SupplyPurchasesTableTableTableManager(_db, _db.supplyPurchasesTable);
  $$InventoryStockTableTableTableManager get inventoryStockTable =>
      $$InventoryStockTableTableTableManager(_db, _db.inventoryStockTable);
  $$SuppliersTableTableTableManager get suppliersTable =>
      $$SuppliersTableTableTableManager(_db, _db.suppliersTable);
  $$SavingsGoalsTableTableTableManager get savingsGoalsTable =>
      $$SavingsGoalsTableTableTableManager(_db, _db.savingsGoalsTable);
  $$InventoryAuditsTableTableTableManager get inventoryAuditsTable =>
      $$InventoryAuditsTableTableTableManager(_db, _db.inventoryAuditsTable);
  $$InventoryAdjustmentsTableTableTableManager get inventoryAdjustmentsTable =>
      $$InventoryAdjustmentsTableTableTableManager(
        _db,
        _db.inventoryAdjustmentsTable,
      );
  $$CustomerDepositsTableTableTableManager get customerDepositsTable =>
      $$CustomerDepositsTableTableTableManager(_db, _db.customerDepositsTable);
  $$CopilotMessagesTableTableTableManager get copilotMessagesTable =>
      $$CopilotMessagesTableTableTableManager(_db, _db.copilotMessagesTable);
  $$CustomerBottleReconciliationsTableTableTableManager
  get customerBottleReconciliationsTable =>
      $$CustomerBottleReconciliationsTableTableTableManager(
        _db,
        _db.customerBottleReconciliationsTable,
      );
  $$CustomerOwnedBottleLogsTableTableTableManager
  get customerOwnedBottleLogsTable =>
      $$CustomerOwnedBottleLogsTableTableTableManager(
        _db,
        _db.customerOwnedBottleLogsTable,
      );
  $$WalkInSalesTableTableTableManager get walkInSalesTable =>
      $$WalkInSalesTableTableTableManager(_db, _db.walkInSalesTable);
}
