import 'package:flutter/material.dart';

import 'package:hive_flutter/hive_flutter.dart';

import '../sessions/models/session_model.dart';
import '../../theme/forest_theme.dart';

class SessionsScreen extends StatefulWidget {

  const SessionsScreen({super.key});

  @override
  State<SessionsScreen> createState() => _SessionsScreenState();
}

class _SessionsScreenState extends State<SessionsScreen> {
  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int minutes) {
    if (minutes < 60) return '$minutes min';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '$hours h $mins min' : '$hours h';
  }

  Future<void> _clearAllSessions() async {
    final box = Hive.box<SessionModel>('sessionsBox');
    
    if (!context.mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear All Sessions'),
        content: const Text('Are you sure you want to delete all sessions? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await box.clear();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All sessions cleared'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _deleteSession(int index, int boxIndex) async {
    final box = Hive.box<SessionModel>('sessionsBox');
    
    if (!mounted) return;
    
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Session'),
        content: const Text('Are you sure you want to delete this session?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await box.deleteAt(boxIndex);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session deleted'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  Future<void> _renameSession(int index, int boxIndex) async {
    final box = Hive.box<SessionModel>('sessionsBox');
    final session = box.getAt(boxIndex);
    
    if (session == null || !mounted) return;
    
    final controller = TextEditingController(text: session.name);
    
    if (!mounted) return;
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Session'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter session name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != null && mounted) {
      final updatedSession = session.copyWith(name: result);
      await box.putAt(boxIndex, updatedSession);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Session renamed'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _showSessionDetails(SessionModel session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(session.name.isEmpty ? 'Session Details' : session.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Type', session.type),
            const SizedBox(height: 8),
            _buildDetailRow('Duration', _formatDuration(session.durationMinutes)),
            const SizedBox(height: 8),
            _buildDetailRow('Completed', session.completed ? 'Yes' : 'No'),
            const SizedBox(height: 8),
            _buildDetailRow('Date', _formatDateTime(session.startTime)),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            '$label:',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: ForestTheme.textBrown,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: ForestTheme.textLightBrown,
            ),
          ),
        ),
      ],
    );
  }

  void _showSessionOptions(int index, int boxIndex, SessionModel session) {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('View Details'),
              onTap: () {
                Navigator.of(context).pop();
                _showSessionDetails(session);
              },
            ),
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Navigator.of(context).pop();
                _renameSession(index, boxIndex);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.of(context).pop();
                _deleteSession(index, boxIndex);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    final box =
    Hive.box<SessionModel>(
      'sessionsBox',
    );

    return Scaffold(

      appBar: AppBar(
        title: const Text('Sessions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Clear all sessions',
            onPressed: _clearAllSessions,
          ),
        ],
      ),

      body: ValueListenableBuilder(

        valueListenable: box.listenable(),

        builder: (context, Box<SessionModel> box, _) {

          final sessions =
          box.values.toList().reversed.toList();

          if (sessions.isEmpty) {

            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 64,
                    color: ForestTheme.brownLight,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No sessions yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: ForestTheme.textLightBrown,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(

            padding: const EdgeInsets.all(16),
            
            itemCount: sessions.length,

            itemBuilder: (context, index) {
              final session = sessions[index];
              // Calculate the actual box index (reversed list)
              final boxIndex = box.length - 1 - index;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Dismissible(
                  key: ValueKey('session_${session.startTime.millisecondsSinceEpoch}'),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _deleteSession(index, boxIndex);
                  },
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.delete,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  child: Card(
                    child: InkWell(
                      onTap: () => _showSessionDetails(session),
                      onLongPress: () => _showSessionOptions(index, boxIndex, session),
                      child: ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: session.type == 'focus'
                                ? ForestTheme.brownLight.withOpacity(0.2)
                                : ForestTheme.greenAccent.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            session.type == 'focus'
                                ? Icons.timer
                                : Icons.free_breakfast,
                            color: session.type == 'focus'
                                ? ForestTheme.brownMedium
                                : ForestTheme.greenAccent,
                          ),
                        ),

                        title: Text(
                          session.name.isEmpty 
                              ? '${session.durationMinutes} min ${session.type}'
                              : session.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        subtitle: Text(
                          '${_formatDateTime(session.startTime)} • ${_formatDuration(session.durationMinutes)}',
                          style: TextStyle(
                            color: ForestTheme.textLightBrown,
                          ),
                        ),

                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showSessionOptions(index, boxIndex, session),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}