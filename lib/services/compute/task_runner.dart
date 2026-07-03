import 'dart:math';

import 'models/task.dart';

class TaskRunner {

  static Future<
      ({
      dynamic result,
      double durationMs,
      })
  > run(
      ComputeTask task,
      ) async {

    final sw =
    Stopwatch()
      ..start();

    dynamic result;

    switch (task.type) {

      case 'prime_sieve':

        result =
            _primes(
              task.payload[
              'range_start'],
              task.payload[
              'range_end'],
            );

        break;

      case 'matrix_multiply':

        result =
            _multiply(
              task.payload[
              'matrix_a'],
              task.payload[
              'matrix_b'],
            );

        break;
    }

    sw.stop();

    return (
    result: result,
    durationMs:
    sw.elapsedMilliseconds
        .toDouble()
    );
  }

  static List<int> _primes(
      int start,
      int end,
      ) {

    final out = <int>[];

    for (
    int i = start;
    i <= end;
    i++
    ) {

      bool prime = true;

      for (
      int j = 2;
      j <= sqrt(i);
      j++
      ) {
        if (i % j == 0) {
          prime = false;
          break;
        }
      }

      if (prime) {
        out.add(i);
      }
    }

    return out;
  }

  static List<List<double>>
  _multiply(
      List a,
      List b,
      ) {

    final n =
        a.length;

    final result =
    List.generate(
      n,
          (_) =>
          List.filled(
            n,
            0.0,
          ),
    );

    for (
    int i = 0;
    i < n;
    i++
    ) {
      for (
      int j = 0;
      j < n;
      j++
      ) {
        for (
        int k = 0;
        k < n;
        k++
        ) {
          result[i][j] +=
              a[i][k] *
                  b[k][j];
        }
      }
    }

    return result;
  }
}