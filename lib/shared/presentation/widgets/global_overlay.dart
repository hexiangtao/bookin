import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bookin/shared/providers/app_provider.dart';

class GlobalOverlay extends StatelessWidget {
  final Widget child;

  const GlobalOverlay({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Consumer<AppProvider>(
          builder: (context, appProvider, _) {
            if (appProvider.isAppLoading) {
              return Container(
                color: Colors.black.withOpacity(0.5),
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              );
            } else if (appProvider.globalMessage != null) {
              // Display a temporary message (e.g., SnackBar or Toast)
              // For a more persistent error, you might use a dialog.
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(appProvider.globalMessage!),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                }
                appProvider.setGlobalMessage(null); // Clear message after showing
              });
              return const SizedBox.shrink(); // Don't show anything on top
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
}