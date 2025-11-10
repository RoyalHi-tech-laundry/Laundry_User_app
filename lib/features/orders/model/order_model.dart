class OrderList {
  final bool success;
  final List<Order> data;
  final Pagination pagination;

  OrderList({
    required this.success,
    required this.data,
    required this.pagination,
  });

  factory OrderList.fromJson(Map<String, dynamic> json) {
    return OrderList(
      success: json['success'] ?? false,
      data: (json['data'] as List<dynamic>)
          .map((item) => Order.fromJson(item))
          .toList(),
      pagination: Pagination.fromJson(json['pagination']),
    );
  }
}

class Order {
  final int id;
  final String orderNumber;
  final OrderStatus status;
  final DateTime pickupDate;
  final String pickupTimeSlot;
  final double totalAmount;
  final DateTime createdAt;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.pickupDate,
    required this.pickupTimeSlot,
    required this.totalAmount,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'],
      status: _getOrderStatusFromString(json['status']),
      pickupDate: DateTime.parse(json['pickupDate']),
      pickupTimeSlot: json['pickupTimeSlot'],
      totalAmount: json['totalAmount'].toDouble(),
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  // Helper method to convert string to OrderStatus enum
  static OrderStatus _getOrderStatusFromString(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return OrderStatus.pending;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'PICKED_UP':
        return OrderStatus.pickedUp;
      case 'IN_PROGRESS':
        return OrderStatus.inProgress;
      case 'READY_FOR_DELIVERY':
        return OrderStatus.readyForDelivery;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELLED':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }

  // Get color for status
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return '#FFA000'; // Amber
      case OrderStatus.confirmed:
        return '#1976D2'; // Blue
      case OrderStatus.pickedUp:
        return '#7B1FA2'; // Purple
      case OrderStatus.inProgress:
        return '#0097A7'; // Cyan
      case OrderStatus.readyForDelivery:
        return '#388E3C'; // Green
      case OrderStatus.delivered:
        return '#43A047'; // Light Green
      case OrderStatus.cancelled:
        return '#D32F2F'; // Red
    }
  }

  // Get display text for status
  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.readyForDelivery:
        return 'Ready for Delivery';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Format pickup date
  String get formattedPickupDate {
    return '${pickupDate.day}/${pickupDate.month}/${pickupDate.year}';
  }

  // Format created date
  String get formattedCreatedDate {
    return '${createdAt.day}/${createdAt.month}/${createdAt.year}';
  }
}

class Pagination {
  final int total;
  final int page;
  final int size;
  final int totalPages;

  Pagination({
    required this.total,
    required this.page,
    required this.size,
    required this.totalPages,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    return Pagination(
      total: json['total'],
      page: json['page'],
      size: json['size'],
      totalPages: json['totalPages'],
    );
  }
}

enum OrderStatus {
  pending,
  confirmed,
  pickedUp,
  inProgress,
  readyForDelivery,
  delivered,
  cancelled,
}
