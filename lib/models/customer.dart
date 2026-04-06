class Customer {
  final int id;
  final String name;
  final String? phone;
  final String? address;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int ordersCount;
  final DateTime? latestOrderDate;
  final int? latestOrderNumber;
  final bool hasOrders;

  Customer({
    required this.id,
    required this.name,
    this.phone,
    this.address,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.ordersCount = 0,
    this.latestOrderDate,
    this.latestOrderNumber,
    this.hasOrders = false,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      name: json['name'],
      phone: json['phone'],
      address: json['address'],
      notes: json['notes'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      ordersCount: json['orders_count'] ?? 0,
      latestOrderDate: json['latest_order_date'] != null
          ? DateTime.parse(json['latest_order_date'])
          : null,
      latestOrderNumber: json['latest_order_number'],
      hasOrders: json['has_orders'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'orders_count': ordersCount,
      'latest_order_date': latestOrderDate?.toIso8601String(),
      'latest_order_number': latestOrderNumber,
      'has_orders': hasOrders,
    };
  }
}
