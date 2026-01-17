import 'package:flutter/material.dart';

/// 错误类型枚举
enum ErrorType {
  network,
  permission,
  data,
  file,
  unknown,
}

/// 错误处理服务 - 提供统一的错误处理UI
class ErrorHandler {
  /// 显示错误对话框
  static Future<void> showErrorDialog({
    required BuildContext context,
    required String title,
    required String message,
    required ErrorType errorType,
    VoidCallback? onRetry,
    String retryText = '重试',
  }) async {
    final icon = _getErrorIcon(errorType);
    final color = _getErrorColor(errorType);

    return showDialog(
      context: context,
      barrierDismissible: onRetry != null ? false : true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          if (onRetry != null)
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                onRetry();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
              ),
              child: Text(retryText),
            )
          else
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('知道了'),
            ),
        ],
      ),
    );
  }

  /// 显示SnackBar错误提示
  static void showSnackBar({
    required BuildContext context,
    required String message,
    ErrorType errorType = ErrorType.unknown,
    VoidCallback? onRetry,
    String? actionLabel,
  }) {
    final color = _getErrorColor(errorType);
    final icon = _getErrorIcon(errorType);

    final snackBar = SnackBar(
      content: Row(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
          if (onRetry != null && actionLabel != null)
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                onRetry();
              },
              child: Text(
                actionLabel,
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      action: onRetry != null && actionLabel == null
          ? SnackBarAction(
              label: '重试',
              textColor: Colors.white,
              onPressed: onRetry,
            )
          : null,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// 显示加载错误状态
  static Widget buildErrorState({
    required String message,
    required VoidCallback onRetry,
    ErrorType errorType = ErrorType.unknown,
  }) {
    final color = _getErrorColor(errorType);
    final icon = _getErrorIcon(errorType);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: color),
            ),
            const SizedBox(height: 24),
            Text(
              '出错了',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('重新加载'),
              style: ElevatedButton.styleFrom(
                backgroundColor: color,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示空状态（带操作）
  static Widget buildEmptyState({
    required String title,
    required String description,
    required IconData icon,
    VoidCallback? onAction,
    String? actionLabel,
    Color iconColor = Colors.blue,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 40, color: iconColor),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 获取错误图标
  static IconData _getErrorIcon(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Icons.wifi_off;
      case ErrorType.permission:
        return Icons.no_accounts;
      case ErrorType.data:
        return Icons.error_outline;
      case ErrorType.file:
        return Icons.insert_drive_file;
      case ErrorType.unknown:
        return Icons.warning;
    }
  }

  /// 获取错误颜色
  static Color _getErrorColor(ErrorType type) {
    switch (type) {
      case ErrorType.network:
        return Colors.orange;
      case ErrorType.permission:
        return Colors.red;
      case ErrorType.data:
        return Colors.blue;
      case ErrorType.file:
        return Colors.purple;
      case ErrorType.unknown:
        return Colors.grey;
    }
  }
}

/// 错误上下文mixin - 用于在StatefulWidget中统一处理错误
mixin ErrorHandlerMixin<T extends StatefulWidget> on State<T> {
  /// 显示错误
  void showError(String message, {VoidCallback? onRetry}) {
    ErrorHandler.showSnackBar(
      context: context,
      message: message,
      onRetry: onRetry,
    );
  }

  /// 显示网络错误
  void showNetworkError({VoidCallback? onRetry}) {
    ErrorHandler.showSnackBar(
      context: context,
      message: '网络连接失败，请检查网络设置',
      errorType: ErrorType.network,
      onRetry: onRetry,
    );
  }

  /// 显示权限错误
  void showPermissionError(String permission, {VoidCallback? onOpenSettings}) {
    ErrorHandler.showErrorDialog(
      context: context,
      title: '权限被拒绝',
      message: '$permission 权限被拒绝，请前往设置中开启权限',
      errorType: ErrorType.permission,
      onRetry: onOpenSettings,
      retryText: '前往设置',
    );
  }
}

/// 异步操作包装器 - 自动处理加载状态和错误
class AsyncActionWrapper extends StatefulWidget {
  final Widget Function(bool isLoading, String? error, VoidCallback retry) builder;
  final Future<void> Function() action;
  final Widget? loadingWidget;
  final Widget Function(String error, VoidCallback retry)? errorBuilder;

  const AsyncActionWrapper({
    super.key,
    required this.builder,
    required this.action,
    this.loadingWidget,
    this.errorBuilder,
  });

  @override
  State<AsyncActionWrapper> createState() => _AsyncActionWrapperState();
}

class _AsyncActionWrapperState extends State<AsyncActionWrapper> {
  bool _isLoading = false;
  String? _error;

  Future<void> _execute() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.action();
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(_isLoading, _error, _execute);
  }
}
