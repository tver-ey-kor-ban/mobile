class QuotationItem {
  final String itemType;
  final String name;
  final int quantity;
  final double unitPrice;

  QuotationItem({
    required this.itemType,
    required this.name,
    required this.quantity,
    required this.unitPrice,
  });

  factory QuotationItem.fromJson(Map<String, dynamic> json) {
    return QuotationItem(
      itemType: json['item_type'] ?? 'labor',
      name: json['name'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unit_price'] ?? 0).toDouble(),
    );
  }

  double get totalPrice => quantity * unitPrice;
}

class QuotationModel {
  final int id;
  final int? appointmentId;
  final String title;
  final String? description;
  final String status;
  final double laborCost;
  final double partsCost;
  final double taxAmount;
  final double discountAmount;
  final double totalAmount;
  final List<QuotationItem> items;
  final String createdAt;
  final String? shopName;
  final String? rejectionReason;

  QuotationModel({
    required this.id,
    this.appointmentId,
    required this.title,
    this.description,
    required this.status,
    required this.laborCost,
    required this.partsCost,
    required this.taxAmount,
    required this.discountAmount,
    required this.totalAmount,
    this.items = const [],
    required this.createdAt,
    this.shopName,
    this.rejectionReason,
  });

  factory QuotationModel.fromJson(Map<String, dynamic> json) {
    final itemsList = (json['items'] as List<dynamic>?)
            ?.map((e) => QuotationItem.fromJson(e))
            .toList() ??
        [];
    return QuotationModel(
      id: json['id'] ?? 0,
      appointmentId: json['appointment_id'],
      title: json['title'] ?? '',
      description: json['description'],
      status: json['status'] ?? 'draft',
      laborCost: (json['labor_cost'] ?? 0).toDouble(),
      partsCost: (json['parts_cost'] ?? 0).toDouble(),
      taxAmount: (json['tax_amount'] ?? 0).toDouble(),
      discountAmount: (json['discount_amount'] ?? 0).toDouble(),
      totalAmount: (json['total_amount'] ?? 0).toDouble(),
      items: itemsList,
      createdAt: json['created_at'] ?? '',
      shopName: json['shop_name'] ?? json['shop']?['name'],
      rejectionReason: json['rejection_reason'],
    );
  }
}
