import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../constants/app_styles.dart';
import 'app_button.dart';

/// 加载状态组件
/// 统一应用中的加载状态显示
class AppLoadingWidget extends StatelessWidget {
  const AppLoadingWidget({
    super.key,
    this.message,
    this.size = AppLoadingSize.medium,
  });

  final String? message;
  final AppLoadingSize size;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: _getSize(),
            height: _getSize(),
            child: CircularProgressIndicator(
              strokeWidth: _getStrokeWidth(),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          if (message != null) ...[
            SizedBox(height: _getSpacing()),
            Text(
              message!,
              style: _getTextStyle(),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  double _getSize() {
    switch (size) {
      case AppLoadingSize.small:
        return 24;
      case AppLoadingSize.medium:
        return 36;
      case AppLoadingSize.large:
        return 48;
    }
  }

  double _getStrokeWidth() {
    switch (size) {
      case AppLoadingSize.small:
        return 2;
      case AppLoadingSize.medium:
        return 3;
      case AppLoadingSize.large:
        return 4;
    }
  }

  double _getSpacing() {
    switch (size) {
      case AppLoadingSize.small:
        return 8;
      case AppLoadingSize.medium:
        return 12;
      case AppLoadingSize.large:
        return 16;
    }
  }

  TextStyle _getTextStyle() {
    switch (size) {
      case AppLoadingSize.small:
        return AppStyles.caption;
      case AppLoadingSize.medium:
        return AppStyles.bodySmall;
      case AppLoadingSize.large:
        return AppStyles.bodyMedium;
    }
  }
}

/// 加载尺寸枚举
enum AppLoadingSize {
  small,
  medium,
  large,
}

/// 错误状态组件
/// 统一应用中的错误状态显示
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    super.key,
    required this.message,
    this.onRetry,
    this.icon,
    this.retryText = '重试',
  });

  final String message;
  final VoidCallback? onRetry;
  final IconData? icon;
  final String retryText;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.error_outline,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: retryText,
                onPressed: onRetry,
                type: AppButtonType.outline,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 空状态组件
/// 统一应用中的空状态显示
class AppEmptyWidget extends StatelessWidget {
  const AppEmptyWidget({
    super.key,
    required this.message,
    this.icon,
    this.actionText,
    this.onAction,
  });

  final String message;
  final IconData? icon;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon ?? Icons.inbox_outlined,
              size: 64,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: AppStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (actionText != null && onAction != null) ...[
              const SizedBox(height: 24),
              AppButton(
                text: actionText!,
                onPressed: onAction,
                type: AppButtonType.primary,
                size: AppButtonSize.medium,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// 网络错误组件
/// 专门用于网络错误的显示
class AppNetworkErrorWidget extends StatelessWidget {
  const AppNetworkErrorWidget({
    super.key,
    this.onRetry,
  });

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(
      message: '网络连接失败\n请检查网络设置后重试',
      icon: Icons.wifi_off,
      onRetry: onRetry,
      retryText: '重新加载',
    );
  }
}

/// 状态构建器组件
/// 根据不同状态显示不同的UI
class AppStateBuilder<T> extends StatelessWidget {
  const AppStateBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
  });

  final AppState<T> state;
  final Widget Function(BuildContext context, T data) builder;
  final Widget Function(BuildContext context)? loadingBuilder;
  final Widget Function(BuildContext context, String error)? errorBuilder;
  final Widget Function(BuildContext context)? emptyBuilder;

  @override
  Widget build(BuildContext context) {
    return state.when(
      loading: () => loadingBuilder?.call(context) ?? 
          const AppLoadingWidget(message: '加载中...'),
      error: (error) => errorBuilder?.call(context, error) ?? 
          AppErrorWidget(message: error),
      empty: () => emptyBuilder?.call(context) ?? 
          const AppEmptyWidget(message: '暂无数据'),
      data: (data) => builder(context, data),
    );
  }
}

/// 应用状态类
/// 统一管理加载、错误、空数据、成功等状态
class AppState<T> {
  const AppState._();
  const AppState();

  const factory AppState.loading() = _Loading<T>;
  const factory AppState.error(String message) = _Error<T>;
  const factory AppState.empty() = _Empty<T>;
  const factory AppState.data(T data) = _Data<T>;

  R when<R>({
    required R Function() loading,
    required R Function(String error) error,
    required R Function() empty,
    required R Function(T data) data,
  }) {
    if (this is _Loading<T>) {
      return loading();
    } else if (this is _Error<T>) {
      return error((this as _Error<T>).message);
    } else if (this is _Empty<T>) {
      return empty();
    } else if (this is _Data<T>) {
      return data((this as _Data<T>).value);
    }
    throw Exception('Unknown state: $this');
  }

  bool get isLoading => this is _Loading<T>;
  bool get isError => this is _Error<T>;
  bool get isEmpty => this is _Empty<T>;
  bool get hasData => this is _Data<T>;

  T? get dataOrNull => this is _Data<T> ? (this as _Data<T>).value : null;
  String? get errorOrNull => this is _Error<T> ? (this as _Error<T>).message : null;
}

class _Loading<T> extends AppState<T> {
  const _Loading();
}

class _Error<T> extends AppState<T> {
  const _Error(this.message);
  final String message;
}

class _Empty<T> extends AppState<T> {
  const _Empty();
}

class _Data<T> extends AppState<T> {
  const _Data(this.value);
  final T value;
}