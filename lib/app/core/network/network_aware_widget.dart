import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_ai_app/app/core/network/network_cubit.dart';

/// A widget that shows different content based on network connectivity
class NetworkAwareWidget extends StatefulWidget {
  final Widget child;
  final Widget? offlineChild;
  final VoidCallback? onRetry;
  final bool showRetryButton;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.offlineChild,
    this.onRetry,
    this.showRetryButton = true,
  });

  @override
  State<NetworkAwareWidget> createState() => _NetworkAwareWidgetState();
}

class _NetworkAwareWidgetState extends State<NetworkAwareWidget> {
  @override
  void initState() {
    super.initState();
    // Initialize network check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NetworkCubit>().checkConnection();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NetworkCubit, NetworkState>(
      builder: (context, state) {
        final isOffline = state is NetworkDisconnected;

        return Stack(
          children: [
            // The main content - always in the tree but behind the offline UI when offline
            IgnorePointer(
              ignoring: isOffline,
              child: Opacity(opacity: isOffline ? 0.0 : 1.0, child: widget.child),
            ),

            // Offline UI - only shown when offline
            if (isOffline) widget.offlineChild ?? _buildOfflineUI(context),
          ],
        );
      },
    );
  }

  Widget _buildOfflineUI(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.signal_wifi_off_rounded, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Please check your internet connection and try again.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              if (widget.showRetryButton) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () {
                    // Safely access the bloc if it exists
                    final networkCubit = context.read<NetworkCubit>();
                    widget.onRetry?.call();
                    networkCubit.checkConnection();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
