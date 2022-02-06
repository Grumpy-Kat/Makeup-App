import 'dart:ffi';

// ignore: import_of_legacy_library_into_null_safe
import 'package:ffi/ffi.dart';

import 'dlib.dart';

/// Version information for the TensorFlowLite library.
final Pointer<Utf8> Function()? tfLiteVersion =
  tflitelib?.lookup<NativeFunction<_TfLiteVersion_native_t>>('TfLiteVersion').asFunction();

typedef _TfLiteVersion_native_t = Pointer<Utf8> Function();
