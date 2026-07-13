**Yêu Cầu Cấu Hình**

- **Dart SDK**: >=3.1.0 <4.0.0 (theo `environment` trong [pubspec.yaml](pubspec.yaml#L1-L20)).
- **Flutter SDK**: Stable channel; đảm bảo `dart --version` >= 3.1.0. Kiểm tra bằng `flutter --version`.
- **Java (JDK)**: 11 (project sử dụng `JavaVersion.VERSION_11`).
- **Gradle (wrapper)**: 8.10.2 (xem [android/gradle/wrapper/gradle-wrapper.properties](android/gradle/wrapper/gradle-wrapper.properties#L1-L10)).
- **Android Gradle Plugin (AGP)**: 8.7.0 (xem [android/settings.gradle.kts](android/settings.gradle.kts#L1-L40)).
- **Kotlin**: 1.8.22 (xem [android/settings.gradle.kts](android/settings.gradle.kts#L20-L30)).
- **Android NDK**: 27.0.12077973 (được đặt trong [android/app/build.gradle.kts](android/app/build.gradle.kts#L1-L40)).
- **Android SDK / Platforms**: Cài Android SDK Platform tương ứng với `compileSdk`/`targetSdk` do Flutter yêu cầu (chạy `flutter doctor -v` để biết thiếu gì). Khuyến nghị cài API 33+ và build-tools tương ứng.
- **Biến môi trường**: Thiết lập `ANDROID_SDK_ROOT`/`ANDROID_HOME` và (`ANDROID_NDK_HOME` nếu cần) hoặc quản lý qua Android Studio.

Các file tham chiếu chính:

- [pubspec.yaml](pubspec.yaml#L1-L20)
- [android/app/build.gradle.kts](android/app/build.gradle.kts#L1-L60)
- [android/settings.gradle.kts](android/settings.gradle.kts#L1-L40)
- [android/gradle/wrapper/gradle-wrapper.properties](android/gradle/wrapper/gradle-wrapper.properties#L1-L10)

Lệnh kiểm tra / cài đặt nhanh (Windows):

```
flutter --version
dart --version
flutter doctor -v
# Ví dụ cài NDK và Android platform bằng sdkmanager (Android SDK command-line tools cần có):
# sdkmanager "ndk;27.0.12077973" "platforms;android-33" "build-tools;33.0.2" "platform-tools"
flutter pub get
flutter run
```

**Google Maps**

- Enable Maps SDK for Android, Maps SDK for iOS, and Maps JavaScript API in Google Cloud.
- Android: add `GOOGLE_MAPS_API_KEY=your_key` to `android/local.properties`.
- Web: replace `YOUR_GOOGLE_MAPS_API_KEY` in `web/index.html` with a browser-restricted key.
- iOS: define the `GOOGLE_MAPS_API_KEY` build setting in Xcode.
- Do not commit API keys. Restrict each key by platform and application identifier.

Ghi chú:

- Chạy `flutter doctor -v` để biết các thành phần còn thiếu (SDK, licenses, v.v.).
- Trên Windows, đảm bảo `java -version` trả về JDK 11; nếu không, cài OpenJDK 11 và cập nhật `JAVA_HOME`.
- NDK có thể được cài qua Android Studio -> SDK Manager -> SDK Tools -> NDK (side by side) hoặc bằng `sdkmanager`.

\*\* lưu ý không có lưu src code ở trong thư mục mà nằm trong one drive nha lưu rồi clean one drive nó khóa
