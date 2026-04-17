/// 网络错误类型
enum NetworkErrorType {
  /// 请求超时
  timeout,

  /// 连接失败
  connectionFailed,

  /// 设备离线
  deviceOffline,

  /// 响应格式错误
  invalidResponse,

  /// 未知错误
  unknown,
}

/// 网络操作结果
sealed class NetworkResult<T> {
  const NetworkResult();
}

/// 网络操作成功
class NetworkSuccess<T> extends NetworkResult<T> {
  const NetworkSuccess(this.data);

  final T data;
}

/// 网络操作失败
class NetworkError<T> extends NetworkResult<T> {
  const NetworkError(this.message, this.type);

  final String message;
  final NetworkErrorType type;
}
