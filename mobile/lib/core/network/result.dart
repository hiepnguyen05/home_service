import 'app_exceptions.dart';

/// Pattern Result để xử lý kết quả thành công hoặc lỗi
sealed class Result<T> {
  const Result();
}

/// Kết quả thành công
class Success<T> extends Result<T> {
  final T data;
  
  const Success(this.data);
  
  @override
  String toString() => 'Success(data: $data)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Success<T> &&
      runtimeType == other.runtimeType &&
      data == other.data;
  
  @override
  int get hashCode => data.hashCode;
}

/// Kết quả lỗi
class Failure<T> extends Result<T> {
  final AppException exception;
  
  const Failure(this.exception);
  
  @override
  String toString() => 'Failure(exception: $exception)';
  
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Failure<T> &&
      runtimeType == other.runtimeType &&
      exception == other.exception;
  
  @override
  int get hashCode => exception.hashCode;
}

/// Extension methods cho Result
extension ResultExtensions<T> on Result<T> {
  /// Kiểm tra có phải thành công không
  bool get isSuccess => this is Success<T>;
  
  /// Kiểm tra có phải lỗi không
  bool get isFailure => this is Failure<T>;
  
  /// Lấy dữ liệu nếu thành công, null nếu lỗi
  T? get dataOrNull => switch (this) {
    Success<T>(data: final data) => data,
    Failure<T>() => null,
  };
  
  /// Lấy exception nếu lỗi, null nếu thành công
  AppException? get exceptionOrNull => switch (this) {
    Success<T>() => null,
    Failure<T>(exception: final exception) => exception,
  };
  
  /// Thực hiện action nếu thành công
  Result<T> onSuccess(void Function(T data) action) {
    if (this is Success<T>) {
      action((this as Success<T>).data);
    }
    return this;
  }
  
  /// Thực hiện action nếu lỗi
  Result<T> onFailure(void Function(AppException exception) action) {
    if (this is Failure<T>) {
      action((this as Failure<T>).exception);
    }
    return this;
  }
  
  /// Map dữ liệu nếu thành công
  Result<R> map<R>(R Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => Success(mapper(data)),
      Failure<T>(exception: final exception) => Failure(exception),
    };
  }
  
  /// FlatMap để chain các Result
  Result<R> flatMap<R>(Result<R> Function(T data) mapper) {
    return switch (this) {
      Success<T>(data: final data) => mapper(data),
      Failure<T>(exception: final exception) => Failure(exception),
    };
  }
}