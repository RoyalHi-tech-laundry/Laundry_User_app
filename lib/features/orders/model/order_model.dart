import 'package:flutter/material.dart';

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
  final List<OrderItem>? items;
  final dynamic address; // Can be Map or specific Address model if known
  final List<StatusHistory>? statusHistory;

  Order({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.pickupDate,
    required this.pickupTimeSlot,
    required this.totalAmount,
    required this.createdAt,
    this.items,
    this.address,
    this.statusHistory,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem>? parsedItems;
    if (json['items'] != null && json['items'] is List) {
      parsedItems = (json['items'] as List)
          .map((i) => OrderItem.fromJson(i))
          .toList();
    } else if (json['orderItems'] != null && json['orderItems'] is List) {
       parsedItems = (json['orderItems'] as List)
          .map((i) => OrderItem.fromJson(i))
          .toList();
    }

    List<StatusHistory>? parsedStatusHistory;
    if (json['statusHistory'] != null && json['statusHistory'] is List) {
      parsedStatusHistory = (json['statusHistory'] as List)
          .map((i) => StatusHistory.fromJson(i))
          .toList();
    }

    return Order(
      id: json['id'],
      orderNumber: json['orderNumber'] ?? '',
      status: _getOrderStatusFromString(json['status'] ?? 'PENDING'),
      pickupDate: json['pickupDate'] != null 
          ? DateTime.parse(json['pickupDate']) 
          : DateTime.now(),
      pickupTimeSlot: json['pickupTimeSlot'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      items: parsedItems,
      address: json['address'],
      statusHistory: parsedStatusHistory,
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

  // Create a copy of the order with updated fields
  Order copyWith({
    int? id,
    String? orderNumber,
    OrderStatus? status,
    DateTime? pickupDate,
    String? pickupTimeSlot,
    double? totalAmount,
    DateTime? createdAt,
    List<OrderItem>? items,
    dynamic address,
  }) {
    return Order(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      pickupDate: pickupDate ?? this.pickupDate,
      pickupTimeSlot: pickupTimeSlot ?? this.pickupTimeSlot,
      totalAmount: totalAmount ?? this.totalAmount,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      address: address ?? this.address,
    );
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
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      size: json['size'] ?? 10,
      totalPages: json['totalPages'] ?? 1,
    );
  }
}

class OrderItem {
  final String name;
  final int quantity;
  final double price;
  final double? tax;

  OrderItem({
    required this.name,
    required this.quantity,
    required this.price,
    this.tax,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // Attempt to handle different JSON structures
    String name = 'Unknown Item';
    if (json['serviceName'] != null) name = json['serviceName'];
    if (json['name'] != null) name = json['name'];
    if (json['service'] != null && json['service'] is Map)  name = json['service']['name'] ?? 'Unknown Item';

    return OrderItem(
      name: name,
      quantity: json['quantity'] ?? 1,
      price: (json['price'] ?? json['unitPrice'] ?? 0).toDouble(),
      tax: json['tax'] != null ? (json['tax']).toDouble() : null,
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

class StatusHistory {
  final int id;
  final String status;
  final String? notes;
  final DateTime createdAt;

  StatusHistory({
    required this.id,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  factory StatusHistory.fromJson(Map<String, dynamic> json) {
    return StatusHistory(
      id: json['id'],
      status: json['status'] ?? '',
      notes: json['notes'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
    );
  }

  // Get display text for status
  String get statusDisplay {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 'Order Placed';
      case 'CONFIRMED':
        return 'Order Confirmed';
      case 'PICKED_UP':
        return 'Picked Up';
      case 'PROCESSING':
      case 'IN_PROGRESS':
        return 'Processing';
      case 'READY_FOR_DELIVERY':
        return 'Ready for Delivery';
      case 'OUT_FOR_DELIVERY':
        return 'Out for Delivery';
      case 'DELIVERED':
        return 'Delivered';
      case 'CANCELLED':
        return 'Cancelled';
      default:
        return status;
    }
  }

  // Get color for status
  dynamic get statusColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0xFFFFB300; // Amber (600)
      case 'CONFIRMED':
      case 'PICKED_UP':
      case 'PROCESSING':
      case 'IN_PROGRESS':
      case 'READY_FOR_DELIVERY':
      case 'OUT_FOR_DELIVERY':
        return 0xFF1976D2; // Blue (700)
      case 'DELIVERED':
        return 0xFF388E3C; // Green (700)
      case 'CANCELLED':
        return 0xFFD32F2F; // Red (700)
      default:
        return 0xFF757575; // Grey
    }
  }

  // Get background color for status
  dynamic get statusBackgroundColor {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return 0xFFFFF8E1; // Amber (50)
      case 'CONFIRMED':
      case 'PICKED_UP':
      case 'PROCESSING':
      case 'IN_PROGRESS':
      case 'READY_FOR_DELIVERY':
      case 'OUT_FOR_DELIVERY':
        return 0xFFE3F2FD; // Blue (50)
      case 'DELIVERED':
        return 0xFFE8F5E9; // Green (50)
      case 'CANCELLED':
        return 0xFFFFEBEE; // Red (50)
      default:
        return 0xFFF5F5F5; // Grey (50)
    }
  }

  // Get icon for status
  dynamic get statusIcon {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Icons.access_time_rounded;
      case 'CONFIRMED':
        return Icons.assignment_turned_in_rounded;
      case 'PICKED_UP':
        return Icons.local_shipping_rounded;
      case 'PROCESSING':
      case 'IN_PROGRESS':
        return Icons.settings_rounded;
      case 'READY_FOR_DELIVERY':
        return Icons.inventory_2_rounded;
      case 'OUT_FOR_DELIVERY':
        return Icons.delivery_dining_rounded;
      case 'DELIVERED':
        return Icons.check_circle_rounded;
      case 'CANCELLED':
        return Icons.cancel_rounded;
      default:
        return Icons.info_outline;
    }
  }
}
