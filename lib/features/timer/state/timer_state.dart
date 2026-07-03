enum SessionType {
  focus,
  breakTime,
}

extension SessionTypeExtension on SessionType {
  String get displayName {
    switch (this) {
      case SessionType.focus:
        return 'focus';
      case SessionType.breakTime:
        return 'break';
    }
  }
}

class TimerState {

  final int totalSeconds;
  final int remainingSeconds;

  final bool isRunning;

  final SessionType sessionType;
  
  final bool isComputeRunning;
  
  final bool computeEnabled;

  const TimerState({
    required this.totalSeconds,
    required this.remainingSeconds,
    required this.isRunning,
    required this.sessionType,
    this.isComputeRunning = false,
    this.computeEnabled = true,
  });

  double get progress {
    if (totalSeconds == 0) return 0.0;
    return remainingSeconds / totalSeconds;
  }

  TimerState copyWith({
    int? totalSeconds,
    int? remainingSeconds,
    bool? isRunning,
    SessionType? sessionType,
    bool? isComputeRunning,
    bool? computeEnabled,
  }) {
    return TimerState(
      totalSeconds:
      totalSeconds ?? this.totalSeconds,

      remainingSeconds:
      remainingSeconds ?? this.remainingSeconds,

      isRunning:
      isRunning ?? this.isRunning,

      sessionType:
      sessionType ?? this.sessionType,
      
      isComputeRunning:
      isComputeRunning ?? this.isComputeRunning,
      
      computeEnabled:
      computeEnabled ?? this.computeEnabled,
    );
  }
}