# BLUEPRINT XÂY DỰNG ỨNG DỤNG FLUTTER / DART

> **Mục tiêu:** Tạo một ứng dụng mobile hiện đại, giao diện gọn và đẹp, có sidebar, panel, dropdown/combobox, animation khi tương tác, lưu dữ liệu offline trên thiết bị và hỗ trợ tốt điện thoại, Android tablet và iPad.
>
> **Ngày biên soạn:** 20/11/2026  
> **Nền tảng tham chiếu:** Flutter 3.50.0 stable · Dart 3.14.0  
> **Định hướng:** Ưu tiên ổn định, dễ bảo trì, responsive/adaptive và tận dụng không gian hiển thị; không chạy theo hiệu ứng hoặc package chỉ để làm giao diện phức tạp.

---

## 1. Định hướng sản phẩm và nguyên tắc thiết kế

Tài liệu này là bộ khung kỹ thuật cho một ứng dụng Flutter có thể được dùng làm nền cho nhiều loại sản phẩm: quản lý dữ liệu, ghi chú, theo dõi công việc, quản lý thiết bị, quản lý hồ sơ hoặc dashboard cá nhân. Vì chức năng nghiệp vụ cụ thể chưa được xác định, tên màn hình và bảng dữ liệu mẫu bên dưới mang tính minh họa; cần thay bằng domain thực tế khi bắt đầu triển khai.

### 1.1. Mục tiêu giao diện

- **Đẹp nhưng đơn giản:** dùng ít màu, ít hiệu ứng trang trí, hình khối rõ ràng; ưu tiên nội dung hơn trang trí.
- **Phân cấp rõ:** tiêu đề và dữ liệu chính nổi bật; nhãn, mô tả, thời gian và thông tin phụ dùng màu/độ đậm nhẹ hơn.
- **Mật độ hiển thị hợp lý:** khoảng cách đủ để phân vùng nhưng không tạo các khoảng trắng lớn không cần thiết.
- **Ưu tiên tablet:** khi có diện tích, hiển thị sidebar và nội dung cạnh nhau; có thể mở thêm panel chi tiết mà không phải chuyển màn hình.
- **Responsive + adaptive:** vừa tự co giãn theo chiều rộng, vừa thay đổi cách điều hướng và tương tác theo thiết bị.
- **Tương tác có phản hồi:** button, dropdown, panel, sidebar, tab và nội dung chuyển trang có animation ngắn, mượt, không gây chậm thao tác.
- **Offline-first:** dữ liệu chính được lưu trong SQLite; ứng dụng vẫn xem, tạo, sửa và tìm kiếm dữ liệu khi không có Internet.
- **Dark / Light / System:** cho phép chọn giao diện sáng, tối hoặc theo hệ thống; lựa chọn được lưu sau khi đóng ứng dụng.

### 1.2. Nguyên tắc không nên vi phạm

1. Không đặt toàn bộ logic, truy vấn database và xử lý nghiệp vụ trực tiếp trong `build()` của Widget.
2. Không dùng một bộ layout cố định cho mọi kích thước màn hình.
3. Không đặt `width`/`height` tuyệt đối cho mọi thành phần. Chỉ dùng kích thước cố định khi có lý do rõ ràng như độ rộng sidebar hoặc chiều cao icon button.
4. Không dùng quá nhiều màu nhấn, gradient, shadow hoặc bo góc lớn cùng lúc.
5. Không animate mọi thứ. Chỉ animate những thay đổi trạng thái giúp người dùng hiểu điều gì đang xảy ra.
6. Không dùng `SharedPreferences` để lưu danh sách dữ liệu nghiệp vụ lớn, dữ liệu quan trọng hoặc mật khẩu/token.
7. Không truy cập SQLite trực tiếp trong Widget; đi qua DAO/Repository.
8. Không tự viết lại các component chuẩn như dropdown, dialog, navigation và focus management nếu Material đã có component phù hợp.

---

## 2. Nền tảng và phiên bản Flutter/Dart

### 2.1. Phiên bản khuyến nghị

Tại ngày 20/11/2026, Flutter 3.50.0 stable đi cùng Dart 3.14.0. Đây là baseline tham chiếu của tài liệu; khi triển khai thực tế, kiểm tra lại kênh stable, ghi lại phiên bản SDK nhóm sử dụng và cố định dependency qua `pubspec.lock`.

```powershell
flutter --version
flutter doctor -v
flutter channel stable
flutter upgrade
```

Không nhất thiết phải nâng SDK ngay khi có bản mới. Với ứng dụng đang triển khai, chỉ nâng khi đã đọc release notes, kiểm tra breaking changes và chạy lại toàn bộ test/build.

### 2.2. Lưu ý quan trọng về Material UI trong Flutter 3.50

Flutter 3.50 tách thư viện Material và Cupertino ra khỏi Flutter SDK thành các package độc lập:

- Material UI: `package:material_ui/material_ui.dart`
- Cupertino UI: `package:cupertino_ui/cupertino_ui.dart`

Các thư viện cũ `package:flutter/material.dart` và `package:flutter/cupertino.dart` đã được đánh dấu deprecated trong Flutter 3.50. Vì dự án mới được xây dựng trên baseline này, nên dùng package độc lập ngay từ đầu và kiểm tra tính tương thích của plugin bên thứ ba.

Cài Material UI:

```powershell
flutter pub add material_ui
```

Import trong file Dart:

```dart
import 'package:material_ui/material_ui.dart';
```

Nếu dự án có phụ thuộc chưa chuyển sang Material UI độc lập, cần đọc hướng dẫn migration/compatibility bridge chính thức trước khi tích hợp. Không trộn các kiểu dữ liệu Material cũ và mới trong cùng API công khai vì chúng có thể không tương thích kiểu.

### 2.3. Tạo project

Nếu mục tiêu hiện tại là Android nhưng muốn giữ đường mở rộng cho iPadOS:

```powershell
flutter create --platforms=android,ios --org com.example my_app
cd my_app
flutter pub get
```

Thay `com.example` và `my_app` bằng namespace/tên dự án thực tế.

- Android có thể build và kiểm thử trên Windows, macOS hoặc Linux theo toolchain phù hợp.
- iPadOS cần môi trường macOS và Xcode để build/sign ứng dụng iOS/iPadOS. Có thể thiết kế responsive ngay từ đầu trên Windows, nhưng không thể hoàn tất quy trình build iPadOS chỉ bằng Windows.
- Đối với Android, lựa chọn `minSdk`, `targetSdk`, Android Gradle Plugin và Java/Kotlin theo yêu cầu của phiên bản Flutter/plugin đang dùng tại thời điểm build; không sao chép cấu hình cũ một cách máy móc.

---

## 3. Kiến trúc ứng dụng

### 3.1. Kiến trúc đề xuất: MVVM + Repository

Nên bắt đầu bằng kiến trúc **MVVM (Model–View–ViewModel)** kết hợp Repository. Đây là cách tổ chức phù hợp cho ứng dụng có nhiều màn hình, database local, bộ lọc, trạng thái UI và khả năng mở rộng.

```text
              ┌───────────────────────────────┐
              │             VIEW              │
              │   Screens / Widgets / Forms   │
              └───────────────┬───────────────┘
                              │ events / UI state
              ┌───────────────▼───────────────┐
              │          VIEWMODEL             │
              │ State, validation, commands    │
              └───────────────┬───────────────┘
                              │ calls
              ┌───────────────▼───────────────┐
              │          REPOSITORY            │
              │ Source of truth, mapping,      │
              │ caching, error handling        │
              └───────────────┬───────────────┘
                              │
                 ┌────────────┴────────────┐
                 │                         │
        ┌────────▼────────┐       ┌────────▼────────┐
        │ Local data      │       │ Remote service  │
        │ Drift / SQLite  │       │ REST / Firebase │
        └─────────────────┘       └─────────────────┘
```

**Trách nhiệm từng lớp:**

| Thành phần | Nhiệm vụ | Không nên làm |
|---|---|---|
| View / Screen | Hiển thị, nhận thao tác, bố cục responsive | Tự viết SQL, xử lý nghiệp vụ dài |
| ViewModel / Controller | Giữ UI state, validate form, gọi repository, xử lý trạng thái loading/error | Biết chi tiết đường dẫn file hoặc SQL thuần |
| Repository | Nguồn dữ liệu chuẩn, chuyển đổi model, cache, xử lý lỗi và đồng bộ | Chứa logic trình bày UI |
| DAO / Database | Query, insert, update, delete, transaction, migration | Biết Widget nào đang hiển thị dữ liệu |
| Service | Tích hợp API, file system, notification hoặc plugin nền tảng | Điều khiển trực tiếp UI |

Với nghiệp vụ phức tạp, có thể thêm lớp Domain/Use Case giữa ViewModel và Repository. Không cần thêm lớp này cho mọi thao tác CRUD đơn giản.

### 3.2. State management: Riverpod

Đề xuất dùng **`flutter_riverpod`** để quản lý trạng thái:

- Tách state khỏi Widget.
- Quản lý trạng thái bất đồng bộ (loading, data, error).
- Dễ mock dependency và kiểm thử ViewModel/Repository.
- Dùng chung được cho theme, điều hướng, bộ lọc, form, dữ liệu và trạng thái panel.

Không kết hợp cùng lúc Riverpod, Bloc, Provider và GetX chỉ vì mỗi package có một tiện ích riêng. Chọn một phương pháp chính để giữ kiến trúc nhất quán.

Nếu dự án rất nhỏ, chỉ có một vài màn hình và vài state đơn giản, `ValueNotifier`/`ChangeNotifier` của Flutter cũng đủ. Với blueprint này, mặc định dùng Riverpod để có đường mở rộng.

### 3.3. Điều hướng: go_router

Đề xuất `go_router` khi ứng dụng có nhiều trang, route lồng nhau, deep link hoặc cần giữ cấu trúc điều hướng ổn định.

- Dùng `ShellRoute`/`StatefulShellRoute` cho khu vực có navigation shell.
- Chọn route theo tính năng, ví dụ `/dashboard`, `/records`, `/reports`, `/settings`.
- Không dùng index thuần làm định danh trang nếu route có thể được mở trực tiếp từ notification/deep link.
- Với ứng dụng cực nhỏ, `Navigator` gốc vẫn có thể đáp ứng; không bắt buộc cài router package cho mọi ứng dụng.

### 3.4. Cấu trúc thư mục đề xuất

Ưu tiên chia theo feature, bên trong feature chia theo lớp. Cách này giúp thêm tính năng mà không tạo một thư mục `screens` hoặc `widgets` khổng lồ.

```text
lib/
├── main.dart
├── app/
│   ├── app.dart
│   ├── router/
│   │   ├── app_router.dart
│   │   └── route_names.dart
│   ├── theme/
│   │   ├── app_theme.dart
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   └── theme_controller.dart
│   └── shell/
│       ├── adaptive_app_shell.dart
│       ├── app_sidebar.dart
│       └── app_top_bar.dart
├── core/
│   ├── constants/
│   ├── errors/
│   ├── extensions/
│   ├── utils/
│   └── widgets/
│       ├── app_button.dart
│       ├── app_card.dart
│       ├── app_dropdown.dart
│       ├── empty_state.dart
│       ├── loading_view.dart
│       └── responsive_layout.dart
├── data/
│   ├── local/
│   │   ├── database/
│   │   │   ├── app_database.dart
│   │   │   ├── app_database.g.dart
│   │   │   ├── tables/
│   │   │   └── daos/
│   │   └── preferences/
│   ├── remote/
│   └── repositories/
├── features/
│   ├── dashboard/
│   │   ├── presentation/
│   │   │   ├── dashboard_screen.dart
│   │   │   └── dashboard_view_model.dart
│   │   └── domain/
│   ├── records/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   ├── reports/
│   └── settings/
└── l10n/
```

Quy tắc: không tạo file chỉ để có cấu trúc đẹp. Khi một feature còn rất nhỏ, có thể để ít file hơn; khi tính năng lớn dần thì tách model, view, viewmodel, repository và DAO.

---

## 4. Lưu trữ dữ liệu trên điện thoại

### 4.1. Khuyến nghị tổng thể

Dùng mô hình lưu trữ kết hợp, mỗi loại dữ liệu có nơi lưu phù hợp:

| Loại dữ liệu | Công nghệ | Ví dụ | Lý do |
|---|---|---|---|
| Dữ liệu nghiệp vụ có cấu trúc | **SQLite + Drift** | Hồ sơ, bản ghi, danh mục, lịch sử, trạng thái | Quan hệ, lọc, sắp xếp, tìm kiếm, transaction, migration |
| Cài đặt nhỏ | **SharedPreferencesAsync** | Theme mode, sidebar thu gọn, trang mặc định | Key-value đơn giản |
| Token / bí mật | **flutter_secure_storage** | Access token, refresh token, khóa bí mật | Lưu trữ an toàn theo cơ chế nền tảng |
| File đính kèm | App-specific file directory | Ảnh, PDF, tài liệu | Không nhồi file lớn vào bảng SQLite |
| Dữ liệu đồng bộ nhiều thiết bị (nếu cần) | Backend / Firebase / API | Tài khoản, dữ liệu dùng trên nhiều thiết bị | SQLite local không tự đồng bộ |

**Khuyến nghị chính:** SQLite qua `drift` + `drift_flutter` cho dữ liệu chính. `Drift` cung cấp query có kiểu dữ liệu, stream phản ứng khi dữ liệu thay đổi, transaction và migration. Nếu ứng dụng chỉ có vài bảng, CRUD nhỏ và người phát triển muốn tự viết SQL, `sqflite` cũng là phương án hợp lý; không cần cài cả hai.

### 4.2. Vì sao chọn Drift thay vì chỉ dùng SharedPreferences?

`SharedPreferences` không phải database. Nó phù hợp cho số lượng nhỏ các cặp key-value, không phù hợp để lưu danh sách hàng trăm/hàng nghìn bản ghi có quan hệ, filter, sort hoặc lịch sử.

SQLite phù hợp hơn khi cần:

- Tạo/sửa/xóa bản ghi.
- Lọc theo nhiều trường, sắp xếp và phân trang.
- Liên kết bản ghi với danh mục hoặc file đính kèm.
- Chạy transaction để tránh dữ liệu cập nhật nửa chừng.
- Nâng cấp schema khi phát hành phiên bản mới.
- Hoạt động khi thiết bị offline.

Drift phù hợp khi cần thêm type safety, generated code và stream dữ liệu. Nếu chọn `sqflite`, cần tự quản lý nhiều phần SQL, model mapping và cách phát tín hiệu cập nhật UI.

### 4.3. Cài package

```powershell
flutter pub add drift drift_flutter
flutter pub add shared_preferences path_provider
flutter pub add flutter_secure_storage
flutter pub add --dev drift_dev build_runner
```

`flutter_secure_storage` chỉ cần khi ứng dụng thực sự lưu thông tin bí mật. `path_provider` có thể cần khi quản lý file đính kèm hoặc tùy chỉnh vị trí dữ liệu; `drift_flutter` đã dùng các cơ chế Flutter cần thiết để thiết lập database mặc định.

### 4.4. Khởi tạo Drift database

Ví dụ cơ bản với một bảng ghi chú/record. Đây là bảng mẫu, thay đổi trường theo nghiệp vụ thật.

**`lib/data/local/database/tables/entries.dart`**

```dart
import 'package:drift/drift.dart';

class Entries extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get title => text().withLength(min: 1, max: 180)();

  TextColumn get description => text().nullable()();

  DateTimeColumn get createdAt =>
      dateTime().clientDefault(() => DateTime.now())();

  DateTimeColumn get updatedAt => dateTime().nullable()();

  BoolColumn get isArchived =>
      boolean().withDefault(const Constant(false))();
}
```

**`lib/data/local/database/app_database.dart`**

```dart
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'tables/entries.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Entries])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'my_app_database'));

  @override
  int get schemaVersion => 1;
}
```

Sinh code:

```powershell
dart run build_runner build --delete-conflicting-outputs
```

Sau khi thêm hoặc sửa bảng, chạy lại lệnh generate. Đưa file database qua một provider để các repository dùng chung một instance; không mở database mới cho mỗi lần build Widget.

### 4.5. Quy tắc thiết kế schema

Khi chuyển sang nghiệp vụ thực tế, nên xác định rõ:

- Primary key: dùng integer tăng tự động cho ứng dụng local đơn giản; dùng UUID/text ID khi cần import/export, đồng bộ hoặc hợp nhất dữ liệu.
- Foreign key: bật và dùng đúng quan hệ giữa bản ghi, danh mục và file đính kèm.
- Index: thêm index cho trường thường xuyên tìm kiếm/lọc/sắp xếp; tránh tạo index cho mọi cột.
- Timestamp: thống nhất quy tắc lưu UTC hoặc local time; khi hiển thị mới format theo locale/timezone.
- Soft delete: chỉ dùng `deletedAt`/`isDeleted` khi cần khôi phục hoặc đồng bộ; nếu không, xóa thật và xử lý file liên quan.
- Transaction: dùng khi một thao tác tác động nhiều bảng.
- Migration: tăng `schemaVersion` và viết migration có kiểm thử, không xóa database người dùng chỉ để cập nhật cấu trúc.

Gợi ý bộ bảng tổng quát:

| Bảng | Vai trò | Trường tham khảo |
|---|---|---|
| `records` | Dữ liệu chính | `id`, `title`, `description`, `category_id`, `status`, `created_at`, `updated_at` |
| `categories` | Nhóm/phân loại | `id`, `name`, `color`, `sort_order` |
| `attachments` | File đính kèm | `id`, `record_id`, `relative_path`, `mime_type`, `size_bytes`, `created_at` |
| `activity_logs` | Lịch sử thao tác khi cần | `id`, `record_id`, `action`, `created_at`, `metadata` |

### 4.6. Lưu file đính kèm

Không nên lưu ảnh/PDF dung lượng lớn trực tiếp trong SQLite dưới dạng BLOB trừ khi có lý do kỹ thuật rõ ràng.

Mô hình đề xuất:

1. Chép file vào thư mục riêng của ứng dụng.
2. Đặt tên file duy nhất, không dùng tên gốc làm đường dẫn nội bộ.
3. Lưu `relative_path`, MIME type, dung lượng và bản ghi sở hữu trong SQLite.
4. Khi xóa record, xóa metadata trong transaction; sau đó dọn file không còn được tham chiếu.
5. Khi backup, xuất cả database và file đính kèm hoặc đóng gói trong một archive.

Không yêu cầu quyền truy cập toàn bộ bộ nhớ (`MANAGE_EXTERNAL_STORAGE`) chỉ để lưu file nội bộ. Khi người dùng cần chọn file bên ngoài, dùng Android/iOS document picker hoặc file picker phù hợp.

### 4.7. Dữ liệu có mất khi gỡ ứng dụng không?

SQLite và SharedPreferences lưu trong vùng dữ liệu riêng của ứng dụng trên thiết bị. Chúng không tự đồng bộ sang điện thoại khác và thông thường sẽ bị xóa khi người dùng gỡ ứng dụng. Nếu dữ liệu quan trọng, cần lập kế hoạch backup/export/restore hoặc dịch vụ đồng bộ server. Không được quảng cáo local database là đã có backup cloud.

Nên có ít nhất:

- Xuất dữ liệu (JSON hoặc CSV tùy loại nội dung).
- Sao lưu database và file liên quan theo định dạng có version.
- Khôi phục có bước xác nhận và kiểm tra tính hợp lệ.
- Tùy chọn tự đồng bộ cloud chỉ khi có backend, tài khoản và quy tắc xử lý xung đột.

### 4.8. Bảo mật dữ liệu

- Không lưu password hoặc token trong SQLite/SharedPreferences dạng thường.
- Dùng `flutter_secure_storage` cho token/secret.
- SQLite không tự động đồng nghĩa với database đã mã hóa. Nếu lưu dữ liệu nhạy cảm, đánh giá threat model và lựa chọn giải pháp mã hóa database phù hợp (ví dụ SQLite/SQLCipher integration) trước khi phát hành.
- Tránh ghi token, dữ liệu cá nhân hoặc nội dung nhạy cảm vào log.
- Có chính sách xóa dữ liệu, export và xử lý backup rõ ràng.

---

## 5. Hệ thống giao diện và quy tắc thiết kế

### 5.1. Phong cách tổng thể

Phong cách đề xuất: **Clean Material 3 – Compact Workspace**.

Đặc điểm:

- Nền phẳng, trung tính; content panel sáng/tối theo theme.
- Accent color dùng cho thao tác chính, trạng thái được chọn và liên kết quan trọng.
- Card chỉ dùng để nhóm nội dung có quan hệ; không bọc mọi dòng dữ liệu vào một card riêng.
- Border mảnh, shadow rất nhẹ hoặc không dùng shadow; tránh cảm giác mỗi thành phần là một ô nổi.
- Icon đơn giản và thống nhất một bộ icon.
- Không dùng màu sắc để truyền đạt thông tin duy nhất; trạng thái quan trọng nên có icon/label đi kèm.

### 5.2. Bảng màu tham khảo

Bảng màu chỉ là điểm xuất phát. Dùng `ColorScheme.fromSeed` để tạo các sắc độ liên quan và kiểm tra độ tương phản trên thiết bị thực.

**Light theme**

| Token | Màu tham khảo | Vai trò |
|---|---|---|
| Primary | `#315FEA` | Button chính, selection, link quan trọng |
| Background | `#F5F7FB` | Nền tổng thể |
| Surface | `#FFFFFF` | Card, dialog, panel |
| Surface secondary | `#EEF2F7` | Vùng phụ, input nhẹ, selected container |
| Text primary | `#172033` | Tiêu đề và dữ liệu chính |
| Text secondary | `#64748B` | Mô tả, metadata, helper text |
| Border | `#D7DEE8` | Divider và viền nhẹ |
| Success | `#16865C` | Thành công/hoạt động |
| Warning | `#B7791F` | Cảnh báo |
| Error | `#D14343` | Lỗi/nguy hiểm |

**Dark theme**

| Token | Màu tham khảo | Vai trò |
|---|---|---|
| Primary | `#8EA7FF` | Accent trên nền tối |
| Background | `#0F141C` | Nền tổng thể |
| Surface | `#171E29` | Card, dialog, panel |
| Surface secondary | `#202A38` | Vùng phụ, selected container |
| Text primary | `#E8EDF5` | Nội dung chính |
| Text secondary | `#A8B3C5` | Mô tả và metadata |
| Border | `#344153` | Viền và divider |

**Nguyên tắc phân biệt nội dung chính/phụ:**

- Nội dung chính: `onSurface`, font weight 500–600, kích thước 14–20 tùy vai trò.
- Nội dung phụ: `onSurfaceVariant` hoặc màu secondary, font weight 400, thường 12–14.
- Nhãn: màu phụ, cỡ 12–13; không viết hoa toàn bộ nếu không cần.
- Chỉ dùng accent ở điểm cần tương tác hoặc trạng thái được chọn.
- Không dùng chữ xám quá nhạt trên nền trắng/tối; kiểm tra độ tương phản theo WCAG khi có thể.

### 5.3. Typography

| Vai trò | Kích thước tham khảo | Độ đậm |
|---|---:|---|
| Page title | 22–26 | 600 |
| Section title | 16–18 | 600 |
| Card title | 14–16 | 600 |
| Body | 14–16 | 400 |
| Secondary / helper | 12–13 | 400 |
| Button / navigation | 13–14 | 500–600 |

Không dùng nhiều font family. Có thể dùng font hệ thống để tối ưu tốc độ tải và tính nhất quán; nếu dùng font riêng, chỉ chọn một family có đủ weight cần thiết.

### 5.4. Spacing, margin, padding

Ưu tiên hệ spacing theo bội số 4 hoặc 8. Mục tiêu là gọn, không bị dính nhưng cũng không lãng phí diện tích.

| Token | Giá trị | Dùng cho |
|---|---:|---|
| `xs` | 4 px | Khoảng giữa icon và label |
| `sm` | 8 px | Khoảng giữa control gần nhau |
| `md` | 12 px | Padding compact, khoảng giữa nhóm |
| `lg` | 16 px | Padding card, khoảng giữa section nhỏ |
| `xl` | 20 px | Page inset trên tablet |
| `2xl` | 24 px | Section lớn khi thật sự cần |

Khuyến nghị mặc định:

- Page inset: 12–16 logical px trên điện thoại; 16–20 trên tablet.
- Khoảng cách giữa hai khu vực: 8–16 px.
- Padding card: 12–16 px.
- Gap trong form: 12 px; giữa nhóm form: 16 px.
- Sidebar item height: khoảng 44–48 px.
- Button/input height: khoảng 40–48 px; vùng chạm tương tác nên đạt tối thiểu 48×48 logical px khi khả thi.

Không áp dụng padding 24–32 px cho cả bốn phía của mọi component. Không lồng nhiều card có padding lớn vào nhau. Nếu đã có page inset, card bên trong chỉ cần padding vừa đủ.

### 5.5. Border và radius

| Thành phần | Radius gợi ý |
|---|---:|
| Input / button | 10–12 px |
| Card | 12–16 px |
| Dialog / bottom sheet | 16–20 px |
| Badge / chip | 8–12 px hoặc pill |

Dùng cùng một hệ radius. Không cần bo tròn quá mức mọi góc; một số divider, table và list row nên giữ đường biên vuông hoặc bo rất nhẹ.

---

## 6. Responsive và adaptive cho điện thoại, tablet, iPad

### 6.1. Breakpoint theo logical pixels

Không dựa vào tên thiết bị như “iPad” hay “tablet Samsung” để quyết định layout. Dùng chiều rộng thực tế mà widget nhận được, thông qua `LayoutBuilder` hoặc `MediaQuery`.

Breakpoint khởi đầu đề xuất:

| Chế độ | Chiều rộng khả dụng | Bố cục |
|---|---:|---|
| Compact | `< 600` | Nội dung một cột, sidebar dạng drawer overlay |
| Medium | `600–839` | NavigationRail cố định, nội dung một hoặc hai cột tùy màn hình |
| Expanded | `840–1199` | Sidebar cố định có thể thu gọn, nội dung chính chiếm phần còn lại |
| Large | `>= 1200` | Sidebar + nội dung chính + inspector/detail panel khi phù hợp |

Đây là breakpoint dự án đề xuất, không phải quy định bắt buộc của Flutter. Cần kiểm thử khi đổi hướng ngang/dọc, chia đôi màn hình, cửa sổ floating và màn hình gập.

### 6.2. Bố cục điều hướng theo kích thước

**Compact – điện thoại**

- AppBar gọn, có nút menu ở góc trái.
- Nhấn menu mở `NavigationDrawer` dạng overlay; chọn mục xong drawer tự đóng.
- Không giữ sidebar cố định vì sẽ chiếm quá nhiều chiều rộng.
- Có thể dùng `NavigationBar` ở đáy nếu ứng dụng chỉ có 3–4 mục chính và cần chuyển trang thường xuyên. Nếu màn hình cần tối đa chiều cao nội dung, ưu tiên drawer.

**Medium – tablet nhỏ / tablet dọc**

- `NavigationRail` cố định bên trái, mặc định chỉ hiện icon hoặc label ngắn.
- Nội dung chiếm vùng còn lại.
- Với form hoặc dashboard, dùng hai cột khi mỗi cột vẫn đủ chiều rộng; nếu không, giữ một cột.

**Expanded – tablet ngang / tablet lớn**

- Sidebar cố định khoảng 240–264 px.
- Có nút thu gọn thành rail khoảng 72–80 px.
- Sidebar có thể giữ logo/tên app, nhóm navigation, mục cài đặt ở cuối.
- Main content sử dụng hết chiều rộng còn lại, không căn giữa một khung nhỏ nếu dữ liệu cần bảng/list rộng.

**Large – tablet rất rộng**

- Sidebar 240–264 px.
- Main content linh hoạt.
- Inspector panel bên phải 280–320 px khi tính năng cần xem chi tiết song song.
- Có thể tắt panel để trả toàn bộ phần rộng cho nội dung chính.

### 6.3. Bố cục màn hình minh họa

```text
COMPACT / PHONE
┌─────────────────────────────────┐
│ ☰  Page title             Search│
├─────────────────────────────────┤
│                                 │
│        Main content             │
│        One column               │
│                                 │
└─────────────────────────────────┘
      Drawer xuất hiện khi bấm ☰

MEDIUM / TABLET
┌───────┬─────────────────────────┐
│  ◉    │ Page title       Actions│
│  ◉    ├─────────────────────────┤
│  ◉    │                         │
│  ◉    │ Main content             │
│  ⚙    │                         │
└───────┴─────────────────────────┘

EXPANDED / LARGE TABLET
┌──────────────┬───────────────────────────┬──────────────┐
│ App / Logo   │ Page title          ⋯     │ Inspector    │
│ Dashboard    ├───────────────────────────┤ Details      │
│ Records      │                           │              │
│ Reports      │ Main content              │ Properties   │
│              │                           │              │
│ Settings     │                           │              │
└──────────────┴───────────────────────────┴──────────────┘
```

### 6.4. Responsive content

- Dashboard cards: một cột ở màn hình hẹp, hai cột ở tablet, ba cột khi vùng nội dung thực sự đủ rộng.
- List/table: điện thoại ưu tiên card/list row; tablet có thể dùng data table với cột quan trọng. Không thu nhỏ chữ quá mức chỉ để ép bảng vừa màn hình.
- Detail: điện thoại mở trang chi tiết hoặc bottom sheet; tablet có thể mở inspector panel bên phải.
- Form: một cột trên điện thoại; chia hai cột cho các trường độc lập trên tablet ngang. Trường cần nhiều chiều rộng như mô tả, ghi chú hoặc địa chỉ vẫn chiếm full row.
- Search/filter: gom vào filter panel hoặc bottom sheet trên điện thoại; hiển thị thành toolbar hoặc panel trên tablet.
- Hình ảnh: dùng `AspectRatio`, `BoxFit.cover/contain` phù hợp, tránh kích thước pixel cố định.
- Text: cho phép scale theo cài đặt trợ năng, kiểm tra các label dài và tiếng Việt.

### 6.5. Ví dụ lựa chọn layout bằng LayoutBuilder

```dart
import 'package:material_ui/material_ui.dart';

class ResponsivePage extends StatelessWidget {
  const ResponsivePage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;

        if (width < 600) {
          return const CompactPageLayout();
        }

        if (width < 840) {
          return const MediumPageLayout();
        }

        if (width < 1200) {
          return const ExpandedPageLayout();
        }

        return const LargePageLayout();
      },
    );
  }
}
```

Tên class layout ở ví dụ là các Widget cần triển khai trong dự án. Ưu tiên breakpoint dựa trên chiều rộng khả dụng của khu vực đang layout thay vì chỉ đọc kích thước toàn màn hình; điều này giúp layout đúng khi mở panel hoặc chạy ở cửa sổ chia đôi.

---

## 7. Sidebar, panel và điều hướng

### 7.1. Sidebar

Sidebar nên có cấu trúc đơn giản:

1. **Header:** logo/icon và tên ứng dụng.
2. **Primary navigation:** các khu vực được sử dụng thường xuyên.
3. **Secondary navigation:** công cụ ít dùng hơn, có thể gom nhóm.
4. **Footer:** Settings, Help, Profile hoặc trạng thái tài khoản.

Trạng thái cần hỗ trợ:

- Expanded: icon + label.
- Collapsed: icon; tooltip khi hover/long press.
- Selected: nền tonal nhẹ + icon/text primary; không cần màu nền quá đậm.
- Hover/focus: nền rất nhẹ.
- Compact: modal drawer overlay.

Không đặt quá nhiều mục menu. Nếu có trên 8–10 mục, nhóm theo category và cho phép expand/collapse nhóm.

### 7.2. Animation sidebar

- Thời gian mở/thu gọn: khoảng 200–260 ms.
- Dùng `AnimatedContainer` để chuyển độ rộng.
- Dùng `AnimatedSwitcher` hoặc `AnimatedOpacity` cho label.
- Không dựng lại toàn bộ cây điều hướng theo cách làm mất route/scroll state.
- Giữ vị trí selected item khi sidebar chuyển trạng thái.

Ví dụ ý tưởng:

```dart
AnimatedContainer(
  duration: const Duration(milliseconds: 220),
  curve: Curves.easeInOutCubic,
  width: isExpanded ? 252 : 76,
  child: AppSidebarContent(isExpanded: isExpanded),
)
```

### 7.3. Panel / inspector

Panel có thể chứa thông tin chi tiết, bộ lọc hoặc thuộc tính của record đang chọn.

| Thiết bị | Cách hiển thị |
|---|---|
| Điện thoại | ModalBottomSheet, Dialog hoặc route chi tiết |
| Tablet dọc / medium | BottomSheet hoặc trang chi tiết tùy tác vụ |
| Tablet ngang / expanded | Panel bên phải, có nút đóng |
| Màn hình rộng | Inspector panel độc lập; main content co giãn |

Khi panel mở/đóng:

- Panel trượt nhẹ từ cạnh tương ứng hoặc xuất hiện bằng fade + size.
- Main content co giãn theo panel, không bị phủ mờ nếu không phải modal.
- Modal overlay cần nền scrim vừa đủ để biểu thị focus.
- Có nút đóng rõ ràng, hỗ trợ back gesture/back button và Escape trên thiết bị có bàn phím.
- Nếu đang nhập liệu chưa lưu, xác nhận trước khi đóng hoặc chuyển record.

Dùng `AnimatedSize`, `AnimatedSlide`, `AnimatedSwitcher` hoặc animation route tùy hiệu ứng. Không viết animation controller phức tạp nếu một implicit animation đã đáp ứng.

### 7.4. Dialog và bottom sheet

- Xác nhận thao tác phá hủy dữ liệu: Dialog có mô tả hậu quả, nút Cancel và Delete rõ ràng.
- Form ngắn trên mobile: bottom sheet hoặc full-screen form tùy số trường.
- Bộ lọc: bottom sheet trên điện thoại, side panel trên tablet.
- Không mở dialog cho mọi hành động nhỏ; thao tác thông thường nên xử lý inline hoặc bằng snackbar.

---

## 8. Component, button, combobox và tương tác

### 8.1. Button

Phân loại tối đa 3 tầng:

- **Primary:** hành động chính của màn hình, ví dụ Save/Create.
- **Secondary / tonal:** hành động phụ quan trọng, ví dụ Filter/Export.
- **Text/Icon:** hành động nhẹ, ví dụ More, Close, Edit trong ngữ cảnh phù hợp.

Quy tắc:

- Một khu vực thường chỉ có một primary action.
- Nút có label cụ thể; tránh các nhãn mơ hồ như “OK” khi có thể viết “Lưu thay đổi”.
- Khi tác vụ đang chạy, disable nút hoặc đổi sang loading state để tránh bấm lặp.
- Có trạng thái hover, focus, pressed, disabled và loading.
- Vùng chạm đủ lớn; không thu nhỏ icon button đến mức khó bấm trên tablet cảm ứng.

### 8.2. Animation khi click button

Cảm giác tương tác nên nhẹ và nhanh:

| Tác vụ | Thời gian tham khảo | Hiệu ứng |
|---|---:|---|
| Press feedback | 90–140 ms | Scale xuống khoảng 0.97–0.99 hoặc thay đổi tonal overlay |
| Hover/focus | 100–160 ms | Đổi nền/viền nhẹ |
| Button loading | Theo tác vụ | Progress indicator thay nội dung/icon |
| Toggle | 150–220 ms | Animated icon/indicator |

Dùng Ink ripple/splash của Material kết hợp AnimatedScale/AnimatedContainer khi cần. Tránh scale quá lớn hoặc nảy mạnh vì làm UI có cảm giác đồ chơi.

### 8.3. Combobox / Dropdown

Chọn component dựa trên số lượng option và cách tìm kiếm:

| Trường hợp | Component đề xuất |
|---|---|
| 2–5 lựa chọn, hiển thị ngay | SegmentedButton hoặc RadioListTile |
| Danh sách ngắn, chọn một | DropdownMenu |
| Danh sách dài, cần gõ tìm | Autocomplete / SearchAnchor hoặc dialog chọn có search |
| Chọn nhiều giá trị | Checkbox list trong menu/dialog hoặc component multi-select riêng |
| Lọc danh sách phức tạp | Filter panel với chip và clear action |

Yêu cầu UX:

- Có label ở phía trên hoặc trong FormField; không chỉ dựa vào placeholder.
- Giá trị đã chọn cần nhìn thấy rõ.
- Mở menu có animation tự nhiên; đóng menu sau khi chọn nếu là single-select.
- Danh sách dài phải có search, scroll và empty state.
- Hỗ trợ bàn phím, focus, screen reader và thao tác cảm ứng.
- Không tự viết overlay menu từ đầu nếu `DropdownMenu`, `MenuAnchor` hoặc `Autocomplete` phù hợp.

### 8.4. Form và validation

- Dùng `Form` + `TextFormField`/form widgets tương ứng.
- Validate khi submit hoặc sau khi người dùng rời field; tránh báo lỗi khi người dùng chưa nhập gì.
- Error message ngắn và nói rõ cách sửa.
- Tách validation nghiệp vụ khỏi Widget nếu logic dài.
- Trên tablet, chia cột khi trường độc lập; không chia đôi các field cần nội dung dài.
- Có trạng thái unsaved changes và xác nhận trước khi bỏ thay đổi.

### 8.5. List, card và table

- Dùng `ListView.builder`/slivers cho danh sách dài.
- Có loading, empty, error, refreshing và loaded state rõ ràng.
- Dùng pagination hoặc lazy loading khi dữ liệu nhiều.
- Không bọc từng dòng đơn giản trong card nổi riêng.
- Tablet có thể hiển thị danh sách bên trái và detail bên phải (master-detail).
- Giữ vị trí scroll khi mở chi tiết/quay lại nếu trải nghiệm cần thiết.

---

## 9. Animation và chuyển cảnh

### 9.1. Bộ quy tắc motion

| Thành phần | Khoảng thời gian | Gợi ý |
|---|---:|---|
| Button press | 90–140 ms | Scale/tonal feedback |
| Hover/focus | 100–160 ms | Fade/background |
| Dropdown/menu | 140–200 ms | Fade + slight scale/slide |
| Sidebar | 200–260 ms | Width + label fade |
| Side panel | 220–280 ms | Slide + size |
| Page transition | 180–260 ms | Fade/slide nhẹ |
| Theme transition | 180–300 ms | Chuyển màu mượt, không nháy |
| List insertion/removal | 180–240 ms | AnimatedList hoặc AnimatedSwitcher |

Giá trị trên là guideline thiết kế, không phải yêu cầu kỹ thuật của Flutter. Cần đo trên thiết bị thực.

### 9.2. Widget nên ưu tiên

- `AnimatedContainer`: đổi màu, padding, border radius, kích thước.
- `AnimatedOpacity`: fade in/out.
- `AnimatedSize`: panel/section mở rộng và thu gọn.
- `AnimatedSwitcher`: thay đổi nội dung/state.
- `AnimatedList`: thêm/xóa item có animation.
- `TweenAnimationBuilder`: hiệu ứng riêng không quá phức tạp.
- `Hero`: chuyển tiếp cùng một đối tượng giữa hai route khi thực sự giúp người dùng nhận biết quan hệ.
- `AnimationController`: chỉ dùng khi cần điều khiển thời gian/chuỗi animation tùy chỉnh.

### 9.3. Không lạm dụng animation

- Không dùng animation dài hơn 300–400 ms cho thao tác thường ngày.
- Không animate toàn màn hình khi chỉ một label thay đổi.
- Không để animation chặn thao tác tiếp theo.
- Không tạo chuyển động lặp liên tục ở màn hình làm việc.
- Tôn trọng thiết lập Reduce Motion của hệ điều hành; Flutter 3.50 cung cấp tín hiệu `MediaQueryData.reduceMotion` để ứng dụng giảm hoặc thay thế chuyển động mạnh bằng fade đơn giản.
- Khi animation bị giảm/tắt, chức năng vẫn phải đầy đủ và trạng thái vẫn rõ ràng.

---

## 10. Dark theme / Light theme / System theme

### 10.1. Ba chế độ giao diện

- **System:** theo giao diện sáng/tối của thiết bị.
- **Light:** giao diện sáng, nền sáng và nội dung tối.
- **Dark:** giao diện tối, nền tối và nội dung sáng.

Không chỉ đổi màu nền. Phải kiểm tra cả icon, divider, border, shadow, chart, selected item, dialog, bottom sheet, input, dropdown và trạng thái disabled.

### 10.2. Khai báo ThemeData

**`lib/app/theme/app_theme.dart`**

```dart
import 'package:material_ui/material_ui.dart';

class AppTheme {
  AppTheme._();

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF315FEA),
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: const Color(0xFFF5F7FB),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8EA7FF),
      brightness: Brightness.dark,
    ),
    scaffoldBackgroundColor: const Color(0xFF0F141C),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
  );
}
```

Khi hoàn thiện, có thể tách palette thành tokens và cấu hình component theme riêng. Tránh khai báo màu literal ở hàng chục Widget; mọi màu chính nên đi qua `Theme.of(context).colorScheme` hoặc design tokens.

### 10.3. Lưu lựa chọn theme

Dùng `SharedPreferencesAsync` cho cài đặt nhỏ. Với Riverpod 3, có thể triển khai một `AsyncNotifier` để load setting lúc khởi động và lưu khi người dùng đổi chế độ.

**`lib/app/theme/theme_controller.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferencesAsync>(
  (ref) => SharedPreferencesAsync(),
);

final themeModeProvider =
    AsyncNotifierProvider<ThemeModeController, ThemeMode>(
  ThemeModeController.new,
);

class ThemeModeController extends AsyncNotifier<ThemeMode> {
  static const _storageKey = 'theme_mode';

  @override
  Future<ThemeMode> build() async {
    final preferences = ref.read(sharedPreferencesProvider);
    final savedValue = await preferences.getString(_storageKey);

    return switch (savedValue) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    final value = switch (mode) {
      ThemeMode.system => 'system',
      ThemeMode.light => 'light',
      ThemeMode.dark => 'dark',
    };

    await ref.read(sharedPreferencesProvider).setString(_storageKey, value);
    state = AsyncData(mode);
  }
}
```

**`lib/app/app.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'theme/app_theme.dart';
import 'theme/theme_controller.dart';

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeState = ref.watch(themeModeProvider);

    final themeMode = themeState.when(
      data: (mode) => mode,
      loading: () => ThemeMode.system,
      error: (_, __) => ThemeMode.system,
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      home: const AppHomeShell(),
    );
  }
}
```

**`lib/main.dart`**

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app/app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: MyApp()));
}
```

`AppHomeShell` là shell điều hướng do dự án triển khai. Trong ứng dụng hoàn chỉnh, `home` có thể được thay bằng `MaterialApp.router` và `GoRouter`.

**Settings UI:** dùng `SegmentedButton<ThemeMode>` hoặc radio/select với 3 lựa chọn “Theo hệ thống / Sáng / Tối”. Khi người dùng đổi lựa chọn, gọi `setThemeMode`. Nên đặt ở Settings và có thể thêm quick action ở menu profile.

### 10.4. Ngôn ngữ và localization

Nên đặt nền tảng localization từ đầu, kể cả khi phiên bản đầu chỉ có tiếng Việt. Không hard-code câu chữ ở nhiều file nếu dự án có khả năng bổ sung tiếng Anh.

Với Material UI tách rời trong Flutter 3.50, dùng delegate từ `material_ui`:

```dart
import 'package:material_ui/material_ui.dart';

MaterialApp(
  supportedLocales: const [
    Locale('vi'),
    Locale('en'),
  ],
  localizationsDelegates: GlobalMaterialLocalizations.delegates,
  // theme, darkTheme, routerConfig...
)
```

Khi số lượng chuỗi tăng, dùng Flutter gen-l10n/ARB (`app_vi.arb`, `app_en.arb`) thay vì tự tạo một file map dịch thủ công. Kiểm tra ngày tháng, số thập phân, tiền tệ và định dạng thời gian theo locale; không nối chuỗi bằng cách giả định thứ tự từ trong tiếng Anh.

---

## 11. Gói thư viện nên dùng

Không cài mọi package ngay từ đầu. Chỉ thêm khi tính năng cần đến. Bảng dưới là stack đề xuất; các phiên bản pub.dev có thể thay đổi, vì vậy nên dùng `flutter pub add` để lấy bản tương thích và lưu kết quả trong `pubspec.lock`.

| Package | Mục đích | Mức ưu tiên |
|---|---|---|
| `material_ui` | Widget Material cho Flutter 3.50+ | Bắt buộc nếu dùng Material UI theo baseline này |
| `flutter_riverpod` | State management / dependency injection | Khuyến nghị |
| `go_router` | Routing/deep link/shell navigation | Khuyến nghị khi app có nhiều màn hình |
| `drift` | SQLite có type safety, stream và migration | Khuyến nghị |
| `drift_flutter` | Thiết lập Drift trên Flutter | Khuyến nghị khi dùng Drift |
| `drift_dev` | Code generation cho Drift | Dev dependency |
| `build_runner` | Chạy code generator | Dev dependency |
| `shared_preferences` | Lưu theme và cài đặt nhỏ | Khuyến nghị |
| `path_provider` | Lấy đường dẫn app documents/cache | Khi cần quản lý file/path |
| `flutter_secure_storage` | Token và dữ liệu bí mật nhỏ | Chỉ khi có secret |
| `flutter_lints` | Quy tắc lint Dart/Flutter | Khuyến nghị |

Cài nhóm cơ bản:

```powershell
flutter pub add material_ui flutter_riverpod go_router
flutter pub add drift drift_flutter shared_preferences
flutter pub add --dev drift_dev build_runner flutter_lints
```

Thêm khi có file đính kèm hoặc secret:

```powershell
flutter pub add path_provider flutter_secure_storage
```

Có thể tham khảo các bản đang xuất hiện trên pub.dev tại ngày 20/11/2026: `flutter_riverpod 3.5.0`, `go_router 18.1.4`, `drift 2.35.4`, `drift_flutter 0.3.1`, `shared_preferences 2.5.6`, `path_provider 2.1.6`, `flutter_secure_storage 11.2.0`. Không bắt buộc phải khóa đúng các số phiên bản này; luôn kiểm tra compatibility, changelog và known issues trước khi cập nhật.

### 11.1. Quy tắc quản lý dependencies

- Giữ `pubspec.lock` trong version control cho ứng dụng.
- Không chạy `pub upgrade --major-versions` một cách tùy tiện.
- Trước khi nâng package: đọc changelog, kiểm tra API breaking changes, build Android và test trên thiết bị.
- Tránh cài nhiều package có cùng vai trò.
- Ưu tiên package được duy trì, có tài liệu, có test, có mức sử dụng và issue tracker rõ ràng.
- Không dùng package chỉ vì có demo bắt mắt nếu nó làm tăng rủi ro hoặc khó bảo trì.

---

## 12. Hiệu năng, độ ổn định và trải nghiệm thiết bị

### 12.1. Hiệu năng giao diện

- Dùng `const` constructor khi có thể.
- Dùng `ListView.builder`, `GridView.builder` hoặc slivers với danh sách dài.
- Không chạy query lớn hoặc parsing nặng trong UI isolate.
- Dùng pagination, query giới hạn và index hợp lý.
- Tránh rebuild toàn bộ app khi chỉ một badge hoặc một field thay đổi; tách provider theo phạm vi state.
- Không dùng blur, shadow lớn và clipping phức tạp trên nhiều layer cùng lúc.
- Tối ưu ảnh: kích thước phù hợp, cache và thumbnail.
- Dùng Flutter DevTools để kiểm tra frame time, rebuild, memory và raster performance.

### 12.2. Quản lý vòng đời

- Dispose `TextEditingController`, `FocusNode`, `AnimationController`, `ScrollController`, subscription và stream đúng lúc.
- Không khởi tạo database hoặc service lặp đi lặp lại trong `build()`.
- Xử lý app resume/pause cho các tác vụ có liên quan.
- Không phụ thuộc vào việc app luôn chạy nền; Android có thể dừng process bất cứ lúc nào.

### 12.3. Offline-first và lỗi

- UI cần phân biệt loading, empty, error, offline và dữ liệu cũ.
- Đọc dữ liệu local trước để màn hình có nội dung ngay.
- Khi có backend sau này, repository chịu trách nhiệm sync và giải quyết xung đột; Widget không tự gọi API và tự ghi DB.
- Không hiển thị lỗi kỹ thuật dài cho người dùng; ghi log có kiểm soát và hiển thị thông báo có hướng xử lý.
- Khi save thất bại, giữ nội dung form để người dùng không mất dữ liệu.

### 12.4. Trợ năng và thao tác tablet

- Hỗ trợ font scale lớn.
- Có semantics/tooltip cho icon button không có label.
- Có focus ring/keyboard traversal khi dùng bàn phím ngoài.
- Có thể dùng chuột, touchpad và bàn phím trên tablet.
- Giữ vùng chạm đủ lớn.
- Tôn trọng Reduce Motion và độ tương phản hệ thống.
- Không dùng màu sắc đơn độc để thể hiện trạng thái.

---

## 13. Kiểm thử và tiêu chí nghiệm thu

### 13.1. Ma trận màn hình

Kiểm tra tối thiểu những kích thước logical width sau (có thể dùng emulator hoặc widget test):

| Width tham khảo | Kịch bản cần kiểm tra |
|---:|---|
| 360 | Điện thoại nhỏ, drawer, form 1 cột |
| 390–430 | Điện thoại phổ biến, nội dung không bị chật |
| 600 | Ranh giới compact/medium |
| 768 | Tablet dọc hoặc chia đôi màn hình |
| 840 | Ranh giới medium/expanded |
| 1024 | Tablet ngang, sidebar mở/thu gọn |
| 1200+ | Sidebar + nội dung + panel chi tiết |

Kiểm tra cả portrait/landscape, text scale, keyboard hiện lên, menu mở, panel mở, dữ liệu rỗng và danh sách dài.

### 13.2. Test kỹ thuật

- Unit test cho validation, ViewModel và Repository.
- DAO/database test cho CRUD, relation, transaction và migration.
- Widget test cho theme sáng/tối, drawer/rail/sidebar, panel và combobox.
- Integration test cho luồng tạo → sửa → xóa → đóng app → mở lại và kiểm tra dữ liệu.
- Test export/import và xử lý file đính kèm.
- Test lỗi database, file không tồn tại, quyền bị từ chối và mất kết nối nếu có remote service.

### 13.3. Checklist nghiệm thu UI

- [ ] Nội dung chính/phụ được phân cấp bằng màu, typography và spacing.
- [ ] Không có khoảng trống lớn vô nghĩa.
- [ ] Sidebar mở/đóng đúng theo breakpoint.
- [ ] Sidebar thu gọn/mở rộng có animation và không mất mục đang chọn.
- [ ] Panel có trạng thái mở/đóng rõ ràng và responsive.
- [ ] Button có pressed/disabled/loading feedback.
- [ ] Dropdown/combobox hỗ trợ lựa chọn, tìm kiếm khi danh sách dài và trạng thái rỗng.
- [ ] Light theme và dark theme đều có contrast tốt.
- [ ] Chế độ System hoạt động theo hệ điều hành.
- [ ] Theme mode được giữ lại sau khi khởi động lại app.
- [ ] Nội dung không tràn hoặc bị che khi xoay màn hình.
- [ ] Các thao tác chính dùng được bằng touch; các vùng tương tác đủ lớn.
- [ ] Có loading, empty, error và success state.
- [ ] Dữ liệu local tồn tại sau khi đóng/mở app.
- [ ] Database migration không làm mất dữ liệu cũ.
- [ ] Có hướng backup/export nếu dữ liệu quan trọng.
- [ ] Không có lỗi nghiêm trọng trong `flutter analyze`, unit test và build release.

---

## 14. Lộ trình triển khai theo phase

Không nên xây toàn bộ giao diện, database, animation và mọi tính năng trong một lần. Chia thành các phase nhỏ để build/test được sau từng giai đoạn.

### Phase 0 – Project foundation

1. Tạo Flutter project.
2. Xác nhận `flutter doctor -v` và thiết bị Android.
3. Cài Material UI, Riverpod, router và lint.
4. Thiết lập cấu trúc thư mục, app theme và design tokens.
5. Thiết lập CI/local checks: format, analyze, test.

**Kết quả:** project chạy được trên Android, có theme sáng/tối cơ bản.

### Phase 1 – Design system

1. Chốt bảng màu Light/Dark.
2. Chốt typography, spacing, radius và button styles.
3. Tạo `AppButton`, `AppCard`, `AppTextField`, `AppDropdown`, `EmptyState`, `LoadingView`.
4. Test các component trong cả hai theme.

**Kết quả:** component có style nhất quán, không phải viết lại style ở từng màn hình.

### Phase 2 – App shell và responsive navigation

1. Tạo router và app shell.
2. Tạo mobile drawer.
3. Tạo tablet navigation rail.
4. Tạo expanded sidebar có thể thu gọn.
5. Thêm panel/inspector và responsive page container.
6. Kiểm thử các breakpoint 360/600/768/840/1024/1200.

**Kết quả:** cấu trúc điều hướng và bố cục chạy tốt từ điện thoại đến tablet.

### Phase 3 – Database và Repository

1. Tạo Drift database.
2. Định nghĩa bảng theo nghiệp vụ.
3. Tạo DAO và migration version 1.
4. Tạo Repository.
5. Viết unit/database tests.
6. Tạo màn hình CRUD mẫu để xác nhận persistence.

**Kết quả:** dữ liệu được lưu thật trên thiết bị, có thể đọc lại sau khi khởi động app.

### Phase 4 – Các tính năng nghiệp vụ

Triển khai từng feature: View → ViewModel → Repository → DAO. Mỗi feature cần loading, empty, error và success state.

**Kết quả:** chức năng chính hoàn thành trước khi thêm hiệu ứng trang trí.

### Phase 5 – Motion và polish

1. Button feedback.
2. Sidebar animation.
3. Panel open/close.
4. Dropdown/menu transition.
5. Page/list transition có chọn lọc.
6. Reduce Motion.
7. Kiểm tra độ mượt trên thiết bị thật.

**Kết quả:** animation thống nhất và không làm chậm thao tác.

### Phase 6 – Backup, bảo mật và phát hành

1. Export/import dữ liệu.
2. Xử lý file đính kèm.
3. Xem xét secure storage/encryption nếu có dữ liệu nhạy cảm.
4. Kiểm tra Android permissions và app lifecycle.
5. Chạy integration tests, build release APK/AAB.
6. Chuẩn bị icon, splash screen, versioning và privacy policy nếu phát hành công khai.

**Kết quả:** bản release có thể kiểm thử người dùng và phát hành.

---

## 15. Các lệnh phát triển thường dùng

```powershell
# Kiểm tra Flutter/Dart và môi trường
flutter --version
flutter doctor -v

# Cài dependency
flutter pub get

# Sinh code Drift
dart run build_runner build --delete-conflicting-outputs

# Format và phân tích mã nguồn
dart format .
flutter analyze

# Chạy test
flutter test

# Chạy app trên thiết bị/emulator
flutter devices
flutter run

# Build Android release
flutter build apk --release
flutter build appbundle --release

# Kiểm tra dependency lỗi thời (chỉ xem trước, không tự động nâng)
flutter pub outdated
```

Sau mỗi phase nên chạy ít nhất:

```powershell
dart format .
flutter analyze
flutter test
flutter build apk --debug
```

Build release ở phase cuối và kiểm tra thêm trên thiết bị Android thật, không chỉ dựa vào emulator.

---

## 16. Quyết định kỹ thuật tổng kết

| Hạng mục | Quyết định đề xuất | Lý do |
|---|---|---|
| Ngôn ngữ | Dart | Ngôn ngữ chính của Flutter |
| UI | Material UI / Material 3 | Component phong phú, nhất quán, dễ tạo theme |
| Theme | Light / Dark / System | Theo cài đặt người dùng hoặc hệ thống |
| Kiến trúc | MVVM + Repository | Tách UI, state và dữ liệu |
| State management | Riverpod | Quản lý state và dependency có kiểm thử |
| Routing | go_router | Phù hợp nhiều trang và shell navigation |
| Database | SQLite qua Drift | Local-first, quan hệ, migration, query có kiểu |
| Cài đặt nhỏ | SharedPreferencesAsync | Theme, sidebar state, tùy chọn giao diện |
| Secret | flutter_secure_storage | Lưu token/bí mật riêng biệt |
| File | App-specific directory | Lưu ảnh/tài liệu ngoài database |
| Responsive | LayoutBuilder + breakpoint | Chuyển layout theo chiều rộng thực tế |
| Mobile navigation | Modal drawer | Giữ diện tích nội dung |
| Tablet navigation | NavigationRail / persistent sidebar | Tận dụng chiều rộng tablet |
| Tablet detail | Side inspector panel | Xem danh sách và chi tiết song song |
| Animation | Implicit animations trước | Đơn giản, dễ bảo trì, đủ mượt cho UI thường |

**Kết luận:** Với yêu cầu giao diện gọn, đẹp, có sidebar/panel animation và ưu tiên tablet, phương án cân bằng tốt là Flutter + Dart, Material UI, MVVM, Riverpod, go_router và SQLite/Drift. Hãy làm design system và responsive shell trước, database/repository tiếp theo, rồi mới hoàn thiện các animation. Cách này tránh việc giao diện đẹp nhưng khó mở rộng, dữ liệu lưu không đúng chỗ hoặc phải viết lại layout khi chạy trên iPad/tablet.

---

## 17. Tài liệu tham khảo chính thức và nguồn package

Các liên kết dưới đây được dùng để kiểm tra nền tảng, kiến trúc, responsive, database và package tại thời điểm biên soạn. Kiểm tra lại trước khi triển khai vì phiên bản package có thể thay đổi.

### Flutter / Dart

1. [Flutter 3.50 – What's new](https://flutter.dev/blog/whats-new-in-flutter-3-50) – phiên bản stable và thay đổi trong Flutter 3.50.
2. [Migrate to standalone material_ui and cupertino_ui packages](https://docs.flutter.dev/release/breaking-changes/material-ui-and-cupertino-ui) – hướng dẫn sử dụng package Material/Cupertino độc lập.
3. [Adaptive and responsive design in Flutter](https://docs.flutter.dev/ui/adaptive-responsive) – responsive/adaptive layout và thiết bị nhiều kích thước.
4. [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide) – Views, ViewModels, Repositories, Services và MVVM.
5. [Flutter architecture recommendations](https://docs.flutter.dev/app-architecture/recommendations) – nguyên tắc tách lớp và tổ chức app.
6. [Choose a database for your Flutter app](https://docs.flutter.dev/data-and-backend/persistence/choose-a-database) – phân biệt SQLite, key-value và cloud database.
7. [Persist data with SQLite](https://docs.flutter.dev/cookbook/persistence/sqlite) – ví dụ SQLite với sqflite.
8. [Implicit animations](https://docs.flutter.dev/ui/animations/implicit-animations) – animation tích hợp sẵn và cách dùng.

### Packages

1. [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
2. [go_router](https://pub.dev/packages/go_router)
3. [drift](https://pub.dev/packages/drift)
4. [drift_flutter](https://pub.dev/packages/drift_flutter)
5. [drift_dev](https://pub.dev/packages/drift_dev)
6. [shared_preferences](https://pub.dev/packages/shared_preferences)
7. [path_provider](https://pub.dev/packages/path_provider)
8. [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage)
9. [material_ui](https://pub.dev/packages/material_ui)

---

**Ghi chú phạm vi:** Đây là blueprint nền tảng và quy chuẩn triển khai, không phải mã nguồn của một ứng dụng nghiệp vụ hoàn chỉnh. Trước khi bắt đầu viết tính năng thực, cần xác định các module nghiệp vụ, entity, luồng người dùng và dữ liệu cụ thể để hoàn thiện schema, route và navigation item.
