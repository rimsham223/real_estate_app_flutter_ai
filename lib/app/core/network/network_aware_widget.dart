import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nawy_ai_app/app/core/network/network_cubit.dart';

/// Shows app content at all times and overlays a small offline banner when the
/// device is disconnected. Feature pages can still use local/cache fallbacks.
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
            widget.child,
            if (isOffline)
              Positioned(
                left: 12,
                right: 12,
                top: MediaQuery.of(context).padding.top + 8,
                child: widget.offlineChild ?? _buildOfflineBanner(context),
              ),
          ],
        );
      },
    );
  }

  Widget _buildOfflineBanner(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            Icon(Icons.signal_wifi_off_rounded, color: theme.colorScheme.onErrorContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Offline mode: showing saved local content.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onErrorContainer),
              ),
            ),
            if (widget.showRetryButton)
              TextButton(
                onPressed: () {
                  widget.onRetry?.call();
                  context.read<NetworkCubit>().checkConnection();
                },
                child: const Text('Retry'),
              ),
          ],
        ),
      ),
    );
  }
}
