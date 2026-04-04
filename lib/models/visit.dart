import 'customer.dart';
import 'measurement.dart';
import 'visit_image.dart';

class Visit {
  final int id;
  final int customerId;
  final String? customerName;
  final Customer? customerDetails;
  final int delegateId;
  final String? delegateName;
  final String status;
  final DateTime? scheduledAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final String? notes;
  final List<Measurement>? measurements;
  final List<VisitImage>? images;
  final int? visitNumber;
  final bool isMainVisit;
  final int? orderNumber;
  final bool? hasLocation;
  final Map<String, double>? latestLocation;
  final DateTime createdAt;
  final DateTime updatedAt;

  Visit({
    required this.id,
    required this.customerId,
    this.customerName,
    this.customerDetails,
    required this.delegateId,
    this.delegateName,
    required this.status,
    this.scheduledAt,
    this.startedAt,
    this.completedAt,
    this.notes,
    this.measurements,
    this.images,
    this.visitNumber,
    this.isMainVisit = true,
    this.orderNumber,
    this.hasLocation,
    this.latestLocation,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Visit.fromJson(Map<String, dynamic> json) {
    return Visit(
      id: json['id'],
      customerId: json['customer'],
      customerName: json['customer_name'],
      customerDetails: json['customer_details'] != null
          ? Customer.fromJson(json['customer_details'])
          : null,
      delegateId: json['delegate'],
      delegateName: json['delegate_name'],
      status: json['status'],
      scheduledAt: json['scheduled_at'] != null
          ? DateTime.parse(json['scheduled_at'])
          : null,
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'])
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'])
          : null,
      notes: json['notes'],
      measurements: json['measurements'] != null
          ? (json['measurements'] as List)
              .map((m) => Measurement.fromJson(m))
              .toList()
          : null,
      images: json['images'] != null
          ? (json['images'] as List).map((i) => VisitImage.fromJson(i)).toList()
          : null,
      visitNumber: json['visit_number'],
      isMainVisit: json['is_main_visit'] ?? true,
      orderNumber: json['order_number'],
      hasLocation: json['has_location'],
      latestLocation: json['latest_location'] != null
          ? Map<String, double>.from(json['latest_location'])
          : null,
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer': customerId,
      'customer_name': customerName,
      'delegate': delegateId,
      'delegate_name': delegateName,
      'status': status,
      'scheduled_at': scheduledAt?.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'Pending';
      case 'in_progress':
        return 'In Progress';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}
