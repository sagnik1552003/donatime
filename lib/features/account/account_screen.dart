import 'package:flutter/material.dart';

import '../../services/compute/compute_service.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Account',
        ),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            try {
              final service = ComputeService(
                deviceId: 'test_device',
                baseUrl: 'http://10.0.2.2:8000',
              );

              final stats = await service.stats();

              debugPrint(
                stats.toString(),
              );

              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Connected ✓',
                    ),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Failed: $e',
                    ),
                  ),
                );
              }
            }
          },
          child: const Text(
            'Test Backend',
          ),
        ),
      ),
    );
  }
}
