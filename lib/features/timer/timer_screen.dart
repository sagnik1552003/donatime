import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'state/timer_notifier.dart';
import 'state/timer_state.dart';
import '../../theme/forest_theme.dart';
import '../../widgets/circular_time_slider.dart';
import 'active_timer_screen.dart';

class TimerScreen extends ConsumerStatefulWidget {
  const TimerScreen({super.key});

  @override
  ConsumerState<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends ConsumerState<TimerScreen> {
  int _selectedMinutes = 25;

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final isFocus = timer.sessionType == SessionType.focus;

    return Scaffold(
      body: SafeArea(

        child: Padding(

          padding:
          const EdgeInsets.all(24),

          child: Column(

            children: [

              const SizedBox(height: 20),

              Text(
                isFocus
                    ? 'Focus Session'
                    : 'Break Session',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: ForestTheme.textBrown,
                ),
              ),

              const SizedBox(height: 16),

              // Session type toggle
              GestureDetector(
                onTap: () {
                  notifier.toggleSessionType();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: ForestTheme.brownLight.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: ForestTheme.brownLight,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isFocus ? Icons.timer : Icons.free_breakfast,
                        color: ForestTheme.brownMedium,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Switch to ${isFocus ? "Break" : "Focus"}',
                        style: TextStyle(
                          color: ForestTheme.brownMedium,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Circular time slider
              SizedBox(
                child: CircularTimeSlider(
                  initialMinutes: _selectedMinutes,
                  onTimeChanged: (minutes) {
                    setState(() {
                      _selectedMinutes = minutes;
                    });
                    notifier.setDuration(minutes);
                  },
                ),
              ),

              const SizedBox(height: 40),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () {
                      notifier.reset();
                      notifier.setDuration(_selectedMinutes);
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const ActiveTimerScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.play_arrow),
                    label: const Text('Start'),
                  ),
                ],
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}