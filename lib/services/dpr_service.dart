import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/index.dart';

/// Firebase Firestore service for DPR operations
class DprService {
  static const String dprCollection = 'dpr'; // Daily Progress Reports

  late FirebaseFirestore _firestore;

  DprService() {
    try {
      // Always initialize instance
      _firestore = FirebaseFirestore.instance;
      debugPrint('✅ Firestore instance created for DprService');
    } catch (e) {
      debugPrint('⚠️ Firestore not available in DprService: $e');
    }
  }

  /// Create a new DPR
  Future<String> createDpr(DailyProgressReport dpr) async {
    try {
      final docRef = await _firestore
          .collection(dprCollection)
          .add(dpr.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create DPR: $e');
    }
  }

  /// Get DPR by ID
  Future<DailyProgressReport?> getDprById(String dprId) async {
    try {
      final doc = await _firestore.collection(dprCollection).doc(dprId).get();

      if (!doc.exists) return null;

      return DailyProgressReport.fromJson({
        'id': doc.id,
        ...doc.data() as Map<String, dynamic>,
      });
    } catch (e) {
      throw Exception('Failed to fetch DPR: $e');
    }
  }

  /// Get DPRs for a task
  Stream<List<DailyProgressReport>> getDprsForTask(String taskId) {
    return _firestore
        .collection(dprCollection)
        .where('taskId', isEqualTo: taskId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    DailyProgressReport.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();
        });
  }

  /// Get DPRs for an employee
  Stream<List<DailyProgressReport>> getDprsForEmployee(String employeeId) {
    return _firestore
        .collection(dprCollection)
        .where('employeeId', isEqualTo: employeeId)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    DailyProgressReport.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();
        });
  }

  /// Get DPRs for a site location
  Stream<List<DailyProgressReport>> getDprsForSite(String siteLocation) {
    return _firestore
        .collection(dprCollection)
        .where('siteLocation', isEqualTo: siteLocation)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    DailyProgressReport.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();
        });
  }

  /// Get DPRs for a date range
  Future<List<DailyProgressReport>> getDprsForDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? employeeId,
    String? taskId,
  }) async {
    try {
      var query = _firestore
          .collection(dprCollection)
          .where('reportDate', isGreaterThanOrEqualTo: startDate)
          .where('reportDate', isLessThanOrEqualTo: endDate);

      if (employeeId != null) {
        query = query.where('employeeId', isEqualTo: employeeId);
      }

      if (taskId != null) {
        query = query.where('taskId', isEqualTo: taskId);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map(
            (doc) =>
                DailyProgressReport.fromJson({'id': doc.id, ...doc.data()}),
          )
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch DPRs for date range: $e');
    }
  }

  /// Update DPR
  Future<void> updateDpr(String dprId, DailyProgressReport dpr) async {
    try {
      await _firestore
          .collection(dprCollection)
          .doc(dprId)
          .update(dpr.toJson());
    } catch (e) {
      throw Exception('Failed to update DPR: $e');
    }
  }

  /// Approve DPR
  Future<void> approveDpr(String dprId, String approvedBy) async {
    try {
      await _firestore.collection(dprCollection).doc(dprId).update({
        'isApproved': true,
        'approvedBy': approvedBy,
        'approvedAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
    } catch (e) {
      throw Exception('Failed to approve DPR: $e');
    }
  }

  /// Delete DPR
  Future<void> deleteDpr(String dprId) async {
    try {
      await _firestore.collection(dprCollection).doc(dprId).delete();
    } catch (e) {
      throw Exception('Failed to delete DPR: $e');
    }
  }

  /// Get pending DPRs for approval
  Stream<List<DailyProgressReport>> getPendingDprsForApproval() {
    return _firestore
        .collection(dprCollection)
        .where('isApproved', isEqualTo: false)
        .orderBy('reportDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map(
                (doc) =>
                    DailyProgressReport.fromJson({'id': doc.id, ...doc.data()}),
              )
              .toList();
        });
  }

  /// Get statistics for a task
  Future<Map<String, dynamic>> getTaskStatistics(String taskId) async {
    try {
      final dprList = await _firestore
          .collection(dprCollection)
          .where('taskId', isEqualTo: taskId)
          .get();

      double totalMaterialCost = 0;
      double totalLaborHours = 0;
      int totalWorkers = 0;
      int reportCount = 0;

      for (var doc in dprList.docs) {
        final dpr = DailyProgressReport.fromJson({'id': doc.id, ...doc.data()});

        totalMaterialCost += dpr.totalMaterialCost;
        totalLaborHours += dpr.totalLaborHours;
        totalWorkers += dpr.totalWorkers;
        reportCount++;
      }

      return {
        'totalMaterialCost': totalMaterialCost,
        'totalLaborHours': totalLaborHours,
        'averageDailyWorkers': reportCount > 0 ? totalWorkers / reportCount : 0,
        'reportCount': reportCount,
      };
    } catch (e) {
      throw Exception('Failed to get task statistics: $e');
    }
  }
}
