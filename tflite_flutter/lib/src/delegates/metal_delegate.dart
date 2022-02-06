import 'dart:ffi';

// ignore: import_of_legacy_library_into_null_safe
import 'package:ffi/ffi.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/check.dart';
import '../bindings/delegate.dart';
import '../bindings/types.dart';
import '../delegate.dart';

/// Metal Delegate for iOS
class GpuDelegate implements Delegate {
  Pointer<TfLiteDelegate> _delegate;
  bool _deleted = false;

  @override
  Pointer<TfLiteDelegate> get base => _delegate;

  GpuDelegate._(this._delegate);

  factory GpuDelegate({ GpuDelegateOptions? options }) =>
      GpuDelegate._(tflGpuDelegateCreate!(options?.base ?? GpuDelegateOptions(true, TFLGpuDelegateWaitType.active).base));

  @override
  void delete() {
    checkState(!_deleted, message: 'TfLiteGpuDelegate already deleted.');
    tflGpuDelegateDelete!(_delegate);
    _deleted = true;
  }
}

/// Metal Delegate options
class GpuDelegateOptions {
  Pointer<TFLGpuDelegateOptions> _options;
  bool _deleted = false;

  Pointer<TFLGpuDelegateOptions> get base => _options;

  GpuDelegateOptions._(this._options);

  factory GpuDelegateOptions(bool allowPrecisionLoss, TFLGpuDelegateWaitType waitType) {
    return GpuDelegateOptions._(TFLGpuDelegateOptions.allocate(allowPrecisionLoss, waitType).addressOf);
  }

  void delete() {
    checkState(!_deleted, message: 'TfLiteGpuDelegate already deleted.');
    calloc.free(_options);
    _deleted = true;
  }
}
