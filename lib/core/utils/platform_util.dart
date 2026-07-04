import 'package:flutter/foundation.dart' show kIsWeb;

bool get isWebPlatform => kIsWeb;

bool get isMobilePlatform => !kIsWeb;
