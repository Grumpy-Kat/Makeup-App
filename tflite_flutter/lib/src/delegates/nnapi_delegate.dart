import 'dart:ffi';

// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/check.dart';
import '../bindings/delegate.dart';
import '../bindings/types.dart';
import '../delegate.dart';

/// NnApi Delegate for Android
class NnApiDelegate implements Delegate {
  Pointer<TfLiteDelegate> _delegate;
  bool _deleted = false;

  @override
  Pointer<TfLiteDelegate> get base => _delegate;

  NnApiDelegate._(this._delegate);

  factory NnApiDelegate() {
    return NnApiDelegate._(tfLiteStatefulNnApiDelegateCreate!());
  }

  @override
  void delete() {
    checkState(!_deleted,
        message: 'TfLiteStatefulNnApiDelegate already deleted.');
    tfLiteStatefulNnApiDelegateDelete!(_delegate);
    _deleted = true;
  }
}
