import 'package:flutter/material.dart';

enum ReturnStatus {
  pending,
  scheduled,
  confirmed,
  rejected,
  late,
}

class Return {
  final String? id;
  final String rentalId;
  final TimeOfDay proposedReturnTime;
  final String? note;
  final ReturnStatus status;
  final DateTime createdAt;

  Return({
    this.id,
    required this.rentalId,
    required this.proposedReturnTime,
    this.note,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'rental_id': rentalId,
      'proposed_return_time': _timeToDbString(proposedReturnTime),
      if (note != null && note!.isNotEmpty) 'note': note,
      'status': statusToDbString(status),
      if (createdAt != null) 'created_at': createdAt.toIso8601String(),
    };
  }

  factory Return.fromJson(Map<String, dynamic> json) {
    return Return(
      id: json['id'],
      rentalId: json['rental_id'],
      proposedReturnTime: _timeFromDbString(json['proposed_return_time']),
      note: json['note'],
      status: statusFromDbString(json['status']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  static String _timeToDbString(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}:00';
  }

  static TimeOfDay _timeFromDbString(String timeString) {
    final parts = timeString.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );
  }

  static String statusToDbString(ReturnStatus status) {
    switch (status) {
      case ReturnStatus.pending:
        return 'pending';
      case ReturnStatus.scheduled:
        return 'scheduled';
      case ReturnStatus.confirmed:
        return 'confirmed';
      case ReturnStatus.rejected:
        return 'rejected';
      case ReturnStatus.late:
        return 'late';
    }
  }

  static ReturnStatus statusFromDbString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return ReturnStatus.pending;
      case 'scheduled':
        return ReturnStatus.scheduled;
      case 'confirmed':
        return ReturnStatus.confirmed;
      case 'rejected':
        return ReturnStatus.rejected;
      case 'late':
        return ReturnStatus.late;
      default:
        return ReturnStatus.pending;
    }
  }
}

