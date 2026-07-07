import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _Env.baseUrl;
}

// RUN THIS COMMAND TO GENERATE THE ENV.G.DART FILE
// flutter pub run build_runner build
// or
// flutter pub run build_runner build --delete-conflicting-outputs
