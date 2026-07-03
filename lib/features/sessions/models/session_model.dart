import 'package:hive/hive.dart';

part 'session_model.g.dart';

@HiveType(typeId: 0)

class SessionModel {

  @HiveField(0)
  final DateTime startTime;

  @HiveField(1)
  final int durationMinutes;

  @HiveField(2)
  final bool completed;

  @HiveField(3)
  final String type;

  @HiveField(4)
  final String name;

  SessionModel({
    required this.startTime,
    required this.durationMinutes,
    required this.completed,
    required this.type,
    this.name = '',
  });

  SessionModel copyWith({
    DateTime? startTime,
    int? durationMinutes,
    bool? completed,
    String? type,
    String? name,
  }) {
    return SessionModel(
      startTime: startTime ?? this.startTime,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      completed: completed ?? this.completed,
      type: type ?? this.type,
      name: name ?? this.name,
    );
  }
}