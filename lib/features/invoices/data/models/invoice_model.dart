class InvoiceItem {
  final String itemType;
  final String name;
  final int quantity;
  final double unitPrice;

  InvoiceItem({
    required this.itemType,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      itemType: json['item_type'] ?? 'labor',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  double get totalPrice => quantity * unitPrice;
}

class PaymentRecord {
  final double amount;
  final String method;
  final String? reference;
  final String? notes;
  final String createdAt;

  PaymentRecord({
    required this.amount,
    required this.method,
    this.reference,
    this.notes,
    required this.createdAt,
  });

  factory PaymentRecord.fromJson(Map<String, dynamic> json) {
    return PaymentRecord(
      amount: (json['amount'] ?? 0).toDouble(),
      method: json['method'] ?? 'cash',
      reference: json['reference'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class InvoiceModel {
  final int id;
  final int? appointmentId;
  final String status;
  final double laborCost;
  final double partsCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final String? dueDate;
  final List<InvoiceItem> items;
  final List<PaymentRecord> payments;
  final String createdAt;
  final String? shopName;

  InvoiceModel({
    required this.id,
    this.appointmentId,
    required this.status,
    required this.laborCost,
    required this.partsCost,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.dueDate,
    this.items = const [],
    this.payments = const [],
    required this.createdAt,
    this.shopName,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => InvoiceItem.fromJson(e))
            .toList() ??
        [];
    final paymentsList = (json['payments'] as List<dynamic>?)
            ?.map((e) => PaymentRecord.fromJson(e))
            .toList() ??
        [];
    return InvoiceModel(
      id: json['id'] ?? 0,
      appointmentId: json['appointment_id'],
      status: json['status'] ?? 'draft',
      laborCost: (json['labor_cost'] ?? 0).toDouble(),
      partsCost: (json['parts_cost'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      dueDate: json['due_date'],
      items: itemsList,
      payments: paymentsList,
      createdAt: json['created_at'] ?? '',
      shopName: json['shop_name'] ?? json['shop']?['name'],
    );
  }
}
