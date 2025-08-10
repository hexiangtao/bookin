import 'package:flutter/material.dart';

/// 应用状态枚举
enum AppStateType {
  loading,
  data,
  error,
  empty,
}

/// 通用应用状态类
class AppState<T> {
  final AppStateType type;
  final T? data;
  final String? errorMessage;

  const AppState._(
    this.type, {
    this.data,
    this.errorMessage,
  });

  /// 加载状态
  const AppState.loading() : this._(AppStateType.loading);

  /// 数据状态
  const AppState.data(T data) : this._(AppStateType.data, data: data);

  /// 错误状态
  const AppState.error(String errorMessage)
      : this._(AppStateType.error, errorMessage: errorMessage);

  /// 空状态
  const AppState.empty() : this._(AppStateType.empty);

  /// 是否为加载状态
  bool get isLoading => type == AppStateType.loading;

  /// 是否为数据状态
  bool get isData => type == AppStateType.data;

  /// 是否为错误状态
  bool get isError => type == AppStateType.error;

  /// 是否为空状态
  bool get isEmpty => type == AppStateType.empty;

  /// 获取数据，如果不是数据状态则返回null
  T? get dataOrNull => isData ? data : null;

  /// 获取错误信息，如果不是错误状态则返回null
  String? get errorOrNull => isError ? errorMessage : null;

  @override
  String toString() {
    switch (type) {
      case AppStateType.loading:
        return 'AppState.loading()';
      case AppStateType.data:
        return 'AppState.data($data)';
      case AppStateType.error:
        return 'AppState.error($errorMessage)';
      case AppStateType.empty:
        return 'AppState.empty()';
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppState<T> &&
        other.type == type &&
        other.data == data &&
        other.errorMessage == errorMessage;
  }

  @override
  int get hashCode => Object.hash(type, data, errorMessage);
}

/// AppState构建器Widget
class AppStateBuilder<T> extends StatelessWidget {
  final AppState<T> state;
  final Widget Function() onLoading;
  final Widget Function(T data) onData;
  final Widget Function(String error) onError;
  final Widget Function()? onEmpty;

  const AppStateBuilder({
    Key? key,
    required this.state,
    required this.onLoading,
    required this.onData,
    required this.onError,
    this.onEmpty,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    switch (state.type) {
      case AppStateType.loading:
        return onLoading();
      case AppStateType.data:
        return onData(state.data as T);
      case AppStateType.error:
        return onError(state.errorMessage!);
      case AppStateType.empty:
        return onEmpty?.call() ?? const SizedBox.shrink();
    }
  }
}

/// 默认加载Widget
class DefaultLoadingWidget extends StatelessWidget {
  const DefaultLoadingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }
}

/// 默认错误Widget
class DefaultErrorWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const DefaultErrorWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('重试'),
            ),
          ]
        ],
      ),
    );
  }
}

/// 默认空状态Widget
class DefaultEmptyWidget extends StatelessWidget {
  final String message;
  final Widget? icon;

  const DefaultEmptyWidget({
    Key? key,
    this.message = '暂无数据',
    this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          icon ??
              Icon(
                Icons.inbox_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}