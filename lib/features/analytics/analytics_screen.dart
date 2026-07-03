import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import '../sessions/models/session_model.dart';
import '../../theme/forest_theme.dart';

class AnalyticsScreen extends StatelessWidget {

  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {

    final box =
    Hive.box<SessionModel>(
      'sessionsBox',
    );

    return Scaffold(

      appBar: AppBar(
        title: const Text('Analytics'),
      ),

      body: ValueListenableBuilder(
        valueListenable: box.listenable(),
        builder: (context, Box<SessionModel> box, _) {
          final sessions = box.values.toList();

          final totalSessions = sessions.length;

          final totalMinutes = sessions.fold<int>(
            0,
            (sum, s) => sum + s.durationMinutes,
          );

          final focusSessions = sessions.where(
            (s) => s.type == 'focus',
          ).length;

          final breakSessions = sessions.where(
            (s) => s.type == 'break',
          ).length;

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ForestTheme.brownLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.timer,
                        color: ForestTheme.brownMedium,
                      ),
                    ),
                    title: const Text('Total Sessions'),
                    trailing: Text(
                      '$totalSessions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ForestTheme.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.access_time,
                        color: ForestTheme.greenAccent,
                      ),
                    ),
                    title: const Text('Total Focus Time'),
                    trailing: Text(
                      '$totalMinutes min',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ForestTheme.brownDark.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.psychology,
                        color: ForestTheme.brownDark,
                      ),
                    ),
                    title: const Text('Focus Sessions'),
                    trailing: Text(
                      '$focusSessions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                Card(
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: ForestTheme.greenAccent.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.free_breakfast,
                        color: ForestTheme.greenAccent,
                      ),
                    ),
                    title: const Text('Break Sessions'),
                    trailing: Text(
                      '$breakSessions',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}