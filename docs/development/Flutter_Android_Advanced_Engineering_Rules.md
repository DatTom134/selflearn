# QUY CHUẨN LẬP TRÌNH FLUTTER / DART NÂNG CAO

> **Mục đích:** Đây là bộ quy tắc kỹ thuật và quy trình làm việc bắt buộc khi phát triển ứng dụng Flutter/Dart cho Android, đồng thời giữ khả năng thích ứng tốt với Android tablet và iPad khi dự án có yêu cầu đa nền tảng.
>
> **Tài liệu liên kết:** `Flutter_Dart_Android_App_Blueprint.md` — blueprint về kiến trúc tổng thể, UI/UX, responsive, lưu trữ và tính năng nền tảng. Tài liệu hiện tại bổ sung quy trình phát triển, kiểm soát chất lượng, Git, phát hành và quản lý lỗi/tri thức dự án; không thay thế blueprint.
>
> **Ngày biên soạn:** 20/11/2026  
> **Ngôn ngữ:** Dart  
> **Framework:** Flutter stable  
> **Định hướng:** Ưu tiên ổn định, dễ bảo trì, kiểm thử được, an toàn dữ liệu và luôn giữ nhánh phát hành ở trạng thái có thể sử dụng.

---

## 0. Tuyên bố bắt buộc và thứ tự ưu tiên

Các quy tắc trong tài liệu này là mặc định cho toàn bộ vòng đời dự án, trừ khi chủ dự án chủ động phê duyệt ngoại lệ có lý do kỹ thuật rõ ràng.

### 0.1. Những nguyên tắc không được phá vỡ

1. **Không sửa code theo phỏng đoán.** Trước khi sửa phải đọc phần code liên quan, kiểm tra cách dự án đang tổ chức và xác định nguyên nhân hoặc phạm vi thay đổi.
2. **Không lặp lại lỗi đã biết.** Trước mỗi tính năng hoặc bug fix phải kiểm tra danh sách lỗi đã ghi nhận, các quyết định kiến trúc và các bài học của dự án.
3. **Không coi `build()` thành nơi xử lý nghiệp vụ.** Widget chỉ trình bày trạng thái và chuyển tiếp hành động; nghiệp vụ nằm ở lớp phù hợp.
4. **Không hoàn thành tính năng chỉ vì giao diện đã hiển thị.** Tính năng phải xử lý được trạng thái tải, rỗng, thành công, lỗi, dữ liệu biên và vòng đời ứng dụng.
5. **Không đẩy code chưa qua kiểm tra lên nhánh ổn định.** Mỗi lát tính năng nhỏ chỉ được merge vào nhánh ổn định khi đạt Definition of Done và Quality Gate.
6. **Không để nhánh ổn định bị hỏng.** Nhánh `main` phải luôn build được và có khả năng tạo ra bản cài đặt sử dụng được.
7. **Không lưu bí mật vào Git.** Keystore, mật khẩu ký, token, API key, file `.env` thực tế và dữ liệu cá nhân không được commit.
8. **Không nâng hàng loạt dependency/SDK trong cùng một thay đổi tính năng.** Nâng cấp phải có mục tiêu, đánh giá tương thích và bộ kiểm thử riêng.
9. **Không xóa hoặc ghi đè dữ liệu người dùng khi chưa có kế hoạch migration/backup/rollback.**
10. **Không tuyên bố đã kiểm thử, build, push hoặc phát hành nếu chưa thực sự thực hiện và xác minh kết quả.**

### 0.2. Thứ tự ưu tiên khi có xung đột

1. Yêu cầu trực tiếp đã được chủ dự án xác nhận.
2. An toàn người dùng, bảo mật và toàn vẹn dữ liệu.
3. Quy tắc trong tài liệu này và các quyết định đã ghi trong `docs/`.
4. Kiến trúc, style và convention hiện có trong repository.
5. Khuyến nghị chính thức mới nhất của Flutter, Dart, Android và các package đang sử dụng.
6. Sở thích cá nhân về cách viết code.

Không thay đổi một quy ước hiện tại chỉ vì có một phong cách khác đang phổ biến. Phải so sánh lợi ích, chi phí chuyển đổi và rủi ro hồi quy trước.

---

## 1. Quy trình bắt đầu mọi phiên làm việc

Trước khi viết hoặc sửa bất kỳ code nào, thực hiện checklist sau.

### 1.1. Xác minh repository và trạng thái hiện tại

- Xác định đúng thư mục gốc dự án.
- Đọc `README.md`, `pubspec.yaml`, cấu trúc `lib/`, `test/`, `integration_test/`, cấu hình Android và tài liệu trong `docs/`.
- Đọc `docs/quality/known_issues.md`, `docs/quality/lessons_learned.md` và các ADR liên quan nếu đã có.
- Kiểm tra branch, commit hiện tại, remote và thay đổi chưa commit.
- Không bắt đầu sửa trên một working tree có thay đổi chưa rõ nguồn gốc.
- Không tự ý reset, checkout đè, stash, clean hoặc xóa file của người dùng.

Lệnh PowerShell cơ bản:

```powershell
Set-Location "D:\dev\TenDuAn"
git status --short --branch
git branch --show-current
git log -5 --oneline
git remote -v
flutter --version
dart --version
flutter doctor -v
```

Nếu dự án chưa có remote Git, không giả định URL remote. Nếu remote không truy cập được, phải báo rõ; vẫn có thể tạo commit local nếu chủ dự án yêu cầu hoặc quy trình cho phép, nhưng không được tuyên bố đã push.

### 1.2. Kiểm tra tri thức và lỗi đã biết

Trước khi triển khai:

1. Tìm lỗi tương tự trong issue tracker, `known_issues.md`, `lessons_learned.md` và lịch sử Git.
2. Đọc các ghi chú kiến trúc có liên quan.
3. Kiểm tra xem dự án đã từng gặp lỗi về package/API, navigation, layout, state, SQLite, async, build Android, signing, migration hoặc responsive chưa.
4. Kiểm tra test hồi quy đã có để không viết một cách triển khai mâu thuẫn với giải pháp đã được xác nhận.
5. Nếu không tìm thấy dữ liệu lịch sử, nói rõ đây là lần đầu kiểm tra trong phạm vi repository hiện có; không khẳng định chắc chắn rằng lỗi chưa từng xuất hiện.

### 1.3. Thiết lập baseline trước thay đổi

Chạy các lệnh phù hợp với trạng thái hiện tại:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
```

Có thể chạy thêm build Android để xác minh baseline:

```powershell
flutter build apk --debug
```

Nếu baseline đã lỗi trước khi sửa:

- Ghi lại nguyên văn lỗi, lệnh chạy, phiên bản SDK và commit hiện tại.
- Phân loại lỗi là lỗi có sẵn hay lỗi do thay đổi mới.
- Không gán lỗi có sẵn cho thay đổi đang thực hiện.
- Không tiếp tục mở rộng phạm vi trước khi xác định lỗi baseline có ảnh hưởng đến công việc hay không.

Không chạy `flutter clean` theo thói quen. Chỉ dùng khi có bằng chứng về cache/build artifact lỗi hoặc sau khi thay đổi cấu hình native khiến cache không còn đáng tin cậy. Ghi lại lý do và đánh giá tác động trước khi chạy.

### 1.4. Lập kế hoạch thay đổi ngắn trước khi code

Mỗi tác vụ cần có:

- Mục tiêu người dùng nhìn thấy được.
- Phạm vi file/layer có khả năng phải thay đổi.
- Hành vi hiện tại cần giữ nguyên.
- Tiêu chí chấp nhận có thể kiểm tra.
- Các trường hợp lỗi/biên cần xử lý.
- Test sẽ thêm hoặc cập nhật.
- Rủi ro về database, dữ liệu cũ, navigation, quyền Android, hiệu năng và responsive.
- Lệnh xác minh sau khi triển khai.

Nếu phạm vi đang quá rộng, chia thành các lát chức năng nhỏ. Không chia nhỏ đến mức mỗi lát chỉ tạo ra code chết hoặc UI không có đường sử dụng thực tế.

---

## 2. Quy trình phát triển theo lát tính năng nhỏ

### 2.1. Định nghĩa một lát tính năng hoàn chỉnh

Một lát tính năng là một phần nhỏ có đầu vào, hành vi và kết quả kiểm chứng được. Ví dụ:

- Thêm một mục điều hướng và màn hình rỗng có đủ trạng thái.
- Thêm thao tác tạo một bản ghi, lưu SQLite và hiển thị lại sau khi khởi động ứng dụng.
- Thêm bộ lọc danh sách có trạng thái rỗng và nút xóa bộ lọc.
- Thêm panel chi tiết có thể mở/đóng, giữ đúng trạng thái và hoạt động ở tablet lẫn điện thoại.
- Thêm theme selector và lưu lựa chọn sau khi đóng/mở lại ứng dụng.

Không coi những phần sau là tính năng hoàn chỉnh:

- Button chỉ có animation nhưng chưa thực hiện nghiệp vụ.
- Form chỉ kiểm tra được trường hợp hợp lệ, không báo lỗi đầu vào.
- UI dùng dữ liệu mock nhưng được giới thiệu như dữ liệu thật.
- Nút Save hiển thị thành công trước khi database xác nhận ghi thành công.
- Màn hình mới chưa có loading/error/empty state.
- Tính năng chỉ chạy trên emulator nhưng chưa xác minh trên thiết bị mục tiêu khi tính năng phụ thuộc phần cứng hoặc Android API.

### 2.2. Chu trình bắt buộc

```text
Đọc repository + tri thức lỗi
             |
             v
Xác nhận mục tiêu + tiêu chí chấp nhận
             |
             v
Kiểm tra baseline + thiết kế giải pháp
             |
             v
Triển khai lát tính năng nhỏ
             |
             v
Viết/cập nhật unit, widget, integration test
             |
             v
Format + Analyze + Test + Build
             |
             v
Review diff + kiểm tra hồi quy + xác minh UI
             |
             v
Cập nhật tài liệu/lỗi/tri thức dự án
             |
             v
Commit + push nhánh tính năng
             |
             v
Review/merge vào main khi đạt điều kiện
             |
             v
Tag/build bản tải về khi đạt Release Gate
```

Nếu bất kỳ Quality Gate nào thất bại, không được merge hoặc gắn tag phát hành. Sửa lỗi hoặc hoàn nguyên thay đổi trước khi tiếp tục.

### 2.3. Một mục tiêu mỗi thay đổi

- Một commit nên thể hiện một thay đổi logic có thể giải thích trong một câu.
- Tránh trộn tính năng mới, refactor diện rộng, nâng SDK, đổi theme và cập nhật package không liên quan trong cùng commit.
- Nếu cần refactor để hỗ trợ tính năng, tách refactor thành commit trước, chạy test và xác minh hành vi không đổi.
- Nếu thay đổi buộc phải đi cùng nhau vì phụ thuộc kỹ thuật, ghi rõ quan hệ trong commit/PR.

---

## 3. Kiến trúc và ranh giới trách nhiệm

### 3.1. Kiến trúc mặc định

Sử dụng kiến trúc phân lớp, hướng feature-first. Một cấu trúc tham khảo:

```text
lib/
  app/
    app.dart
    router/
    theme/
    di/
  core/
    errors/
    logging/
    utils/
    widgets/
  features/
    feature_name/
      data/
        datasources/
        dto/
        repositories/
      domain/
        entities/
        repositories/
        usecases/
      presentation/
        controllers/
        screens/
        widgets/
  shared/
    widgets/
    models/

test/
  core/
  features/
    feature_name/
      data/
      domain/
      presentation/
integration_test/
```

Không cần tạo đủ mọi thư mục cho một tính năng quá nhỏ. Chỉ thêm lớp khi có trách nhiệm thực sự. Tránh tạo abstraction rỗng hoặc hàng loạt use case chỉ gọi lại một dòng không tạo giá trị.

### 3.2. Trách nhiệm từng lớp

**Presentation (UI):**
- Hiển thị dữ liệu và trạng thái.
- Thu nhận thao tác người dùng.
- Gọi controller/view model/provider.
- Quản lý trạng thái cục bộ thuần UI như expanded/collapsed, focus hoặc animation khi phù hợp.
- Không chứa SQL, quy tắc nghiệp vụ hoặc gọi HTTP trực tiếp.

**Application / Controller / ViewModel:**
- Điều phối hành động của người dùng.
- Gọi use case hoặc repository.
- Quản lý trạng thái tải, thành công, lỗi.
- Không phụ thuộc trực tiếp vào widget cụ thể.

**Domain:**
- Chứa entity, value object, quy tắc nghiệp vụ và contract repository.
- Không import Flutter UI, plugin, SQLite hoặc lớp Android.
- Ưu tiên Dart thuần để kiểm thử nhanh.

**Data:**
- Thực hiện truy cập SQLite, file, API hoặc platform service.
- Chuyển đổi dữ liệu lưu trữ/network sang domain model.
- Chứa DAO, data source và implementation repository.

**Core:**
- Chỉ chứa thành phần thật sự dùng chung, ổn định và không thuộc riêng một feature.
- Không biến `core/` thành nơi chứa mọi file chưa biết đặt ở đâu.

### 3.3. Quy tắc phụ thuộc

- Presentation được phép phụ thuộc application/domain contract.
- Data được phép implement domain repository contract.
- Domain không phụ thuộc presentation hoặc data implementation.
- Không để một feature import sâu vào chi tiết nội bộ của feature khác nếu có thể thông qua public interface.
- Không tạo vòng phụ thuộc giữa feature.
- Dependency Injection phải tập trung và có thể thay thế implementation trong test.

### 3.4. Repository là nguồn dữ liệu chuẩn

- Một loại dữ liệu nghiệp vụ phải có một nguồn sự thật rõ ràng.
- UI không tự đọc database rồi tự ghép dữ liệu với API.
- Repository quyết định chiến lược cache, đồng bộ, retry, mapping và xử lý lỗi.
- Quy định rõ dữ liệu nào local-first, remote-first hoặc chỉ cache.
- Không để nhiều màn hình có các bản sao logic lưu/đọc khác nhau cho cùng một entity.

### 3.5. State management

Nếu dự án chọn Riverpod như blueprint, phải:

- Chốt một kiểu provider và quy ước đặt tên nhất quán.
- Đặt logic bất đồng bộ trong provider/notifier/controller thích hợp.
- Tách state của nghiệp vụ khỏi state tạm thời của widget.
- Tránh `ref.watch` toàn bộ state lớn nếu UI chỉ cần một trường nhỏ; dùng select khi có lợi ích đo được.
- Xử lý loading, data, error rõ ràng.
- Không dùng provider toàn cục không có lý do; tránh giữ dữ liệu nhạy cảm lâu hơn cần thiết.
- Test provider độc lập, cô lập state giữa các test và override dependency bằng fake/mock.

Không trộn nhiều state-management framework trong một dự án chỉ vì một package có ví dụ thuận tiện. Chỉ thay đổi framework khi có ADR và phân tích chi phí chuyển đổi.

---

## 4. Quy tắc Dart nâng cao

### 4.1. Kiểu dữ liệu và null safety

- Bật và giữ null safety.
- Khai báo kiểu tường minh ở API public, ranh giới module và nơi kiểu suy luận làm code khó đọc.
- Không dùng `dynamic` để né lỗi type. Chỉ dùng ở ranh giới dữ liệu không tin cậy và phải parse/validate ngay.
- Không dùng toán tử `!` như cách sửa lỗi nhanh. Phải giải thích và chứng minh invariant trước khi dùng.
- Ưu tiên model immutable, constructor rõ ràng và `copyWith` khi phù hợp.
- Không dùng `Map<String, dynamic>` làm domain model xuyên suốt ứng dụng.
- Parse JSON/DB vào DTO có schema rõ ràng, sau đó map sang domain model.

### 4.2. Naming và khả năng đọc

- Tuân theo Effective Dart và formatter chính thức.
- Class, enum, extension dùng `UpperCamelCase`.
- biến/hàm/field dùng `lowerCamelCase`.
- file dùng `snake_case.dart`.
- Tên phải diễn tả mục đích, tránh `data`, `manager`, `helper`, `common` nếu không chỉ rõ trách nhiệm.
- Boolean nên có tên diễn tả trạng thái như `isSaving`, `hasError`, `canDelete`.
- Một hàm nên làm một việc chính; nếu có nhiều nhánh nghiệp vụ, tách hàm có tên diễn đạt ý nghĩa.
- Comment giải thích lý do hoặc ràng buộc khó thấy, không lặp lại code.

### 4.3. Immutability và side effects

- Ưu tiên `final` cho biến không cần gán lại.
- Dùng `const` cho widget/value khi có thể.
- Không sửa trực tiếp collection đang được UI/provider dùng chung nếu điều đó làm mất khả năng phát hiện state change.
- Trả về collection không thể sửa hoặc bản sao khi cần bảo vệ invariant.
- Side effect như ghi DB, gọi API, ghi file phải nằm trong lớp có trách nhiệm và có thể kiểm thử.

### 4.4. Async, Future và Stream

- Không gọi `async` mà không `await` khi cần biết kết quả hoặc xử lý lỗi.
- Không bỏ qua Future quan trọng bằng `unawaited` trừ khi side effect độc lập và lỗi đã có cách xử lý.
- Có timeout hợp lý cho network/platform operation có khả năng treo.
- Không chạy tác vụ CPU nặng đồng bộ trên UI isolate. Cân nhắc `Isolate.run`/isolate phù hợp cho parse lớn, mã hóa hoặc xử lý ảnh nặng; đo trước khi tối ưu.
- Không tạo Stream subscription mà không hủy đúng vòng đời.
- Xử lý lỗi tại ranh giới nơi có đủ ngữ cảnh để quyết định retry, báo người dùng hoặc ghi log.
- Không catch exception rồi bỏ qua. Nếu có thể tiếp tục, phải log có ngữ cảnh và đưa ra trạng thái rõ ràng.
- Không giữ `BuildContext` qua một async gap rồi sử dụng tùy tiện. Sau `await`, kiểm tra `mounted`/`context.mounted` theo đúng API và phạm vi State.
- Hủy timer, animation controller, focus node, text controller, stream subscription và notifier khi không còn dùng.

### 4.5. Exception và error model

- Phân biệt lỗi validation, lỗi nghiệp vụ, lỗi database, lỗi network, lỗi quyền và lỗi platform.
- Không hiển thị stack trace hoặc exception kỹ thuật thô cho người dùng.
- Chuyển lỗi kỹ thuật thành thông báo phù hợp, có hành động tiếp theo khi có thể.
- Giữ nguyên nguyên nhân gốc (`cause`/stack trace) trong logging nội bộ an toàn.
- Không dùng exception làm luồng điều khiển thông thường nếu có thể biểu diễn bằng result/state rõ ràng.

### 4.6. Code generation

- Chỉ commit file generated nếu convention/package của dự án yêu cầu.
- Không sửa tay file generated. Sửa schema/annotation/source rồi chạy generator.
- Ghi rõ lệnh sinh code trong README hoặc CONTRIBUTING.
- Kiểm tra diff generated file sau khi generator chạy; không chấp nhận thay đổi lan rộng không liên quan.
- Không chạy nhiều generator với phiên bản lệch nhau.

---

## 5. Quy tắc Flutter Widget và UI

### 5.1. Build method

- `build()` phải thuần trình bày và có thể được gọi nhiều lần.
- Không gọi insert/update/delete database trong `build()`.
- Không gọi API, tạo subscription hoặc khởi chạy tác vụ có side effect trong `build()`.
- Không tạo controller/timer/animation controller mỗi lần build.
- Không thực hiện sort/filter nặng trên danh sách lớn trong build; đưa vào provider/controller hoặc isolate nếu thực sự nặng.
- Tách widget nhỏ theo trách nhiệm và điểm thay đổi state; tránh một screen vài trăm dòng quản lý mọi phần.
- Dùng `const` constructor khi có thể.

### 5.2. State lifecycle

- Chọn đúng giữa state local (`StatefulWidget`), provider và persisted state.
- Trạng thái không cần tồn tại sau khi rời màn hình không nên ghi xuống database.
- Trạng thái cần tồn tại sau khi khởi động lại phải được lưu bền vững.
- Xác định rõ khi nào provider/widget được tạo, refresh, invalidate và dispose.
- Không giữ `BuildContext`, widget hoặc controller trong singleton lâu dài.

### 5.3. Responsive và adaptive

Thiết kế theo constraint thực tế, không dựa vào tên thiết bị.

- Dùng `LayoutBuilder`/constraints khi cấu trúc cần thích ứng theo vùng hiển thị.
- Dùng `MediaQuery` cho kích thước màn hình, text scale, orientation và platform insets ở cấp phù hợp.
- Không hard-code một layout duy nhất cho điện thoại và tablet.
- Định nghĩa breakpoint trong một nơi chung, có giải thích và test.
- Tablet landscape có thể dùng sidebar cố định + nội dung + detail panel.
- Tablet portrait có thể ẩn/thu gọn panel phụ hoặc chuyển sang route/detail overlay.
- Điện thoại ưu tiên một cột, drawer/bottom navigation tùy cấu trúc, panel dạng bottom sheet hoặc route.
- Không ép khóa orientation nếu không có lý do sản phẩm.
- Dùng `SafeArea` và xử lý system bar, cutout, gesture inset và keyboard.
- Form phải có thể cuộn khi keyboard mở; nút hành động quan trọng không bị keyboard che.
- Kiểm thử màn hình hẹp, rộng, landscape, text scaling lớn và font fallback.
- Không dùng `Expanded`/`Flexible` trong vị trí không có `Flex` parent.
- Tránh nested scroll phức tạp nếu không có yêu cầu rõ ràng; cân nhắc `CustomScrollView`/slivers.

### 5.4. Mật độ giao diện và không gian

- Dùng spacing scale thống nhất; ưu tiên compact nhưng không làm giảm vùng chạm.
- Margin/padding phải phân tách nhóm nội dung, không tạo khoảng trắng dư thừa.
- Không thu nhỏ vùng chạm chỉ để nhét thêm nội dung; tuân theo accessibility/platform target size.
- Giới hạn chiều rộng nội dung form/đọc dài trên tablet để tránh dòng quá dài.
- Table/list lớn phải có scroll, lazy rendering, pagination hoặc virtualized approach phù hợp.
- Giữ header/action quan trọng dễ tiếp cận; tránh toolbar chiếm quá nhiều chiều cao.

### 5.5. Animation và tương tác

- Mỗi animation phải có mục đích: phản hồi click, chỉ trạng thái, hướng sự chú ý hoặc giúp hiểu quan hệ không gian.
- Dùng implicit animation cho thay đổi đơn giản; explicit controller khi cần điều khiển vòng đời/timing.
- Không chạy animation vô hạn nếu không có nhu cầu.
- Không lồng nhiều animation làm người dùng chờ.
- Không làm nội dung layout nhảy mạnh khi mở/đóng sidebar hoặc panel.
- Bảo đảm thao tác có thể hoàn tất bằng accessibility action và không phụ thuộc animation.
- Tôn trọng reduce-motion/disable animations khi hệ thống hoặc ứng dụng cung cấp lựa chọn đó.
- Tránh blur, shadow, opacity layer và clip nặng trên nhiều phần tử cùng lúc; profile trên thiết bị thật.
- Không dùng animation để che độ trễ database/API. Dùng loading/progress state trung thực.

### 5.6. Accessibility và localization

- Dùng semantics/tooltip/label phù hợp cho icon-only buttons.
- Hỗ trợ text scaling, contrast và focus order.
- Không truyền tải trạng thái chỉ bằng màu; bổ sung icon/label.
- Không chặn thao tác bàn phím/assistive technology trên tablet và thiết bị có phụ kiện.
- Không hard-code chuỗi hiển thị ở nhiều file; dùng localization từ đầu nếu dự án có khả năng đa ngôn ngữ.
- Định dạng ngày, số, tiền tệ theo locale/time zone; lưu timestamp có quy tắc nhất quán.

---

## 6. Quản lý state, navigation và panel

### 6.1. Tách state theo phạm vi

Phân biệt tối thiểu:

- **Ephemeral UI state:** dropdown đang mở, item hover/focus, panel đang expanded.
- **Screen state:** bộ lọc, sort, tab, trang hiện tại.
- **Application state:** user session, theme, cấu hình dùng chung.
- **Persistent domain state:** dữ liệu nghiệp vụ cần lưu SQLite/file/remote.

Không ghi mọi state xuống database. Không giữ dữ liệu nghiệp vụ quan trọng chỉ trong widget state.

### 6.2. Navigation

- Chọn một giải pháp routing nhất quán, hỗ trợ deep link nếu sản phẩm cần.
- Khai báo route/name rõ ràng; không rải đường dẫn string tùy tiện.
- Xử lý back button Android, back gesture và nested navigation có chủ đích.
- Route cần tham số phải validate đầu vào.
- Khi xóa/sửa dữ liệu đang mở ở detail route, cập nhật hoặc điều hướng về trạng thái hợp lệ.
- Không tự tạo nhiều Navigator lồng nhau nếu không có yêu cầu về tab stack.

### 6.3. Sidebar và detail panel

- Một nguồn state có thẩm quyền cho mục đang chọn.
- Mở/đóng sidebar/panel không được làm mất dữ liệu form chưa lưu.
- Nếu user thay đổi màn hình khi có unsaved changes, đưa ra confirm/discard/save phù hợp.
- Kích thước sidebar/panel cần có min/max và khả năng thích ứng.
- Khi breakpoint đổi do resize, không để panel ở trạng thái không thể truy cập.
- Back button đóng overlay/panel theo đúng thứ tự điều hướng.

---

## 7. SQLite, Drift và toàn vẹn dữ liệu

Phần này bổ sung các quy tắc vận hành cho hướng lưu trữ SQLite/Drift trong blueprint.

### 7.1. Quy tắc schema

- Mỗi bảng cần mục đích và khóa chính rõ ràng.
- Khai báo foreign key và quy tắc delete/update có chủ ý.
- Dùng unique constraint/index khi có invariant nghiệp vụ.
- Index các cột thường xuyên dùng để tìm kiếm, lọc, join hoặc sort; không tạo index tràn lan.
- Lưu thời gian theo định dạng thống nhất, ưu tiên UTC ở tầng lưu trữ và chuyển sang local time khi hiển thị.
- Tránh lưu JSON blob cho dữ liệu có quan hệ/filter cần truy vấn nếu có thể thiết kế schema quan hệ hợp lý.
- Không dựa vào thứ tự trả về của SQL nếu không có `ORDER BY`.

### 7.2. Transaction và thao tác đồng thời

- Dùng transaction cho nhóm thao tác phải thành công/thất bại cùng nhau.
- Không cập nhật hai bảng liên quan bằng nhiều lệnh rời rạc không có transaction.
- Quy định rõ xử lý xung đột ghi, duplicate và retry.
- Không chạy nhiều kết nối ghi tùy tiện mà chưa đánh giá concurrency.
- Không giữ transaction mở trong lúc đợi thao tác UI hoặc network.
- Cân nhắc WAL/busy timeout theo workload; chỉ cấu hình sau khi hiểu yêu cầu và kiểm tra trên thiết bị.

### 7.3. Migration

Mọi thay đổi schema sau khi đã có dữ liệu người dùng đều cần migration.

- Tăng schema version có kiểm soát.
- Viết migration từ phiên bản cũ sang mới; không chỉ kiểm tra cài mới.
- Test migration trên database được tạo từ từng schema version được hỗ trợ.
- Migration phải giữ dữ liệu hợp lệ.
- Không xóa cột/bảng hoặc thay đổi ý nghĩa dữ liệu mà không có kế hoạch chuyển đổi.
- Có chiến lược backup/rollback hoặc phục hồi khi migration thất bại.
- Không coi xóa app/reinstall là phương án test migration.

### 7.4. Query và UI

- UI không gọi DAO trực tiếp.
- Sử dụng query có parameter binding; không ghép SQL từ chuỗi user nhập.
- Paginate/lazy load khi tập dữ liệu có thể tăng lớn.
- Không tải toàn bộ bảng vào bộ nhớ chỉ để hiển thị vài chục hàng.
- Search phải có debounce nếu mỗi ký tự gây query tốn kém; không debounce thao tác cần phản hồi tức thời vô điều kiện.
- Kiểm tra query plan/index khi query chậm, không đoán.

### 7.5. Backup/export/import

- Quy định dữ liệu nào được backup và dữ liệu nào không.
- Export nên có schema/version metadata và định dạng có thể phục hồi.
- Import phải validate, giới hạn kích thước và dùng transaction.
- Không ghi đè database hiện có trước khi xác nhận file import hợp lệ.
- Cân nhắc backup có mã hóa khi dữ liệu nhạy cảm.
- Kiểm thử restore; backup chưa kiểm tra restore chưa được xem là backup đáng tin cậy.

---

## 8. Android platform, permission và bảo mật

### 8.1. Quyền Android tối thiểu

- Chỉ khai báo permission khi tính năng thực sự cần.
- Không yêu cầu nhiều permission ngay lúc app mở nếu chưa cần.
- Giải thích lợi ích trước khi yêu cầu permission nhạy cảm.
- Xử lý denied, permanently denied, restricted và user revoke sau đó.
- Không giả định permission đã cấp chỉ vì lần trước thành công.
- Kiểm tra Android version/API behavior và cập nhật theo chính sách target SDK tại thời điểm phát hành.

### 8.2. Lưu trữ bí mật

- Không lưu password, refresh token, API key, private key hoặc secret trong SharedPreferences/plain text.
- Dùng Android Keystore thông qua giải pháp secure storage phù hợp cho khóa/secret nhỏ.
- SQLite không tự động được xem là encrypted. Nếu dữ liệu nhạy cảm cần encryption at rest, phải có threat model và giải pháp đã được kiểm tra.
- Không tự viết thuật toán mã hóa.
- Không ghi token, password, dữ liệu cá nhân hoặc nội dung database vào log/crash report.

### 8.3. Network security

- HTTPS/TLS cho dữ liệu truyền qua mạng.
- Không bật cleartext traffic toàn ứng dụng để xử lý một endpoint test.
- Không bỏ qua certificate validation trong production.
- Không hard-code API secret trong Dart code hoặc asset.
- Validate dữ liệu server như dữ liệu không tin cậy.
- Thiết kế timeout, retry/backoff và offline error phù hợp; không retry vô hạn.
- Nếu có certificate pinning, phải có chiến lược rotation/recovery và hiểu rủi ro khóa người dùng khỏi dịch vụ.

### 8.4. Android native configuration

- Chỉ sửa manifest/Gradle/Kotlin khi tính năng hoặc plugin cần.
- Đọc cấu hình hiện tại trước khi sửa; không ghi đè toàn bộ file build bằng một snippet lấy từ phiên bản khác.
- Tương thích Kotlin, Gradle, Android Gradle Plugin, JDK và compile/target SDK phải được kiểm tra cùng nhau.
- Không nâng riêng một thành phần lên phiên bản mới mà bỏ qua ma trận tương thích.
- Ghi lại thay đổi native trong tài liệu dự án.
- Plugin cần platform setup phải theo đúng tài liệu của phiên bản package đang lock.

### 8.5. Background work và lifecycle

- Không giả định Android cho phép tác vụ chạy vô hạn trong background.
- Dùng cơ chế background work phù hợp với tính chất tác vụ và giới hạn hệ điều hành.
- Tác vụ định kỳ không được dùng cho nhu cầu cần thời gian thực tuyệt đối.
- Xử lý app process bị kill, app resume, permission bị thu hồi và network thay đổi.
- Không giữ wake lock hoặc foreground service nếu không có căn cứ sản phẩm/pháp lý rõ ràng.

---

## 9. Dependency và quản lý phiên bản

### 9.1. Nguyên tắc chọn package

Trước khi thêm package phải đánh giá:

- Có thật sự cần package hay Flutter SDK đã có API phù hợp?
- Package có hỗ trợ Flutter/Dart stable và Android version cần dùng không?
- Tần suất cập nhật, lịch sử release, issue tồn đọng và khả năng bảo trì.
- Mức độ phổ biến, chất lượng tài liệu, license và độ phụ thuộc transitive.
- Quyền Android/package yêu cầu có vượt mức tính năng cần không?
- Có package thay thế chính thức hoặc ít rủi ro hơn không?
- Cách test, migration và rollback khi package bị ngừng phát triển.

Không chọn package chỉ vì nhiều sao GitHub hoặc vì có demo UI đẹp.

### 9.2. Lockfile và cập nhật

- Ứng dụng Flutter phải commit `pubspec.lock` để giữ dependency versions nhất quán giữa máy phát triển và CI.
- `pubspec.yaml` khai báo constraint phù hợp; lockfile ghi phiên bản thực tế đã resolve.
- Không xóa `pubspec.lock` để “sửa lỗi package” một cách tùy tiện.
- Không dùng `dependency_overrides` lâu dài để ép một dependency chưa tương thích.
- Chạy `flutter pub outdated` để đánh giá cập nhật; không mặc định cập nhật tất cả.
- Nâng một nhóm dependency liên quan trong thay đổi riêng, đọc changelog/breaking changes và chạy đầy đủ kiểm thử.
- Git dependency phải pin ref/tag/commit cụ thể; tránh phụ thuộc branch thay đổi liên tục trong production.

### 9.3. Quy trình cập nhật dependency

1. Ghi lý do cập nhật và lợi ích.
2. Kiểm tra phiên bản hiện tại và phiên bản mục tiêu.
3. Đọc changelog/migration guide.
4. Kiểm tra tương thích Flutter/Dart/Android/Gradle.
5. Tạo branch riêng.
6. Cập nhật package có phạm vi nhỏ.
7. Regenerate code nếu cần.
8. Chạy analyze, test, build và test thiết bị liên quan.
9. Kiểm tra diff của lockfile và dependency tree.
10. Commit riêng; ghi lại vấn đề phát sinh và cách tránh.

---

## 10. Testing strategy và tiêu chuẩn xác minh

### 10.1. Test pyramid

**Unit test:**
- Domain logic, validator, mapper, use case, repository behavior.
- Boundary values, empty/null/invalid values và lỗi.
- Không cần Flutter binding nếu logic là Dart thuần.

**Widget test:**
- Render UI, tương tác button/form/dropdown/sidebar/panel.
- Loading, empty, success và error state.
- Validation và accessibility label cơ bản.
- Responsive ở các constraint quan trọng.

**Integration test:**
- Luồng người dùng xuyên màn hình và database.
- Tạo/sửa/xóa rồi khởi động lại và xác nhận dữ liệu còn.
- Navigation/back behavior.
- Permission/platform flow khi có thể kiểm thử trên thiết bị/emulator.

**Manual device test:**
- Kiểm tra thao tác cảm ứng, keyboard, system bars, animation và layout trên thiết bị mục tiêu.
- Dùng khi có phần cứng/permission/native behavior không được mô phỏng đủ trong widget test.

### 10.2. Trường hợp test bắt buộc cho tính năng dữ liệu

- Dữ liệu hợp lệ.
- Dữ liệu rỗng.
- Dữ liệu quá dài.
- Ký tự Unicode/emoji khi có text input.
- Trùng khóa/duplicate.
- Database lỗi hoặc không thể mở.
- Thao tác bị hủy giữa chừng.
- Nhiều thao tác liên tiếp.
- Khởi động lại app.
- Migration từ schema cũ.

### 10.3. Ma trận giao diện

Ít nhất xác minh các constraint đại diện:

| Nhóm | Ví dụ kích thước/điều kiện | Điều cần kiểm tra |
|---|---|---|
| Điện thoại hẹp | 320–360 logical px | Không overflow, form còn dùng được |
| Điện thoại phổ biến | 375–430 logical px | Mật độ, button, navigation |
| Tablet portrait | khoảng 600–800 logical px | Sidebar/panel chuyển trạng thái đúng |
| Tablet landscape | khoảng 800–1200 logical px | Tận dụng không gian, không kéo dòng quá dài |
| Tablet lớn | trên 1200 logical px | Giới hạn chiều rộng hợp lý, multi-panel |
| Accessibility | text scale lớn | Không cắt nội dung/ẩn action quan trọng |
| Keyboard | keyboard mở | Form cuộn được, nút Save không bị che |

Breakpoint trong bảng chỉ là điểm kiểm thử tham khảo; breakpoint thực tế phải dựa trên layout và constraint của app, không sao chép máy móc.

### 10.4. Test database và migration

- Dùng database tạm trong test, không dựa vào dữ liệu người dùng thật.
- Test schema mới và migration từ schema cũ.
- Kiểm tra unique/foreign key/transaction rollback.
- Đóng database/subscription đúng cách sau test.
- Không để test phụ thuộc thứ tự chạy hoặc state từ test trước.

### 10.5. Golden test

Dùng khi UI có design system ổn định và việc so sánh pixel có giá trị. Không dùng golden làm tiêu chuẩn duy nhất vì font, renderer, OS và device pixel ratio có thể tạo khác biệt hợp lệ. Cập nhật golden phải được review như thay đổi thiết kế, không bấm update hàng loạt để làm test xanh.

---

## 11. Performance và độ ổn định

### 11.1. Đo trước khi tối ưu

- Không gọi code là “mượt 120 FPS” nếu chưa đo trên thiết bị mục tiêu.
- Không đánh giá hiệu năng rendering bằng Debug mode.
- Dùng Profile mode và Flutter DevTools Performance view để tìm frame jank.
- Đo startup, scroll, animation, database query và memory khi có nghi ngờ.
- Ghi thiết bị, OS, build mode và kịch bản đo để kết quả có thể so sánh.

### 11.2. Quy tắc rendering

- Dùng builder/lazy list cho danh sách lớn.
- Không dựng toàn bộ dataset nếu chỉ hiển thị một phần.
- Hạn chế rebuild phạm vi lớn khi chỉ một thành phần thay đổi.
- Dùng `const`/widget extraction/select theo lợi ích thực tế.
- Tránh layout/paint đắt tiền không cần thiết.
- Không thêm cache phức tạp nếu chưa đo thấy bottleneck.
- Tránh ảnh kích thước quá lớn không cần thiết; chọn decode size và cache hợp lý.

### 11.3. Memory và lifecycle

- Dispose controller/subscription.
- Không giữ list/result khổng lồ trong provider global nếu không cần.
- Kiểm tra memory khi mở/đóng screen nhiều lần.
- Xử lý image/file/stream lớn theo luồng phù hợp, không đọc toàn bộ vào RAM vô điều kiện.
- Theo dõi crash, ANR và lỗi khởi động ở bản release.

### 11.4. Giới hạn chất lượng

Mỗi dự án cần xác định performance budget thực tế sau khi có thiết bị mục tiêu. Không hứa hẹn số liệu FPS, thời gian khởi động hoặc RAM khi chưa có phép đo.

---

## 12. Logging, diagnostics và xử lý lỗi

### 12.1. Logging

- Có logger tập trung và mức log phù hợp (debug/info/warning/error).
- Log phải có ngữ cảnh: feature, operation, entity ID không nhạy cảm, error category, correlation ID nếu có.
- Không log secret, token, mật khẩu, dữ liệu cá nhân hoặc nội dung nhạy cảm.
- Không dùng `print()` rải rác trong production.
- Có thể giảm/ẩn log debug ở release.
- Stack trace được giữ ở kênh debug/crash nội bộ an toàn, không hiển thị cho người dùng cuối.

### 12.2. UI error state

- Thông báo lỗi nói rõ việc gì không thực hiện được.
- Cung cấp retry hoặc hành động tiếp theo khi hợp lý.
- Không báo “thành công” trước khi thao tác lưu/đồng bộ được xác nhận.
- Không xóa dữ liệu đang hiển thị chỉ vì một lần refresh thất bại nếu có thể giữ bản cache an toàn.
- Nếu dữ liệu stale, thể hiện thời điểm cập nhật và trạng thái kết nối khi cần.

### 12.3. Crash và incident

Khi có crash:

1. Thu thập stack trace đầy đủ, build number, OS/API, thiết bị và bước tái hiện.
2. Xác định crash có từ startup, navigation, resume, database hoặc thao tác cụ thể.
3. Reproduce ở đúng commit/branch nếu có thể.
4. Phân loại root cause, không chỉ sửa dòng crash cuối cùng.
5. Thêm regression test hoặc bước kiểm tra có thể lặp lại.
6. Cập nhật issue log và tri thức dự án.
7. Phát hành hotfix riêng nếu nhánh ổn định bị ảnh hưởng.

---

## 13. Quy trình review và chống tái diễn lỗi

### 13.1. Review trước khi sửa

- [ ] Đã đọc file liên quan và caller/callee.
- [ ] Đã hiểu luồng dữ liệu từ UI đến repository/database.
- [ ] Đã kiểm tra lỗi/ADR tương tự.
- [ ] Đã xác định baseline và thay đổi chưa commit.
- [ ] Đã xác định hành vi cũ nào không được phá vỡ.
- [ ] Đã có tiêu chí chấp nhận và test plan.
- [ ] Đã xem tài liệu API của đúng phiên bản Flutter/package đang dùng.

### 13.2. Review sau khi sửa

- [ ] Diff chỉ chứa các file liên quan.
- [ ] Không có code debug, mock data, TODO giả hoặc dead code ngoài dự kiến.
- [ ] Không có hard-coded secret/path/device-specific value.
- [ ] Không làm hỏng null safety, type safety hoặc error handling.
- [ ] Không thêm dependency không cần thiết.
- [ ] Không sửa generated file bằng tay.
- [ ] Không tạo side effect trong `build()`.
- [ ] Đã xử lý loading/empty/error/success.
- [ ] Đã kiểm tra tablet/phone và text scale theo phạm vi tính năng.
- [ ] Đã chạy test liên quan và toàn bộ gate cần thiết.
- [ ] Đã cập nhật tài liệu/issue log/tri thức dự án khi có bài học mới.

### 13.3. Nguyên tắc sửa lỗi

- Một lần chỉ thay đổi đủ để kiểm chứng giả thuyết nguyên nhân.
- Không thay đổi đồng thời nhiều lớp nếu chưa biết lớp nào gây lỗi.
- Không dùng find/replace hàng loạt với mẫu rộng khi chưa xem toàn bộ kết quả dự kiến.
- Không chép đè file hoàn chỉnh từ phiên bản khác lên repository mà không so sánh và giữ các thay đổi riêng của dự án.
- Không tự nâng phiên bản package để xử lý một lỗi chưa chứng minh liên quan đến package version.
- Không xóa test đang thất bại chỉ để pipeline xanh.
- Không vô hiệu hóa analyzer/lint hoặc nới lỏng test để che lỗi.
- Nếu phải tạo workaround, ghi rõ nguyên nhân, phạm vi ảnh hưởng, điều kiện loại bỏ và test phòng ngừa.

### 13.4. Bảng lỗi đã biết

Tạo và duy trì `docs/quality/known_issues.md` với cấu trúc:

| ID | Ngày | Khu vực | Triệu chứng | Root cause | Giải pháp đã xác minh | Regression test | Trạng thái |
|---|---|---|---|---|---|---|---|
| FLT-0001 | YYYY-MM-DD | UI/DB/Build | Mô tả ngắn | Nguyên nhân gốc | Cách sửa | Test/lệnh | Open/Fixed/Monitoring |

Mỗi lỗi đã sửa phải có thông tin đủ để người khác nhận ra và tránh tái diễn. Không ghi chung chung kiểu “lỗi Flutter” hoặc “đã fix”.

### 13.5. Bài học kỹ thuật

Tạo và duy trì `docs/quality/lessons_learned.md`. Một entry cần:

- Bối cảnh và phiên bản môi trường.
- Điều đã làm sai hoặc giả định sai.
- Tại sao cách cũ thất bại.
- Dấu hiệu nhận diện sớm.
- Quy tắc mới cần áp dụng.
- Test/checklist ngăn tái diễn.
- Link commit/issue/PR nếu có.

Chỉ đưa vào đây bài học có tính tái sử dụng; không biến file thành nhật ký chat dài.

### 13.6. Cập nhật trí nhớ dự án trong ChatGPT

Khi phát hiện lỗi mới hoặc một bài học quan trọng:

1. Tạo entry đầy đủ trong `known_issues.md` và/hoặc `lessons_learned.md` của repository.
2. Tóm tắt ngắn gọn bài học theo dạng **Triệu chứng → Nguyên nhân gốc → Quy tắc phòng ngừa → Test bắt buộc**.
3. Cập nhật Project Instructions/Project Knowledge hoặc trí nhớ dự án ChatGPT nếu tính năng lưu trữ tương ứng đang khả dụng.
4. Không lưu secret, token, thông tin cá nhân, dữ liệu người dùng hoặc log chứa dữ liệu nhạy cảm vào memory.
5. Sau khi cập nhật, khi bắt đầu tác vụ tương tự phải đọc lại bài học và áp dụng.
6. Nếu không thể cập nhật memory trong môi trường hiện tại, phải nói rõ và vẫn cập nhật repository khi có quyền truy cập; không tuyên bố memory đã được cập nhật khi chưa thực hiện.

**Thứ tự nguồn tri thức:** repository (`docs/quality/`) là bản ghi kỹ thuật có thể review/version-control; ChatGPT Project Memory là lớp nhắc nhớ hỗ trợ phiên làm việc, không thay thế bản ghi trong Git.

### 13.7. Chỉ đóng lỗi khi có bằng chứng

- `Fixed` chỉ khi đã sửa và có test/verification.
- `Monitoring` khi đã có giải pháp nhưng cần quan sát thêm trên thiết bị/bản release.
- `Open` khi chưa có nguyên nhân hoặc giải pháp đáng tin cậy.
- Nếu lỗi quay lại, tạo liên kết tới entry cũ và cập nhật root cause; không tạo một ghi chú mới tách rời khiến lịch sử bị mất.

---

## 14. Git workflow: commit và push sau mỗi tính năng nhỏ

### 14.1. Mục tiêu

Git phải phản ánh lịch sử phát triển theo các lát chức năng có ý nghĩa. Sau khi một tính năng nhỏ đã hoàn chỉnh và đạt Quality Gate:

- Tạo commit riêng.
- Push branch lên remote.
- Ghi lại kết quả kiểm tra.
- Chỉ merge vào nhánh ổn định khi đủ điều kiện.

**Push không đồng nghĩa với phát hành.** Push branch là lưu trữ/chia sẻ code; người dùng tải bản ổn định cần lấy từ một tag/release đã qua Release Gate.

### 14.2. Branch strategy

Mô hình mặc định:

```text
main                 Luôn ở trạng thái ổn định, build được
  |
  +-- feature/...    Một tính năng nhỏ
  +-- fix/...        Một bug fix
  +-- refactor/...   Một refactor có kiểm soát
  +-- chore/...      Tooling/dependency/docs
```

- Không code tính năng mới trực tiếp trên `main` trừ thay đổi tài liệu cực nhỏ đã được quy định.
- Mỗi feature/fix có branch riêng.
- Merge feature vào `main` sau khi review và Quality Gate xanh.
- Với repository cá nhân không có Pull Request, vẫn phải chạy checklist review và test trước merge local.
- Không push force lên branch dùng chung. Chỉ dùng `--force-with-lease` trong trường hợp đã hiểu lịch sử và được phép; tuyệt đối tránh `--force` tùy tiện.

### 14.3. Quy tắc commit

Dùng Conventional Commits hoặc convention đã chọn thống nhất:

```text
feat: add device detail panel
fix: preserve filter after returning from detail
refactor: isolate device repository mapping
perf: paginate large device list
test: cover database migration from v2
build: align Android Gradle configuration
docs: record tablet layout decisions
```

Commit message:

- Mô tả hành động, không ghi “update”, “fix bug”, “done”.
- Một commit không trộn mục tiêu không liên quan.
- Không commit file tạm, log, file build hoặc secret.
- Không commit code chưa format/analyze/test theo gate tương ứng.

### 14.4. Quy trình Git chuẩn bằng PowerShell

Ví dụ cho một tính năng:

```powershell
# 1. Kiểm tra trạng thái trước khi làm
git status --short --branch

# 2. Lấy thông tin mới nhất từ remote
git fetch origin

# 3. Tạo branch tính năng từ main đã cập nhật
git switch main
git pull --ff-only origin main
git switch -c feature/ten-tinh-nang

# 4. Sau khi code xong: kiểm tra chất lượng
dart format --output=none --set-exit-if-changed .
flutter analyze --fatal-infos
flutter test
flutter build apk --debug

# 5. Review diff và kiểm tra secret
git status --short
git diff --check
git diff --stat
git diff

# 6. Stage có chọn lọc, không mặc định add mọi thứ
git add lib/features/ten_tinh_nang test/features/ten_tinh_nang
# Thêm docs/ và file cấu hình liên quan nếu thực sự thuộc tính năng

git diff --cached --check
git diff --cached

# 7. Commit và push
git commit -m "feat: add ten tinh nang"
git push -u origin feature/ten-tinh-nang
```

Không chạy ví dụ nguyên xi nếu đường dẫn/branch khác dự án. Thay bằng file thực tế và kiểm tra `git status` trước mỗi thao tác có khả năng ảnh hưởng dữ liệu.

### 14.5. Merge vào main

Trước khi merge:

- [ ] Branch dựa trên `main` mới nhất hoặc đã được cập nhật an toàn.
- [ ] Tất cả test và build gate đều thành công.
- [ ] Diff đã được review.
- [ ] Tài liệu/known issue/lessons learned đã cập nhật.
- [ ] Không có secret hoặc file local-only.
- [ ] Không có migration phá hủy dữ liệu chưa được đánh giá.
- [ ] Có kế hoạch rollback nếu tính năng tác động đến dữ liệu hoặc luồng chính.

Sau merge:

- Kéo `main` mới nhất.
- Build lại từ chính commit merge.
- Xác nhận working tree sạch.
- Xóa branch khi đã hợp nhất và không còn cần thiết.

### 14.6. Luôn giữ main có thể phát hành

- `main` không chứa code dở dang hoặc tính năng chỉ hoạt động một nửa.
- Nếu cần phát triển nhiều commit nội bộ, giữ trên feature branch.
- Dùng feature flag/config nếu cần merge code đã hoàn thiện kỹ thuật nhưng chưa bật cho người dùng; chỉ khi flag có kiểm thử và không tạo đường code không ổn định.
- Nếu phát hiện main bị hỏng, ưu tiên revert/hotfix ngay; không tiếp tục xếp tính năng mới lên nền lỗi.
- Không xóa tag/rewrite lịch sử release đã phát hành.

---

## 15. Release, APK/AAB và bản tải về

### 15.1. Phân biệt các mốc

| Mốc | Ý nghĩa | Có nên cho người dùng tải? |
|---|---|---|
| Local development | Đang phát triển trên máy | Không |
| Feature branch push | Lưu code tính năng nhỏ đã qua gate riêng | Không mặc định |
| Main green | Tích hợp ổn định, build được | Có thể dùng nội bộ |
| Release candidate | Bản kiểm tra cuối, chưa cam kết ổn định | Chỉ tester |
| Stable release | Đã qua Release Gate, có version/tag và ghi chú | Có |

### 15.2. Release Gate

Trước khi đánh dấu một bản là stable:

- [ ] `flutter analyze --fatal-infos` thành công.
- [ ] `flutter test` thành công.
- [ ] Integration test quan trọng thành công.
- [ ] `flutter build appbundle --release` hoặc APK release thành công.
- [ ] Cài đặt và mở app trên thiết bị/emulator mục tiêu.
- [ ] Kiểm tra luồng quan trọng: startup, navigation, thao tác CRUD, database, theme và permission nếu liên quan.
- [ ] Kiểm tra migration và dữ liệu cũ nếu release có thay đổi schema.
- [ ] Xác minh version/build number.
- [ ] Xác minh ký release đúng key, không dùng debug key.
- [ ] Kiểm tra crash/log và nội dung release notes.
- [ ] Xác nhận không có secret trong artifact hoặc repository.

### 15.3. Versioning

- Dùng Semantic Versioning nếu phù hợp: `MAJOR.MINOR.PATCH`.
- `PATCH`: sửa lỗi tương thích, không thay đổi hợp đồng lớn.
- `MINOR`: tính năng mới tương thích ngược.
- `MAJOR`: thay đổi có breaking behavior/data/API.
- Tăng Android `versionCode` theo quy tắc đơn điệu; không tái sử dụng code đã phát hành.
- Ghi version và build number ở một nguồn có thẩm quyền.

### 15.4. Artifact tải về

- Dùng AAB cho phân phối qua Google Play khi phù hợp; APK cho sideload/test hoặc kênh phân phối cần APK.
- Không commit `build/` vào source repository.
- Đính kèm artifact vào Git Release hoặc kênh phân phối có kiểm soát, kèm checksum nếu cần.
- Release notes ghi tính năng, bug fix, yêu cầu nâng cấp, thay đổi dữ liệu và known issue.
- Không gắn tag `stable` cho bản chỉ mới build thành công mà chưa kiểm thử cài đặt/luồng chính.

### 15.5. Signing và bảo vệ key

- Keystore và file chứa password ký không được commit.
- Dùng secret manager/CI secrets hoặc file local được ignore.
- Giới hạn quyền truy cập và có backup key an toàn.
- Mất upload key/signing key có thể gây khó khăn nghiêm trọng khi cập nhật app; cần quy trình bảo quản và phục hồi.
- Không gửi keystore qua chat hoặc đính kèm vào issue công khai.

### 15.6. Rollback và hotfix

- Lưu artifact của các stable release đã phát hành.
- Khi có lỗi nghiêm trọng, xác định phiên bản bị ảnh hưởng và khả năng tái hiện.
- Tạo hotfix branch từ đúng tag/release bị ảnh hưởng nếu cần.
- Sửa tối thiểu, thêm regression test, chạy Release Gate.
- Không xóa dữ liệu người dùng để né migration lỗi.
- Ghi rõ giải pháp tạm thời và hành động người dùng cần làm trong release notes.

---

## 16. CI/CD và tự động hóa

### 16.1. CI tối thiểu

Mỗi Pull Request/merge request nên chạy:

```text
1. Checkout repository
2. Cài Flutter stable theo phiên bản dự án đã chốt
3. flutter pub get
4. dart format --output=none --set-exit-if-changed .
5. flutter analyze --fatal-infos
6. flutter test
7. flutter build apk --debug (hoặc build target phù hợp)
8. Lưu test/build log khi thất bại
```

- CI phải dùng cùng phiên bản Flutter/Dart đã ghi trong dự án.
- Cache chỉ để tăng tốc, không được là điều kiện để build đúng.
- Không đặt secret trực tiếp trong YAML hoặc log.
- Không để pipeline bỏ qua test/analyze mà không có lý do được ghi nhận.
- Release signing chỉ chạy ở workflow có quyền và secret phù hợp.

### 16.2. Branch protection

Khi nền tảng Git hỗ trợ:

- Yêu cầu CI xanh trước khi merge.
- Yêu cầu review nếu làm việc theo nhóm.
- Hạn chế force push và xóa nhánh chính.
- Không cho phép merge khi có conflict chưa giải quyết.

### 16.3. Không tự động phát hành mọi commit

Có thể tự động build/test mỗi commit hoặc PR. Không tự động gắn nhãn stable hoặc phát hành công khai khi chưa qua Release Gate và chưa xác nhận version/release notes.

---

## 17. Tài liệu hóa và quyết định kiến trúc

### 17.1. Bộ tài liệu tối thiểu

```text
docs/
  architecture/
    overview.md
    decisions/
      ADR-0001-state-management.md
      ADR-0002-local-database.md
  quality/
    known_issues.md
    lessons_learned.md
    release_checklist.md
  development/
    setup.md
    workflow.md
    testing.md
```

README cần có:

- Mục tiêu ứng dụng.
- Yêu cầu môi trường/SDK.
- Cách cài dependency và chạy ứng dụng.
- Cách chạy analyzer/test/build.
- Cách tạo code generated (nếu có).
- Cách cấu hình Android/local secrets an toàn.
- Link tới các tài liệu kỹ thuật quan trọng.

### 17.2. Architecture Decision Record (ADR)

Tạo ADR khi quyết định ảnh hưởng dài hạn như:

- State management.
- Routing/navigation.
- SQLite/Drift hoặc database khác.
- Cách đồng bộ dữ liệu offline/online.
- Encryption và backup.
- Package có ảnh hưởng rộng.
- Thay đổi cấu trúc module/layer.

Mẫu ADR:

```markdown
# ADR-XXXX: Tiêu đề

- Status: Proposed | Accepted | Superseded
- Date: YYYY-MM-DD

## Context
Vấn đề và ràng buộc.

## Decision
Quyết định đã chọn.

## Alternatives considered
Các lựa chọn đã cân nhắc.

## Consequences
Lợi ích, chi phí, rủi ro và ảnh hưởng migration.

## Validation
Test/đo lường dùng để xác minh.
```

### 17.3. Không để tài liệu lệch code

- Khi đổi lệnh build, dependency, schema hoặc kiến trúc, cập nhật tài liệu cùng commit.
- Xóa hướng dẫn cũ nếu nó không còn đúng; không để hai hướng dẫn mâu thuẫn.
- Ghi ngày kiểm tra link và phiên bản tham chiếu nếu nội dung dễ lỗi thời.

---

## 18. Định nghĩa hoàn thành (Definition of Done)

Một tính năng nhỏ chỉ được xem là hoàn chỉnh khi tất cả mục áp dụng đã đạt:

### Chức năng
- [ ] Đạt đúng mục tiêu người dùng và tiêu chí chấp nhận.
- [ ] Luồng chính hoạt động với dữ liệu thật hoặc nguồn dữ liệu đã xác định.
- [ ] Có validation và xử lý lỗi phù hợp.
- [ ] Loading/empty/error/success state được xử lý.
- [ ] Không làm hỏng các luồng hiện có.

### Kiến trúc và code
- [ ] Đúng ranh giới layer.
- [ ] Không có business logic/DB/network trong build method.
- [ ] Không tạo abstraction/dependency không cần thiết.
- [ ] Null safety/type safety và lifecycle được xử lý.
- [ ] Code đã format, analyzer không có lỗi theo mức gate.

### UI/UX
- [ ] Kiểm tra trạng thái click/disabled/loading.
- [ ] Responsive với các constraint có liên quan.
- [ ] Keyboard, SafeArea, back navigation và text scale được xem xét.
- [ ] Animation có mục đích, không cản trở thao tác.
- [ ] Nội dung chính/phụ có phân cấp rõ và không overflow.

### Dữ liệu và bảo mật
- [ ] CRUD/query/migration đúng nếu có.
- [ ] Transaction/validation/backup được xem xét nếu có.
- [ ] Không lộ secret hoặc dữ liệu nhạy cảm.
- [ ] Permission/network/storage tuân thủ nguyên tắc tối thiểu.

### Test và build
- [ ] Unit/widget/integration test phù hợp đã chạy.
- [ ] Không xóa hoặc vô hiệu hóa test để đạt trạng thái xanh.
- [ ] Android build mục tiêu thành công.
- [ ] Thiết bị/emulator được kiểm tra khi yêu cầu tính năng cần.

### Git và tri thức
- [ ] Diff đã được review.
- [ ] Không có file không liên quan hoặc secret.
- [ ] Known issue/lessons learned được cập nhật khi có bài học mới.
- [ ] Commit message có ý nghĩa.
- [ ] Đã push branch lên remote hoặc nêu rõ lý do chưa thể push.
- [ ] Chỉ merge vào main khi đủ gate.

---

## 19. Checklist nhanh trước mỗi lần push

Dùng checklist ngắn này sau khi một tính năng nhỏ hoàn chỉnh:

```text
[ ] Tôi đã đọc các lỗi/bài học cũ có liên quan.
[ ] Tôi đã hiểu và kiểm tra diff, không chỉ nhìn màn hình.
[ ] dart format đã đạt.
[ ] flutter analyze --fatal-infos đã đạt.
[ ] flutter test đã đạt.
[ ] Build Android phù hợp đã đạt.
[ ] Luồng chính và trạng thái lỗi/rỗng đã được xác minh.
[ ] Tablet/phone đã được kiểm tra nếu layout bị ảnh hưởng.
[ ] Không có secret, file tạm, log hoặc build output bị commit.
[ ] Tài liệu/lỗi/tri thức đã được cập nhật.
[ ] Commit riêng cho tính năng này đã tạo.
[ ] Push lên đúng branch/remote.
[ ] Chưa merge main nếu còn gate thất bại.
```

---

## 20. Mẫu báo cáo hoàn thành một lát tính năng

Sau mỗi lát tính năng, báo cáo theo mẫu này để người duyệt biết chính xác mức độ hoàn tất:

```markdown
## Feature: [Tên tính năng]

### Kết quả
- [Hành vi đã hoàn thiện]
- [Hành vi chưa nằm trong phạm vi]

### File/layer đã thay đổi
- `path/to/file.dart` — [lý do]

### Kiểm tra
- Format: PASS/FAIL
- Analyze: PASS/FAIL
- Unit/widget/integration tests: PASS/FAIL (số test nếu có)
- Android build: PASS/FAIL (debug/release)
- Thiết bị đã kiểm tra: [thiết bị/emulator hoặc chưa]

### Hồi quy và rủi ro
- [Luồng đã kiểm tra]
- [Known issue hoặc rủi ro còn lại]

### Tri thức dự án
- [Lỗi/bài học mới đã ghi hoặc Không phát sinh]
- [Đã cập nhật Project Memory hay chưa]

### Git
- Branch: [branch]
- Commit: [hash + message]
- Push: [remote/branch hoặc lý do chưa push]
- Merge/tag/release: [trạng thái]
```

Không được điền PASS nếu lệnh chưa chạy hoặc chưa thấy kết quả.

---

## 21. Hướng dẫn phối hợp với ChatGPT trong dự án

Khi giao một tác vụ Flutter/Dart, ChatGPT phải tuân thủ các quy tắc sau:

1. Đọc và áp dụng blueprint, engineering rules, repository docs và known issues đang có.
2. Nếu user đã upload source/ZIP, kiểm tra đúng bản mới nhất và xác định cấu trúc thật trước khi đưa hướng dẫn sửa.
3. Không tự suy đoán tên file, API, package version, method hoặc cấu trúc project. Kiểm tra code và tài liệu đúng phiên bản.
4. Trước khi đề xuất thay đổi, nêu ngắn gọn mục tiêu, phạm vi file, lý do và cách xác minh.
5. Khi sửa code, cung cấp file hoàn chỉnh hoặc patch chính xác theo yêu cầu; không bỏ mất logic hiện tại.
6. Không thay thế một file lớn chỉ để sửa một lỗi nhỏ nếu có thể patch an toàn.
7. Không lặp lại giải pháp đã từng gây lỗi. Nếu hoàn cảnh khác, giải thích vì sao cách xử lý cũ không còn áp dụng.
8. Sau mỗi lỗi mới, ghi nguyên nhân gốc, quy tắc phòng ngừa và regression test vào tài liệu dự án; cập nhật ChatGPT Project Memory khi khả dụng.
9. Sau mỗi lát tính năng hoàn chỉnh, chạy quality gate, review diff, tạo commit và push branch nếu có quyền truy cập Git/remote.
10. Phân biệt chính xác: code đã viết, test đã chạy, build đã thành công, commit đã tạo, push đã hoàn tất và release đã phát hành. Không gộp các trạng thái này thành một lời khẳng định chung.
11. Nếu không có quyền truy cập repository/terminal/remote, cung cấp chính xác các lệnh và checklist để người dùng thực hiện; nói rõ phần nào chưa được thực thi.
12. Ưu tiên giải pháp ổn định, dễ bảo trì và có kiểm chứng thực tế hơn giải pháp mới nhất nhưng chưa trưởng thành.

### Prompt quy tắc có thể đặt vào ChatGPT Project Instructions

```text
Bạn là kỹ sư Flutter/Dart phụ trách dự án này. Trước khi code, hãy đọc README,
blueprint, engineering rules, ADR, known_issues và lessons_learned. Không sửa theo
phỏng đoán; kiểm tra source, SDK/package version và baseline trước. Chia việc thành
các lát tính năng nhỏ có tiêu chí chấp nhận rõ. Giữ đúng kiến trúc và ranh giới layer;
không đặt nghiệp vụ/DB/network trong build(). Sau mỗi thay đổi, chạy format, analyze,
test và Android build phù hợp; review diff, kiểm tra hồi quy, responsive và dữ liệu.
Không merge code lỗi vào main. Sau mỗi tính năng nhỏ hoàn chỉnh, tạo commit riêng và
push branch lên Git remote khi có quyền. Main luôn phải build được và có thể phát hành.
Chỉ tạo bản tải về stable sau Release Gate. Khi phát hiện lỗi mới, ghi root cause,
phòng ngừa và regression test vào docs/quality/; cập nhật Project Memory khi khả dụng.
Không lặp lại lỗi đã ghi nhận. Không tuyên bố đã test/build/commit/push/release nếu
chưa thực hiện và xác minh. Ưu tiên phiên bản ổn định, an toàn, bảo trì lâu dài.
```

---

## 22. Nguồn tham khảo chính thức

Tài liệu quy chuẩn này dựa trên các hướng dẫn và nguyên tắc chính thức dưới đây. Cần kiểm tra lại tài liệu khi nâng Flutter/Dart/Android SDK hoặc thay đổi package lớn.

### Flutter

- [Flutter app architecture guide](https://docs.flutter.dev/app-architecture/guide)
- [Flutter architecture overview](https://docs.flutter.dev/app-architecture)
- [Testing Flutter apps](https://docs.flutter.dev/testing/overview)
- [Integration testing concepts](https://docs.flutter.dev/cookbook/testing/integration/introduction)
- [Performance best practices](https://docs.flutter.dev/perf/best-practices)
- [Improving rendering performance](https://docs.flutter.dev/perf/rendering-performance)
- [DevTools Performance view](https://docs.flutter.dev/tools/devtools/performance)
- [Flutter dependency management](https://docs.flutter.dev/packages-and-plugins/dependency-management)
- [Using packages](https://docs.flutter.dev/packages-and-plugins/using-packages)
- [Build and release an Android app](https://docs.flutter.dev/deployment/android)

### Dart

- [Effective Dart](https://dart.dev/effective-dart)
- [Dart documentation](https://dart.dev/guides)

### State management

- [Riverpod — testing providers](https://riverpod.dev/docs/how_to/testing)

### Nguyên tắc đọc nguồn

- Ưu tiên tài liệu chính thức và tài liệu của đúng phiên bản dependency đang sử dụng.
- Không lấy một đoạn code từ tài liệu cũ rồi áp dụng vào dự án mới mà không kiểm tra API.
- Nếu tài liệu chính thức và package hiện tại có khác biệt, kiểm tra version/changelog và ghi rõ lựa chọn.
- Không coi tài liệu này là danh sách phiên bản package cố định; phiên bản phải được chốt tại thời điểm triển khai và khóa bằng dependency lockfile.

---

## 23. Kết luận: tiêu chuẩn kỹ thuật của dự án

Một ứng dụng Flutter tốt không chỉ là ứng dụng có giao diện đẹp hoặc build được một lần. Dự án phải có kiến trúc rõ ràng, dữ liệu an toàn, UI thích ứng, code dễ kiểm thử, quy trình Git có kiểm soát và lịch sử lỗi đủ tốt để người phát triển sau không lặp lại cùng một sai lầm.

**Quy tắc vận hành cuối cùng:** hoàn thành một lát tính năng nhỏ → kiểm thử và review → cập nhật tri thức → commit/push → chỉ merge khi nhánh ổn định vẫn xanh → chỉ phát hành bản tải về sau Release Gate. Đây là cách giữ tốc độ phát triển mà không đánh đổi độ tin cậy của phiên bản người dùng đang sử dụng.
