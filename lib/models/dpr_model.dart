import 'package:json_annotation/json_annotation.dart';

part 'dpr_model.g.dart';

/// Model for labor category
@JsonSerializable()
class LaborEntry {
  /// Category of labor (e.g., 'Skilled', 'Semi-Skilled', 'Unskilled')
  final String category;

  /// Number of workers in this category
  final int count;

  /// Hours worked
  final double hoursWorked;

  LaborEntry({
    required this.category,
    required this.count,
    required this.hoursWorked,
  });

  factory LaborEntry.fromJson(Map<String, dynamic> json) =>
      _$LaborEntryFromJson(json);

  Map<String, dynamic> toJson() => _$LaborEntryToJson(this);
}

/// Model for material usage
@JsonSerializable()
class MaterialEntry {
  /// Material name (e.g., 'Cement', 'Steel', 'Bricks')
  final String name;

  /// Quantity used
  final double quantity;

  /// Unit of measurement (e.g., 'bags', 'tons', 'pieces')
  final String unit;

  /// Cost per unit
  final double costPerUnit;

  /// Total cost
  double get totalCost => quantity * costPerUnit;

  MaterialEntry({
    required this.name,
    required this.quantity,
    required this.unit,
    required this.costPerUnit,
  });

  factory MaterialEntry.fromJson(Map<String, dynamic> json) =>
      _$MaterialEntryFromJson(json);

  Map<String, dynamic> toJson() => _$MaterialEntryToJson(this);
}

/// Daily Progress Report (DPR) model
@JsonSerializable()
class DailyProgressReport {
  /// Unique identifier
  final String id;

  /// Associated task ID
  final String taskId;

  /// Associated site location
  final String siteLocation;

  /// Employee who created the report
  final String employeeId;

  /// Date of the report (should be date only, no time)
  final DateTime reportDate;

  /// Weather conditions
  final String? weatherCondition;

  /// List of labor entries
  final List<LaborEntry> laborEntries;

  /// Total labor hours for the day
  double get totalLaborHours {
    return laborEntries.fold(0, (sum, entry) => sum + entry.hoursWorked);
  }

  /// Total workers on site
  int get totalWorkers {
    return laborEntries.fold(0, (sum, entry) => sum + entry.count);
  }

  /// List of material entries
  final List<MaterialEntry> materialEntries;

  /// Total material cost for the day
  double get totalMaterialCost {
    return materialEntries.fold(0, (sum, entry) => sum + entry.totalCost);
  }

  /// Work description and progress notes
  final String workDescription;

  /// Percentage of work completed for the day
  final int progressPercentage;

  /// Safety incidents reported
  final String? safetyIncidents;

  /// Equipment used
  final List<String>? equipmentUsed;

  /// Photos/attachments
  final List<String>? photoUrls;

  /// Remarks and observations
  final String? remarks;

  /// Timestamp when report was created
  final DateTime createdAt;

  /// Timestamp when report was last updated
  final DateTime updatedAt;

  /// Whether report is approved by supervisor/admin
  final bool isApproved;

  /// Approved by (user ID)
  final String? approvedBy;

  /// Approval timestamp
  final DateTime? approvedAt;

  DailyProgressReport({
    required this.id,
    required this.taskId,
    required this.siteLocation,
    required this.employeeId,
    required this.reportDate,
    this.weatherCondition,
    this.laborEntries = const [],
    this.materialEntries = const [],
    required this.workDescription,
    required this.progressPercentage,
    this.safetyIncidents,
    this.equipmentUsed,
    this.photoUrls,
    this.remarks,
    required this.createdAt,
    required this.updatedAt,
    this.isApproved = false,
    this.approvedBy,
    this.approvedAt,
  });

  /// Copy with method for immutability
  DailyProgressReport copyWith({
    String? id,
    String? taskId,
    String? siteLocation,
    String? employeeId,
    DateTime? reportDate,
    String? weatherCondition,
    List<LaborEntry>? laborEntries,
    List<MaterialEntry>? materialEntries,
    String? workDescription,
    int? progressPercentage,
    String? safetyIncidents,
    List<String>? equipmentUsed,
    List<String>? photoUrls,
    String? remarks,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isApproved,
    String? approvedBy,
    DateTime? approvedAt,
  }) {
    return DailyProgressReport(
      id: id ?? this.id,
      taskId: taskId ?? this.taskId,
      siteLocation: siteLocation ?? this.siteLocation,
      employeeId: employeeId ?? this.employeeId,
      reportDate: reportDate ?? this.reportDate,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      laborEntries: laborEntries ?? this.laborEntries,
      materialEntries: materialEntries ?? this.materialEntries,
      workDescription: workDescription ?? this.workDescription,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      safetyIncidents: safetyIncidents ?? this.safetyIncidents,
      equipmentUsed: equipmentUsed ?? this.equipmentUsed,
      photoUrls: photoUrls ?? this.photoUrls,
      remarks: remarks ?? this.remarks,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isApproved: isApproved ?? this.isApproved,
      approvedBy: approvedBy ?? this.approvedBy,
      approvedAt: approvedAt ?? this.approvedAt,
    );
  }

  factory DailyProgressReport.fromJson(Map<String, dynamic> json) =>
      _$DailyProgressReportFromJson(json);

  Map<String, dynamic> toJson() => _$DailyProgressReportToJson(this);

  @override
  String toString() => 'DPR(id: $id, taskId: $taskId, date: $reportDate)';
}
