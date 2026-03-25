class Order {
  final int orderno;
  final int customerCode;
  final String customerName;
  final DateTime? date;
  final double? orderValue;
  final String? branchName2;
  final String status;
  final String statusDisplay;
  final int itemsCount;
  final List<OrderItem> items;

  Order({
    required this.orderno,
    required this.customerCode,
    required this.customerName,
    this.date,
    this.orderValue,
    this.branchName2,
    required this.status,
    required this.statusDisplay,
    required this.itemsCount,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    try {
      var items = <OrderItem>[];
      if (json['items'] != null) {
        final itemsList = json['items'] as List;
        items = itemsList.map((item) => OrderItem.fromJson(item)).toList();
      }

      // Parse orderValue safely
      double? parsedOrderValue;
      if (json['order_value'] != null) {
        if (json['order_value'] is String) {
          parsedOrderValue = double.tryParse(json['order_value']);
        } else if (json['order_value'] is num) {
          parsedOrderValue = (json['order_value'] as num).toDouble();
        }
      }



      return Order(
        orderno: json['orderno'],
        customerCode: json['customer_code'] != null
            ? (json['customer_code'] is int ? json['customer_code'] : json['customer_code']['code'])
            : 0,
        customerName: json['customer_details']?['cust'] ?? json['customer_details']?['re_name'] ?? '',
        date: json['date'] != null ? DateTime.parse(json['date']) : null,
        orderValue: parsedOrderValue,
        branchName2: json['branch_name2'],
        status: json['status'] ?? '',
        statusDisplay: json['status_display'] ?? '',
        itemsCount: items.length,
        items: items,
      );
    } catch (e) {
      print('Error parsing Order: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'orderno': orderno,
      'customer_code': {'code': customerCode},
      'customer_name': customerName,
      'date': date?.toIso8601String(),
      'order_value': orderValue,
      'branch_name2': branchName2,
      'status': status,
      'status_display': statusDisplay,
    };
  }
}

class OrderItem {
  final int id;
  final String itemName;
  final String? colorName;
  final String? itemNote;
  final String? status;

  OrderItem({
    required this.id,
    required this.itemName,
    this.colorName,
    this.itemNote,
    this.status,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    try {
      return OrderItem(
        id: json['id'] ?? json['recno'] ?? 0,
        itemName: json['item_name'] ?? json['itemName'] ?? '',
        colorName: json['color_name'] ?? json['colorName'],
        itemNote: json['item_note'] ?? json['itemNote'] ?? '',
        status: json['status'] ?? '',
      );
    } catch (e) {
      print('Error parsing OrderItem: $e');
      print('JSON data: $json');
      rethrow;
    }
  }
}
