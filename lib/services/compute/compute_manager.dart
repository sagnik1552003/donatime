import 'compute_service.dart';
import 'task_runner.dart';

class ComputeManager {

  final ComputeService service;

  bool running = false;

  ComputeManager(
      this.service,
      );

  Future<void>
  startComputeLoop() async {

    if (running) return;

    running = true;

    while (running) {

      try {

        final task =
        await service.claimTask();

        if (task == null) {

          await Future.delayed(
            const Duration(
              seconds: 10,
            ),
          );

          continue;
        }

        final output =
        await TaskRunner.run(
          task,
        );

        await service.submitResult(
          taskId: task.id,

          result:
          output.result,

          success: true,

          durationMs:
          output.durationMs,
        );

      } catch (_) {

        await Future.delayed(
          const Duration(
            seconds: 5,
          ),
        );
      }
    }
  }

  void stop() {
    running = false;
  }
}