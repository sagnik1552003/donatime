import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'timer_state.dart';
import 'package:hive/hive.dart';
import '../../sessions/models/session_model.dart';
import '../../../services/compute/compute_manager.dart';
import '../../../services/compute/compute_service.dart';

class TimerNotifier
    extends StateNotifier<TimerState> {

  TimerNotifier()
      : super(
    const TimerState(
      totalSeconds: 1500,
      remainingSeconds: 1500,
      isRunning: false,
      sessionType: SessionType.focus,
      isComputeRunning: false,
      computeEnabled: true,
    ),
  );

  Timer? _timer;
  bool _isSaving = false;
  ComputeManager? _computeManager;

  void start() {

    if (state.isRunning) return;

    state = state.copyWith(isRunning: true);
    
    // Start compute loop if enabled
    if (state.computeEnabled) {
      _startComputeManager();
    }
    
    _timer = Timer.periodic(
      const Duration(seconds: 1),
          (timer) async {

        if (state.remainingSeconds <= 1) {
          if (!_isSaving) {
            _isSaving = true;
            await saveSession();
            _isSaving = false;
          }
          // Set remaining seconds to 0 before stopping
          state = state.copyWith(
            remainingSeconds: 0,
            isRunning: false,
          );
          stop();
          return;
        }

        state = state.copyWith(
          remainingSeconds:
          state.remainingSeconds - 1,
        );
      },
    );
  }

  void _startComputeManager() {
    if (_computeManager != null && _computeManager!.running) return;
    
    _computeManager = ComputeManager(
      ComputeService(
        deviceId: 'device_${DateTime.now().millisecondsSinceEpoch}',
        baseUrl: 'http://10.0.2.2:8000',
      ),
    );
    
    // Update state to show compute is running
    state = state.copyWith(isComputeRunning: true);
    
    // Start compute loop in background without blocking
    _computeManager!.startComputeLoop().catchError((error) {
      debugPrint('Compute service error: $error');
      state = state.copyWith(isComputeRunning: false);
    });
  }

  void pause() {

    _timer?.cancel();
    _isSaving = false;
    _stopComputeManager();

    state = state.copyWith(
      isRunning: false,
    );
  }

  void stop() {

    _timer?.cancel();
    _isSaving = false;
    _stopComputeManager();
    state = state.copyWith(
      isRunning: false,
    );
  }

  void reset() {

    _timer?.cancel();
    _isSaving = false;
    _stopComputeManager();

    state = state.copyWith(
      remainingSeconds:
      state.totalSeconds,

      isRunning: false,
    );
  }

  void _stopComputeManager() {
    _computeManager?.stop();
    _computeManager = null;
    state = state.copyWith(isComputeRunning: false);
  }

  void setDuration(int minutes) {

    final seconds = minutes * 60;

    state = state.copyWith(
      totalSeconds: seconds,
      remainingSeconds: seconds,
    );
  }

  void toggleSessionType() {

    if (state.sessionType ==
        SessionType.focus) {

      state = state.copyWith(
        sessionType: SessionType.breakTime,
      );

      setDuration(5);

    } else {

      state = state.copyWith(
        sessionType: SessionType.focus,
      );

      setDuration(25);
    }
  }

  void toggleCompute() {
    final newState = !state.computeEnabled;
    state = state.copyWith(computeEnabled: newState);
    
    if (newState && state.isRunning) {
      _startComputeManager();
    } else if (!newState) {
      _stopComputeManager();
    }
  }

  Future<void> saveSession() async {

    final box =
    Hive.box<SessionModel>(
      'sessionsBox',
    );

    await box.add(

      SessionModel(
        startTime: DateTime.now(),

        durationMinutes:
        state.totalSeconds ~/ 60,

        completed: true,

        type:
        state.sessionType.displayName,
        name: '',
      ),
    );
  }

  @override
  void dispose() {

    _timer?.cancel();
    _isSaving = false;
    _stopComputeManager();

    super.dispose();
  }
}

final timerProvider =
StateNotifierProvider<
    TimerNotifier,
    TimerState>(
      (ref) => TimerNotifier(),
);