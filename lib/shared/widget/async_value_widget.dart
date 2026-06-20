import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AsyncValueWidget<T> extends StatelessWidget {
  final AsyncValue<T> value;
  final Widget Function(T data) data;
  final Widget Function(Object error, StackTrace stackTrace)? error;
  final Widget Function()? loading;
  final String? errorMessage;
  final bool useLinearProgress;

  const AsyncValueWidget({
    super.key,
    required this.value,
    required this.data,
    this.error,
    this.loading,
    this.errorMessage,
    this.useLinearProgress = false,
  });

  @override
  Widget build(BuildContext context) {
    return value.when(
      data: data,
      error: error ??
          (err, stack) {
            final message = errorMessage != null ? '$errorMessage: $err' : 'Error: $err';
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  message,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          },
      loading: loading ??
          () => Center(
                child: useLinearProgress
                    ? const LinearProgressIndicator()
                    : const CircularProgressIndicator(),
              ),
    );
  }
}
