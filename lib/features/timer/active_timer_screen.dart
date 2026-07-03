import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'state/timer_notifier.dart';
import 'state/timer_state.dart';
import '../../theme/forest_theme.dart';

class ActiveTimerScreen extends ConsumerStatefulWidget {
  const ActiveTimerScreen({super.key});

  @override
  ConsumerState<ActiveTimerScreen> createState() => _ActiveTimerScreenState();
}

class _ActiveTimerScreenState extends ConsumerState<ActiveTimerScreen> {
  bool _hasNavigated = false;

  String formatTime(int seconds) {
    final minutes = (seconds ~/ 60).toString().padLeft(2, '0');
    final secs = (seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$secs';
  }

  String getMotivationalText(SessionType sessionType, int remainingSeconds) {
    if (sessionType == SessionType.focus) {
      if (remainingSeconds > 1200) {
        return 'Stay focused, you\'re doing great!';
      } else if (remainingSeconds > 600) {
        return 'Keep going, almost there!';
      } else if (remainingSeconds > 300) {
        return 'You\'re on fire!';
      } else {
        return 'Final stretch, push through!';
      }
    } else {
      return 'Take a deep breath and relax';
    }
  }

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final notifier = ref.read(timerProvider.notifier);
    final isFocus = timer.sessionType == SessionType.focus;

    // Start timer when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!timer.isRunning && timer.remainingSeconds > 0) {
        notifier.start();
      }
    });

    // Handle timer completion
    ref.listen(timerProvider, (previous, next) {
      if (next.remainingSeconds == 0 && next.isRunning == false && !_hasNavigated) {
        // Timer completed
        _hasNavigated = true;
        Future.delayed(const Duration(seconds: 1), () {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        });
      }
    });

    return Scaffold(
      backgroundColor: ForestTheme.creamBackground,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //const Spacer(),


                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () {
                        showModalBottomSheet(
                          showDragHandle: true,
                          context: context,
                          backgroundColor: ForestTheme.brownLight,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28),
                            ),
                          ),
                          builder: (_) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 0),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        "Enable Compute",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),

                                      const Spacer(),

                                      Switch.adaptive(
                                        value: timer.computeEnabled,
                                        onChanged: (_) {
                                          notifier.toggleCompute();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },

                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: ForestTheme.greenAccent.withOpacity(.12),
                          borderRadius: BorderRadius.circular(999),
                        ),

                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: timer.computeEnabled
                                    ? ForestTheme.greenAccent
                                    : Colors.grey.shade500,
                                shape: BoxShape.circle,
                              ),
                            ),

                            const SizedBox(width: 6),

                            Text(
                              timer.computeEnabled
                                  ? "Computing"
                                  : "Not computing",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: timer.computeEnabled
                                    ? ForestTheme.greenAccent
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),

                      ),
                    ),
                  ),

                const SizedBox(height: 20,),
                // Motivational text
                Text(
                  getMotivationalText(timer.sessionType, timer.remainingSeconds),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: ForestTheme.textBrown,
                  ),
                  textAlign: TextAlign.center,
                ),

                // // Compute status indicator
                // // if (timer.isComputeRunning) ...[
                //   const SizedBox(height: 16),
                //   Container(
                //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                //     decoration: BoxDecoration(
                //       color: ForestTheme.greenAccent.withOpacity(0.0),
                //       borderRadius: BorderRadius.circular(16),
                //       border: Border.all(
                //         color: ForestTheme.brownMedium.withOpacity(0.0),
                //         width: 1,
                //       ),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         SizedBox(
                //           width: 12,
                //           height: 12,
                //           child: CircularProgressIndicator(
                //             strokeWidth: 2,
                //             valueColor: AlwaysStoppedAnimation<Color>(ForestTheme.brownDark),
                //           ),
                //         ),
                //         const SizedBox(width: 8),
                //         Text(
                //           'Contributing to distributed computing',
                //           style: TextStyle(
                //             fontSize: 14,
                //             fontWeight: FontWeight.w500,
                //             color: ForestTheme.brownLight,
                //           ),
                //         ),
                //         const SizedBox(height: 24),
                //         Row(
                //           mainAxisSize: MainAxisSize.min,
                //           children: [
                //             // Icon(
                //             //   Icons.computer,
                //             //   color: ForestTheme.brownMedium,
                //             //   size: 20,
                //             // ),
                //             // const SizedBox(width: 12),
                //             // Text(
                //             //   'Distributed Computing',
                //             //   style: TextStyle(
                //             //     fontSize: 16,
                //             //     fontWeight: FontWeight.w500,
                //             //     color: ForestTheme.textBrown,
                //             //   ),
                //             // ),
                //             // const SizedBox(width: 16),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // // ],
                //
                // // Compute toggle
                //
                //
                const SizedBox(height: 40),

                // Timer circle
                CircularPercentIndicator(
                  radius: 180,
                  lineWidth: 16,
                  animation: true,
                  animateFromLastPercent: true,
                  circularStrokeCap: CircularStrokeCap.round,
                  percent: timer.progress,
                  progressColor: ForestTheme.brownMedium,
                  backgroundColor: ForestTheme.dividerBrown,
                  center: Text(
                    formatTime(timer.remainingSeconds),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: ForestTheme.textBrown,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Session type indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: isFocus
                        ? ForestTheme.brownLight.withOpacity(0.2)
                        : ForestTheme.greenAccent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isFocus ? 'Focus Session' : 'Break Time',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: isFocus ? ForestTheme.brownMedium : ForestTheme.greenAccent,
                        ),
                      ),
                    ],
                  ),
                ),

               const SizedBox(height: 20,),

                // Control buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: timer.isRunning ? notifier.pause : notifier.start,
                      icon: Icon(
                        timer.isRunning ? Icons.pause_circle_filled : Icons.play_circle_filled,
                        size: 64,
                        color: ForestTheme.brownMedium,
                      ),
                    ),
                    const SizedBox(width: 32),
                    IconButton(
                      onPressed: () {
                        notifier.pause();
                        notifier.reset();
                        Navigator.of(context).pop();
                      },
                      icon: Icon(
                        Icons.cancel,
                        size: 64,
                        color: ForestTheme.brownDark,
                      ),
                    ),
                  ],
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
