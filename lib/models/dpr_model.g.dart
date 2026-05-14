// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dpr_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LaborEntry _$LaborEntryFromJson(Map<String, dynamic> json) => LaborEntry(
  category: json['category'] as String,
  count: (json['count'] as num).toInt(),
  hoursWorked: (json['hoursWorked'] as num).toDouble(),
);

Map<String, dynamic> _$LaborEntryToJson(LaborEntry instance) =>
    <String, dynamic>{
      'category': instance.category,
      'count': instance.count,
      'hoursWorked': instance.hoursWorked,
    };

MaterialEntry _$MaterialEntryFromJson(Map<String, dynamic> json) =>
    MaterialEntry(
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      costPerUnit: (json['costPerUnit'] as num).toDouble(),
    );

Map<String, dynamic> _$MaterialEntryToJson(MaterialEntry instance) =>
    <String, dynamic>{
      'name': instance.name,
      'quantity': instance.quantity,
      'unit': instance.unit,
      'costPerUnit': instance.costPerUnit,
    };

DailyProgressReport _$DailyProgressReportFromJson(Map<String, dynamic> json) =>
    DailyProgressReport(
      id: json['id'] as String,
      taskId: json['taskId'] as String,
      siteLocation: json['siteLocation'] as String,
      employeeId: json['employeeId'] as String,
      reportDate: DateTime.parse(json['reportDate'] as String),
      weatherCondition: json['weatherCondition'] as String?,
      laborEntries:
          (json['laborEntries'] as List<dynamic>?)
              ?.map((e) => LaborEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      materialEntries:
          (json['materialEntries'] as List<dynamic>?)
              ?.map((e) => MaterialEntry.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      workDescription: json['workDescription'] as String,
      progressPercentage: (json['progressPercentage'] as num).toInt(),
      safetyIncidents: json['safetyIncidents'] as String?,
      equipmentUsed: (json['equipmentUsed'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      photoUrls: (json['photoUrls'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      remarks: json['remarks'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isApproved: json['isApproved'] as bool? ?? false,
      approvedBy: json['approvedBy'] as String?,
      approvedAt: json['approvedAt'] == null
          ? null
          : DateTime.parse(json['approvedAt'] as String),
    );

Map<String, dynamic> _$DailyProgressReportToJson(
  DailyProgressReport instance,
) => <String, dynamic>{
  'id': instance.id,
  'taskId': instance.taskId,
  'siteLocation': instance.siteLocation,
  'employeeId': instance.employeeId,
  'reportDate': instance.reportDate.toIso8601String(),
  'weatherCondition': instance.weatherCondition,
  'laborEntries': instance.laborEntries,
  'materialEntries': instance.materialEntries,
  'workDescription': instance.workDescription,
  'progressPercentage': instance.progressPercentage,
  'safetyIncidents': instance.safetyIncidents,
  'equipmentUsed': instance.equipmentUsed,
  'photoUrls': instance.photoUrls,
  'remarks': instance.remarks,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'isApproved': instance.isApproved,
  'approvedBy': instance.approvedBy,
  'approvedAt': instance.approvedAt?.toIso8601String(),
};
