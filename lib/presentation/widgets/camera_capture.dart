export 'camera_capture_stub.dart'
    if (dart.library.js_interop) 'camera_capture_web.dart'
    if (dart.library.io) 'camera_capture_mobile.dart';
