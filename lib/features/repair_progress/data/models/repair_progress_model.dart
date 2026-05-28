class RepairUpdate {
  final int id;
  final String fromStage;
  final String toStage;
  final String? note;
  final String createdAt;

  RepairUpdate({
    required this.id,
    required this.fromStage,
    required this.toStage,
    this.note,
    required this.createdAt,
  });

  factory RepairUpdate.fromJson(Map<String, dynamic> json) {
    return RepairUpdate(
      id: json['id'] ?? 0,
      fromStage: json['from_stage'] ?? '',
      toStage: json['to_stage'] ?? '',
      note: json['note'],
      createdAt: json['created_at'] ?? '',
    );
  }
}

class RepairProgressModel {
  final int id;
  final int? appointmentId;
  final String stage;
  final String description;
  final String? estimatedCompletion;
  final String? vehicleInfo;
  final String createdAt;
  final List<RepairUpdate> updates;

  RepairProgressModel({
    required this.id,
    this.appointmentId,
    required this.stage,
    required this.description,
    this.estimatedCompletion,
    this.vehicleInfo,
    required this.createdAt,
    this.updates = const [],
  });

  factory RepairProgressModel.fromJson(Map<String, dynamic> json) {
    final updatesList = (json['updates'] as List<dynamic>?)
            ?.map((e) => RepairUpdate.fromJson(e))
            .toList() ??
        [];
    return RepairProgressModel(
      id: json['id'] ?? 0,
      appointmentId: json['appointment_id'],
      stage: json['stage'] ?? 'received',
      description: json['description'] ?? '',
      estimatedCompletion: json['estimated_completion'],
      vehicleInfo: json['vehicle_info'],
      createdAt: json['created_at'] ?? '',
      updates: updatesList,
    );
  }

  static const List<String> stages = [
    'received',
    'diagnosing',
    'waiting_parts',
    'in_progress',
    'quality_check',
    'ready_for_pickup',
    'completed',
  ];

  int get stageIndex => stages.indexOf(stage);
  double get progress => stages.isEmpty ? 0 : (stageIndex + 1) / stages.length;
}
