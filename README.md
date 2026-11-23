# SelfLearn

Ứng dụng học tập và luyện tập kiến thức được xây dựng bằng Flutter.

## Trạng thái triển khai

### App Foundation & App Shell

- Design tokens Blue Modern cho màu sắc, typography, spacing, radius, glass, breakpoints và motion.
- Theme Light / Dark / System; lựa chọn theme hiện được giữ trong phiên chạy. Lưu lựa chọn qua lần mở app sẽ được bổ sung cùng tính năng Settings/persistence.
- App Shell thích ứng theo chiều rộng khả dụng: Bottom Navigation trên phone, NavigationRail/sidebar trên tablet.
- Glass Selection Indicator dùng chung một lớp blur, trượt 180 ms với `easeOutCubic` và tôn trọng Reduce Motion.
- Home Dashboard bản đầu với số liệu khởi tạo rỗng và các lối tắt minh họa. Các luồng tạo/import JSON và dữ liệu thật chưa được triển khai trong phase này.

## Công nghệ

- Flutter / Dart
- Material 3
- Android

Các quyết định sản phẩm vẫn theo `SelfLearn_Product_Decisions.md` trong bộ tài liệu dự án. App không gọi AI API để tạo đề; người dùng sẽ chủ động trao đổi với ChatGPT/Gemini bên ngoài rồi nhập JSON.

## Cài đặt

```bash
flutter pub get
flutter run
```

## Kiểm tra chất lượng

```bash
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug
```

## Responsive smoke test

Kiểm tra tối thiểu các kích thước logical width: 320, 360, 390, 599, 600, 768, 839, 840, 1024 và 1200 px; đồng thời kiểm tra landscape, text scale lớn và Reduce Motion.

## Phiên bản

Xem lịch sử phát triển tại Git.
