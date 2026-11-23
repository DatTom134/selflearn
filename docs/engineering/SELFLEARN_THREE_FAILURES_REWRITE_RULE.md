# Quy tắc tái triển khai khi lỗi lặp lại sau 3 lần sửa

**Mã quy tắc:** SEL-ENG-REWRITE-001\
**Phạm vi:** Toàn bộ mã nguồn SelfLearn, bao gồm Flutter/Dart, Android,
dữ liệu, điều hướng, giao diện, state management, repository và test.\
**Mức độ:** Bắt buộc đối với mọi coding agent và người phát triển.

## 1. Mục đích

Ngăn việc vá lỗi lặp đi lặp lại ở cùng một khu vực mà không xử lý nguyên
nhân gốc. Khi một lỗi vẫn tái hiện sau ba lần sửa độc lập, agent phải
dừng cách tiếp cận vá cục bộ và đánh giá việc tái triển khai toàn bộ khu
vực bị lỗi.

## 2. Điều kiện kích hoạt quy tắc

Quy tắc được kích hoạt khi đáp ứng đồng thời các điều kiện sau:

1.  Cùng một lỗi hoặc cùng một nhóm triệu chứng vẫn tái hiện trong
    **cùng một khu vực chức năng** sau ba lần sửa.
2.  Mỗi lần sửa đã được kiểm tra bằng bước tái hiện hoặc regression test
    phù hợp.
3.  Lỗi không được giải quyết dứt điểm; hoặc một bản sửa làm lỗi quay
    lại, phát sinh lỗi tương đương hay khiến khu vực đó tiếp tục mất ổn
    định.

Một lần sửa được tính là một lần thử khi agent đã thay đổi mã nguồn với
mục tiêu xử lý lỗi và đã chạy bước xác minh tương ứng. Việc chỉ đọc log,
phân tích hoặc chưa thực hiện thay đổi không được tính là một lần sửa.

Không được đặt lại bộ đếm chỉ vì đổi tên commit, chia nhỏ diff hoặc thay
đổi cách mô tả lỗi. Các lỗi có cùng nguyên nhân gốc hoặc cùng khu vực
triển khai phải được xem là một chuỗi sửa lỗi.

## 3. Hành động bắt buộc sau lần sửa thứ ba thất bại

Khi điều kiện ở Mục 2 được đáp ứng, agent phải thực hiện theo thứ tự:

1.  **Dừng vá cục bộ:** Không tiếp tục thêm workaround, điều kiện rẽ
    nhánh hoặc bản vá chồng lên bản vá cũ.
2.  **Khoanh vùng chính xác:** Xác định module, feature, widget,
    service, repository, controller, state provider, adapter, model hoặc
    lớp liên quan trực tiếp đến lỗi.
3.  **Phân tích nguyên nhân gốc:** Đọc toàn bộ luồng dữ liệu và luồng
    gọi hàm của khu vực; kiểm tra dependency, lifecycle, async behavior,
    constraints giao diện, persistence, API contract và test hiện có.
4.  **Lập phương án thay thế:** Mô tả kiến trúc và logic mới, các public
    contract cần giữ, dữ liệu cần bảo toàn, rủi ro migration và test cần
    bổ sung.
5.  **Loại bỏ phần triển khai lỗi thời trong khu vực:** Xóa phần mã cũ
    gây ra lỗi và các workaround phụ thuộc trực tiếp vào nó. Không chỉ
    đổi tên hoặc bọc mã cũ trong một lớp mới.
6.  **Viết lại từ đầu:** Triển khai lại khu vực đó từ logic nền tảng,
    với trách nhiệm rõ ràng, dependency rõ ràng và API được hỗ trợ.
7.  **Kiểm thử độc lập và hồi quy:** Viết hoặc cập nhật unit test,
    widget test, integration test phù hợp; kiểm tra cả luồng thành công,
    lỗi, dữ liệu biên và lifecycle.
8.  **Xác minh toàn dự án:** Chạy format, analyze, test và build theo
    quality gate của dự án; kiểm tra các feature phụ thuộc vào khu vực
    vừa viết lại.
9.  **Ghi nhận bài học:** Cập nhật tài liệu known issues hoặc
    engineering lessons với triệu chứng, nguyên nhân gốc, quyết định
    viết lại, file bị thay thế và test ngăn tái diễn.

## 4. Phạm vi được phép xóa và viết lại

Cụm từ **"xóa toàn bộ khu vực đó"** có nghĩa là loại bỏ toàn bộ phần
triển khai thuộc phạm vi đã khoanh vùng và được chứng minh là không còn
phù hợp, bao gồm:

-   Logic xử lý lỗi và các workaround chồng chéo.
-   Function/method cũ không còn được sử dụng hoặc có hành vi sai.
-   Class, interface, abstraction hoặc adapter không còn phù hợp với
    kiến trúc mới.
-   State, callback, listener, subscription và lifecycle handling được
    gắn với cách triển khai cũ.
-   Test cũ đã kiểm tra một implementation sai hoặc phụ thuộc vào chi
    tiết nội bộ không còn tồn tại; các test này phải được thay bằng test
    kiểm tra contract và hành vi đúng.

Không được hiểu quy tắc này là xóa tùy tiện toàn bộ feature, dữ liệu
người dùng, database, migration, schema JSON, public API hoặc module
không liên quan. Trước khi xóa hoặc thay đổi bất kỳ contract hay cấu
trúc dữ liệu nào, agent phải xác định tất cả nơi đang sử dụng và xây
dựng kế hoạch tương thích/migration.

Nếu không thể viết lại an toàn trong một lần thay đổi, phải chia thành
các bước có thể review và kiểm thử, nhưng không được giữ lại
implementation lỗi chỉ để tránh thay đổi lớn.

## 5. Cấm sử dụng lại API hoặc cấu trúc không còn được hỗ trợ

Khi viết lại, **không được tái sử dụng** bất kỳ function, method, class,
interface, constructor, package API hoặc pattern nào nếu có bằng chứng
rằng nó:

-   Đã bị đánh dấu `deprecated`, `obsolete`, `unsupported` hoặc đã bị
    loại bỏ.
-   Hiển thị gạch ngang (strikethrough) trong IDE hoặc tài liệu API do
    trạng thái deprecated/obsolete.
-   Không còn tồn tại trong phiên bản Flutter, Dart, Android SDK hoặc
    package thực tế mà dự án đang sử dụng.
-   Được tài liệu chính thức của đúng phiên bản xác nhận là không còn
    được hỗ trợ.
-   Chỉ hoạt động nhờ workaround không được nhà cung cấp hỗ trợ.

Agent phải kiểm tra tài liệu chính thức và API của **đúng phiên bản
dependency/SDK trong dự án**, không dựa vào ví dụ cũ, bài viết lỗi thời
hoặc trí nhớ. Phải chọn API thay thế đang được hỗ trợ và phù hợp với
phiên bản mục tiêu.

Nếu một API cũ vẫn còn tồn tại nhưng chỉ bị deprecated, không được mặc
định rằng có thể tiếp tục dùng trong phần viết lại. Chỉ được giữ lại khi
có lý do tương thích bắt buộc, được ghi rõ trong báo cáo, có giới hạn
phạm vi và có kế hoạch loại bỏ. Mặc định của quy tắc này là **không dùng
API deprecated trong implementation mới**.

Không được tự tạo một function, class hoặc interface thay thế chỉ để che
cảnh báo nếu cấu trúc đó vẫn mô phỏng lại thiết kế lỗi cũ. Thay thế phải
giải quyết đúng trách nhiệm và nguyên nhân gốc.

## 6. Các nguyên tắc phải giữ khi viết lại

-   Tuân thủ Blueprint, Engineering Rules, Product Decisions và UI/UX
    Design System của SelfLearn.
-   Không tự ý thay đổi quyết định sản phẩm, schema dữ liệu hoặc quy tắc
    nghiệp vụ chưa được đặc tả.
-   Giữ public contract đang được feature khác sử dụng, trừ khi có kế
    hoạch thay đổi tương thích được review.
-   Ưu tiên thiết kế đơn giản, ít tầng trung gian, mỗi thành phần có một
    trách nhiệm rõ ràng.
-   Tách UI, business logic, persistence và platform integration theo
    cấu trúc dự án.
-   Không tạo abstraction, interface, manager hoặc wrapper không có nhu
    cầu thực tế.
-   Không thêm package mới nếu Flutter/Dart SDK hoặc dependency hiện có
    đã cung cấp API phù hợp.
-   Không tắt analyzer, bỏ qua exception, nới lỏng assertion hoặc xóa
    test để làm pipeline chuyển xanh.
-   Không làm mất dữ liệu người dùng; mọi thay đổi database/file format
    phải có phương án migration và kiểm thử.
-   Không đưa cache, file cấu hình máy cá nhân, secret hoặc file sinh tự
    động vào source control.

## 7. Tiêu chí nghiệm thu bắt buộc

Khu vực viết lại chỉ được xem là hoàn thành khi:

-   Nguyên nhân gốc của lỗi đã được mô tả và xử lý, không chỉ che triệu
    chứng.
-   Không còn tham chiếu đến function/class/interface/API đã bị loại bỏ
    hoặc không còn được hỗ trợ trong phần triển khai mới.
-   Không còn workaround cũ không cần thiết hoặc code chết trong phạm vi
    đã viết lại.
-   Regression test tái hiện lỗi cũ đã được thêm và chạy thành công.
-   Có test cho trường hợp biên, trạng thái lỗi, thao tác lặp lại và
    lifecycle phù hợp.
-   Các test hiện có của feature và feature phụ thuộc đều đạt.
-   Các quality gate của dự án chạy thành công: format, analyze, test và
    build tương ứng.
-   Diff được review; không có thay đổi ngoài phạm vi không được giải
    thích.
-   Tài liệu kỹ thuật và known issues được cập nhật.

Nếu môi trường không có Flutter/Dart SDK hoặc không thể chạy một quality
gate, agent phải ghi rõ **NOT RUN**, lý do và lệnh cần chạy ở môi trường
phù hợp. Không được ghi PASS khi chưa có kết quả thực tế.

## 8. Báo cáo bắt buộc của agent

Sau khi áp dụng quy tắc, báo cáo phải có:

1.  Khu vực bị lỗi và triệu chứng tái hiện.
2.  Ba lần sửa trước: thay đổi gì, test nào đã chạy và vì sao thất bại.
3.  Nguyên nhân gốc được xác nhận bằng bằng chứng.
4.  Danh sách function, class, interface, API hoặc workaround cũ đã loại
    bỏ.
5.  Thiết kế và logic mới được triển khai.
6.  Danh sách file thêm, sửa, xóa.
7.  Regression test và các test bổ sung.
8.  Kết quả format, analyze, test và build: PASS / FAIL / NOT RUN.
9.  Rủi ro còn lại, migration hoặc việc cần người review quyết định.

## 9. Quy tắc quyết định nhanh

  -----------------------------------------------------------------------
  Tình huống                          Hành động
  ----------------------------------- -----------------------------------
  Lỗi được sửa dứt điểm ở lần 1 hoặc  Giữ bản sửa, review diff và
  2 và test đạt                       regression test

  Lỗi cùng khu vực vẫn tái hiện sau   Bắt buộc dừng vá cục bộ, khoanh
  lần sửa thứ 3                       vùng và viết lại khu vực

  Phát hiện API/class/interface       Không tái sử dụng; xác minh API
  deprecated hoặc unsupported trong   thay thế được hỗ trợ
  khu vực viết lại                    

  Chưa rõ phạm vi xóa hoặc có nguy cơ Dừng thao tác phá hủy, phân tích
  mất dữ liệu/public contract         dependency và lập kế hoạch
                                      migration

  Không thể xác minh API thay thế     Ghi rõ điểm chưa xác định, không tự
  hoặc thiếu đặc tả nghiệp vụ         phỏng đoán
  -----------------------------------------------------------------------

------------------------------------------------------------------------

**Nguyên tắc cốt lõi:** Sau ba lần sửa thất bại ở cùng một khu vực,
không tiếp tục vá chồng. Phải xử lý nguyên nhân gốc, loại bỏ
implementation lỗi trong phạm vi đã xác định và xây dựng lại từ logic
nền tảng bằng các API còn được hỗ trợ. Chỉ công nhận hoàn thành khi có
test và kết quả xác minh thực tế.
