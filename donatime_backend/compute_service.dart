// lib/services/compute_service.dart
//
// Handles all communication with the StudyCompute FastAPI backend.
// Drop this into your project and call ComputeService() to get started.

import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

// ── Models ────────────────────────────────────────────────────────────────────

class ComputeTask {
  final String id;
  final String type;          // "prime_sieve" | "matrix_multiply"
  final String description;
  final Map<String, dynamic> payload;
  final String status;

  const ComputeTask({
    required this.id,
    required this.type,
    required this.description,
    required this.payload,
    required this.status,
  });

  factory ComputeTask.fromJson(Map<String, dynamic> j) => ComputeTask(
        id: j['id'] as String,
        type: j['type'] as String,
        description: j['description'] as String,
        payload: Map<String, dynamic>.from(j['payload'] as Map),
        status: j['status'] as String,
      );
}

class ServerStats {
  final int totalGenerated;
  final int totalCompleted;
  final int totalFailed;
  final int activeDevices;
  final Map<String, int> taskCounts;

  const ServerStats({
    required this.totalGenerated,
    required this.totalCompleted,
    required this.totalFailed,
    required this.activeDevices,
    required this.taskCounts,
  });

  factory ServerStats.fromJson(Map<String, dynamic> j) => ServerStats(
        totalGenerated: j['total_generated'] as int,
        totalCompleted: j['total_completed'] as int,
        totalFailed: j['total_failed'] as int,
        activeDevices: j['active_devices'] as int,
        taskCounts: Map<String, int>.from(
          (j['task_counts'] as Map).map((k, v) => MapEntry(k as String, v as int)),
        ),
      );
}

// ── Service ───────────────────────────────────────────────────────────────────

class ComputeService {
  ComputeService({String? baseUrl, required this.deviceId})
      : _base = baseUrl ?? 'http://10.0.2.2:8000'; // Android emulator localhost

  final String _base;
  final String deviceId;

  // Claim the next available task from the server.
  Future<ComputeTask?> claimTask() async {
    final res = await http.post(
      Uri.parse('$_base/tasks/claim'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'device_id': deviceId}),
    );
    if (res.statusCode == 404) return null; // no tasks right now
    if (res.statusCode != 200) throw Exception('claim failed: ${res.body}');
    return ComputeTask.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  // Submit a result back to the server.
  Future<void> submitResult({
    required String taskId,
    required dynamic result,
    required bool success,
    String? error,
    double? durationMs,
  }) async {
    final res = await http.post(
      Uri.parse('$_base/tasks/$taskId/submit'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'device_id': deviceId,
        'result': result,
        'success': success,
        if (error != null) 'error': error,
        if (durationMs != null) 'duration_ms': durationMs,
      }),
    );
    if (res.statusCode != 200) throw Exception('submit failed: ${res.body}');
  }

  Future<ServerStats> fetchStats() async {
    final res = await http.get(Uri.parse('$_base/stats'));
    if (res.statusCode != 200) throw Exception('stats failed');
    return ServerStats.fromJson(jsonDecode(res.body) as Map<String, dynamic>);
  }

  Future<List<Map<String, dynamic>>> fetchLeaderboard() async {
    final res = await http.get(Uri.parse('$_base/leaderboard'));
    if (res.statusCode != 200) throw Exception('leaderboard failed');
    return (jsonDecode(res.body) as List).cast<Map<String, dynamic>>();
  }
}

// ── Local task runner ─────────────────────────────────────────────────────────
// Runs the actual computation on-device and returns a result to submit.

class TaskRunner {
  /// Execute [task] and return the result payload.
  static Future<({dynamic result, double durationMs})> run(
      ComputeTask task) async {
    final sw = Stopwatch()..start();

    final result = switch (task.type) {
      'prime_sieve' => _runPrimeSieve(task.payload),
      'matrix_multiply' => _runMatrixMultiply(task.payload),
      _ => throw UnsupportedError('Unknown task type: ${task.type}'),
    };

    sw.stop();
    return (result: result, durationMs: sw.elapsedMilliseconds.toDouble());
  }

  // ── Prime sieve ────────────────────────────────────────────────────────────

  static List<int> _runPrimeSieve(Map<String, dynamic> p) {
    final start = p['range_start'] as int;
    final end = p['range_end'] as int;
    final primes = <int>[];
    for (var n = start; n <= end; n++) {
      if (_isPrime(n)) primes.add(n);
    }
    return primes;
  }

  static bool _isPrime(int n) {
    if (n < 2) return false;
    if (n == 2) return true;
    if (n.isEven) return false;
    final limit = sqrt(n).floor();
    for (var i = 3; i <= limit; i += 2) {
      if (n % i == 0) return false;
    }
    return true;
  }

  // ── Matrix multiply ────────────────────────────────────────────────────────

  static List<List<double>> _runMatrixMultiply(Map<String, dynamic> p) {
    final n = p['n'] as int;
    final a = _parseMatrix(p['matrix_a'], n);
    final b = _parseMatrix(p['matrix_b'], n);
    final c = List.generate(n, (_) => List<double>.filled(n, 0));

    for (var i = 0; i < n; i++) {
      for (var k = 0; k < n; k++) {
        for (var j = 0; j < n; j++) {
          c[i][j] += a[i][k] * b[k][j];
        }
      }
    }
    return c;
  }

  static List<List<double>> _parseMatrix(dynamic raw, int n) {
    return (raw as List)
        .map((row) => (row as List).map((v) => (v as num).toDouble()).toList())
        .toList();
  }
}
