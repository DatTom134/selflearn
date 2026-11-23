# SelfLearn -- Các đề mục và quyết định đã chốt

> **Mục đích:** Ghi nhận các quyết định nghiệp vụ và tiêu chí nghiệm thu
> đã được xác nhận cho SelfLearn. Đây là tài liệu tham chiếu khi thiết
> kế, triển khai và kiểm thử ứng dụng.
>
> **Trạng thái:** Các quyết định trong tài liệu này đã được người dùng
> xác nhận trong cuộc trao đổi. **Ngày ghi nhận:** 21/11/2026

------------------------------------------------------------------------

## 1. Định hướng tạo và nhập đề bằng AI

### 1.1. Quyết định đã chốt

SelfLearn không yêu cầu ứng dụng trực tiếp gọi API AI để sinh đề. Người
dùng chủ động sử dụng ChatGPT hoặc Gemini trên chatbox bên ngoài, sau đó
đưa kết quả vào SelfLearn.

Quy trình:

1.  Người dùng chọn một hoặc nhiều chủ đề cần học trong SelfLearn.
2.  SelfLearn tạo và xuất **mẫu JSON (Template JSON)** tương ứng.
3.  Người dùng sao chép mẫu JSON hoặc xuất thành file để đưa vào
    ChatGPT/Gemini.
4.  ChatGPT/Gemini sinh bộ câu hỏi theo cấu trúc và quy tắc trong mẫu.
5.  Người dùng đưa kết quả trở lại SelfLearn bằng cách dán JSON dạng
    text hoặc chọn file JSON.
6.  SelfLearn kiểm tra dữ liệu, cho xem trước và lưu bộ đề hợp lệ vào
    Kho đề luyện tập.

### 1.2. Mục tiêu

-   Tận dụng lượt sử dụng miễn phí hằng ngày của ChatGPT/Gemini khi tài
    khoản và dịch vụ cung cấp.
-   Không bắt buộc người học phải nhập API key vào ứng dụng.
-   Không phụ thuộc vào việc SelfLearn phải gọi dịch vụ AI để tạo đề.
-   Cho phép tạo nhiều bộ đề đa dạng từ cùng một chủ đề hoặc tổ hợp chủ
    đề.

### 1.3. Hai loại JSON

-   **Template JSON:** Mẫu do SelfLearn xuất ra để hướng dẫn AI tạo đề;
    mô tả chủ đề, dạng bài, độ khó, số lượng và cấu trúc đầu ra.
-   **Exercise JSON:** JSON đề hoàn chỉnh do AI tạo hoặc được nhập từ
    nguồn bên ngoài; SelfLearn kiểm tra và lưu thành một bộ đề.

------------------------------------------------------------------------

## 2. Kho đề luyện tập

### 2.1. Quyết định tổ chức

**Đã chốt: Kết hợp phân loại theo chủ đề và theo từng bộ đề (`both`).**

-   Mỗi JSON đề hoàn chỉnh được lưu thành **một card độc lập**.
-   Mỗi card có thể gắn một hoặc nhiều chủ đề.
-   Một chủ đề có thể liên kết với nhiều card.
-   Đề trộn nhiều chủ đề vẫn là một card duy nhất; không tách thành
    nhiều card theo từng chủ đề.
-   Người dùng có thể tìm kiếm và lọc card theo chủ đề.

### 2.2. Thông tin hiển thị trên card

Card nên thể hiện các thông tin cơ bản:

-   Tên bộ đề.
-   Chủ đề hoặc danh sách chủ đề.
-   Dạng bài.
-   Độ khó.
-   Số lượng câu hỏi.
-   Thời điểm nhập.

Các thao tác dự kiến trên card:

-   Mở và luyện tập.
-   Xem chi tiết.
-   Đổi tên.
-   Xuất JSON.
-   Xóa bộ đề.

------------------------------------------------------------------------

## 3. Quyết định về xóa bộ đề

**Đã chốt: Xóa riêng từng bộ đề (`per_set`).**

Khi người dùng xóa một card:

-   Chỉ xóa bộ đề được chọn.
-   Không ảnh hưởng các card khác, kể cả khi chúng có chung chủ đề.
-   Xóa file JSON và các tài nguyên chỉ thuộc bộ đề đó khi không còn
    được sử dụng.
-   Không tự động xóa lịch sử làm bài của bộ đề.
-   Hiển thị bước xác nhận trước khi xóa.

Lịch sử làm bài được quản lý độc lập với vòng đời của card. Việc giữ
lịch sử sau khi xóa card là quyết định đã chốt; cách hiển thị và tra cứu
lịch sử sau đó cần được thiết kế riêng.

### 3.1. Quan hệ giữa xóa bộ đề và Kho từ vựng -- Đã chốt

**Quyết định đã chốt: Từ vựng chỉ được lưu vào Kho từ vựng khi người dùng
chủ động chọn trong lúc học (phương án C).** Không tự động đưa toàn bộ từ
xuất hiện trong JSON đề vào Kho từ vựng.

-   Khi học, người dùng có thể chọn/tap một từ trong câu hỏi, đáp án,
    phần giải thích hoặc nội dung liên quan và thực hiện thao tác **Lưu
    từ vựng**.
-   Chỉ những từ người dùng chủ động lưu mới trở thành mục từ độc lập
    trong Kho từ vựng.
-   Mục từ đã lưu tồn tại độc lập với bộ đề đã phát hiện ra từ đó; xóa
    bộ đề không xóa mục từ đã lưu.
-   Từ chỉ xuất hiện trong đề nhưng chưa được người dùng lưu không được
    tự động chuyển thành mục từ trong Kho từ vựng. Khi xóa đề, dữ liệu
    riêng của đề có thể được xóa theo quy tắc xóa bộ đề.
-   Nếu từ đã có trong Kho từ vựng, thao tác lưu từ ở đề khác nên liên
    kết/nghi nhận thêm ngữ cảnh hoặc nguồn xuất hiện, không tạo mục từ
    trùng lặp.
-   Người dùng có thể tra cứu Kho từ vựng độc lập với Kho đề luyện tập.

### 3.2. Dữ liệu của một mục từ đã lưu

Kho từ vựng cần được thiết kế như một tập dữ liệu độc lập, có thể mở rộng
để lưu các trường phù hợp, gồm:

-   Từ/cụm từ chuẩn (headword) và dạng từ xuất hiện trong ngữ cảnh.
-   Loại từ.
-   Nghĩa và giải thích.
-   Phiên âm IPA; có thể phân biệt Anh-Anh và Anh-Mỹ khi có dữ liệu.
-   Cách đọc và tham chiếu âm thanh phát âm nếu có.
-   Ví dụ và ngữ cảnh sử dụng.
-   Collocations, từ đồng nghĩa, trái nghĩa và họ từ khi có dữ liệu.
-   Nguồn/ngữ cảnh mà người dùng đã lưu từ đó.
-   Trạng thái nguồn hoặc xác minh để phân biệt dữ liệu đã kiểm chứng
    với nội dung do AI tạo/chưa xác minh.

Đây là danh sách trường định hướng, không có nghĩa mọi trường đều bắt
buộc phải có ngay trong MVP. Không được tự tạo IPA, nghĩa hoặc âm thanh
rồi coi là dữ liệu đã xác minh.

------------------------------------------------------------------------

## 4. Định dạng và kiểm tra JSON nhập vào

### 4.1. Phương thức nhập

SelfLearn cần hỗ trợ cả hai cách:

1.  Dán nội dung JSON dạng text.
2.  Chọn file JSON từ thiết bị.

### 4.2. Quy trình nhập

1.  Đọc nội dung JSON.
2.  Kiểm tra cú pháp JSON.
3.  Kiểm tra phiên bản schema.
4.  Kiểm tra cấu trúc và các trường bắt buộc.
5.  Kiểm tra dữ liệu câu hỏi, dạng bài và đáp án theo schema tương ứng.
6.  Hiển thị bản xem trước.
7.  Chỉ lưu sau khi người dùng xác nhận.
8.  Tạo một card độc lập trong Kho đề luyện tập.

Nếu dữ liệu không hợp lệ, ứng dụng cần thông báo lỗi cụ thể, chỉ ra câu
hỏi hoặc trường dữ liệu có vấn đề khi có thể. Không chỉ hiển thị thông
báo chung chung "JSON không hợp lệ".

Cần có cơ chế phát hiện ID trùng hoặc nội dung trùng để hạn chế nhập lặp
ngoài ý muốn.

------------------------------------------------------------------------

## 5. Lưu trữ dữ liệu

### 5.1. Hướng lưu trữ đã chọn

Mô hình lưu trữ định hướng:

-   **SQLite/Drift:** lưu metadata của bộ đề, thông tin card, quan hệ
    chủ đề và thông tin tham chiếu tới file JSON.
-   **File JSON riêng:** lưu nội dung đầy đủ của từng bộ đề trong vùng
    lưu trữ riêng của ứng dụng.
-   **Kho từ vựng:** lưu các mục từ do người dùng chủ động chọn trong
    lúc học dưới dạng thực thể độc lập, không phụ thuộc vòng đời JSON đề.
    Quan hệ nguồn/ngữ cảnh từ đề nên được lưu riêng để có thể giữ hoặc
    xóa liên kết mà không xóa mục từ đã lưu.

Cách tổ chức này tránh phải đóng gói các bộ đề người dùng nhập vào APK
và cho phép quản lý, xuất hoặc xóa từng bộ đề độc lập.

### 5.2. Nguyên tắc quản lý tài nguyên

-   Mỗi bộ đề có định danh ổn định và tham chiếu tới nội dung JSON của
    nó.
-   Khi xóa bộ đề, chỉ xóa tài nguyên thuộc riêng bộ đề đó.
-   Không xóa tài nguyên dùng chung hoặc còn được bộ đề khác tham chiếu.
-   Dữ liệu local phải tồn tại sau khi đóng và mở lại ứng dụng.
-   Có khả năng xuất JSON của từng bộ đề để sao lưu hoặc chia sẻ.

------------------------------------------------------------------------

## 6. Tiêu chí nghiệm thu quan trọng -- Đã xác nhận

Các tiêu chí dưới đây đã được người dùng xác nhận:

-   [ ] Nhập một JSON tạo đúng một card.
-   [ ] Nhập đề trộn tạo một card có nhiều nhãn chủ đề.
-   [ ] Lọc theo từng chủ đề tìm thấy đúng các card liên quan.
-   [ ] Xóa một card không ảnh hưởng card khác.
-   [ ] Đóng và mở lại ứng dụng, card vẫn tồn tại.
-   [ ] Xóa card không làm mất lịch sử học tập.
-   [ ] Xóa card không làm mất các mục từ người dùng đã chủ động lưu vào
    Kho từ vựng.
-   [ ] Từ chỉ xuất hiện trong đề nhưng chưa được người dùng lưu không
    tự động trở thành mục từ trong Kho từ vựng.
-   [ ] Một từ đã có trong Kho từ vựng được tái sử dụng/liên kết khi người
    dùng lưu từ đó từ một đề khác, tránh tạo mục từ trùng lặp.
-   [ ] File JSON không còn được sử dụng sẽ được giải phóng dung lượng.
-   [ ] Có thể xuất lại JSON của từng card.

### Diễn giải khi kiểm thử

-   **Một JSON → một card:** không tạo nhiều card từ các chủ đề nằm bên
    trong cùng một bộ đề.
-   **Đề trộn:** card giữ toàn bộ danh sách chủ đề liên quan.
-   **Lọc chủ đề:** card xuất hiện trong kết quả của từng chủ đề mà nó
    được gắn.
-   **Xóa độc lập:** xóa một card không làm thay đổi nội dung hay liên
    kết của card khác.
-   **Persistence:** dữ liệu vẫn đọc được sau khi thoát và khởi động lại
    ứng dụng.
-   **Lịch sử:** lịch sử làm bài không bị xóa theo card.
-   **Kho từ vựng:** mục từ đã được người dùng chủ động lưu vẫn tồn tại
    sau khi xóa bộ đề nguồn.
-   **Không tự động lưu:** từ chưa được người dùng chọn lưu không được
    thêm vào Kho từ vựng chỉ vì xuất hiện trong JSON đề.
-   **Tái sử dụng từ:** lưu một từ đã tồn tại từ đề khác không tạo mục từ
    trùng; có thể bổ sung ngữ cảnh/nguồn xuất hiện.
-   **Giải phóng dung lượng:** chỉ xóa file và tài nguyên không còn được
    tham chiếu.
-   **Export:** file JSON xuất ra phải chứa nội dung bộ đề tương ứng và
    có thể dùng lại để nhập.

------------------------------------------------------------------------

## 7. Phạm vi tính năng MVP đã xác định

Kho đề và luồng JSON cần hỗ trợ:

-   [ ] Chọn một chủ đề để xuất mẫu JSON.
-   [ ] Chọn nhiều chủ đề để tạo mẫu JSON trộn.
-   [ ] Chọn dạng bài, số câu và độ khó khi tạo mẫu.
-   [ ] Sao chép mẫu JSON.
-   [ ] Xuất mẫu JSON thành file.
-   [ ] Nhập JSON bằng cách dán text.
-   [ ] Nhập JSON từ file.
-   [ ] Kiểm tra và xem trước JSON trước khi lưu.
-   [ ] Tạo card riêng cho từng bộ đề.
-   [ ] Luyện tập từ card.
-   [ ] Trong lúc học, cho phép người dùng chủ động chọn/lưu từ vựng.
-   [ ] Lưu mục từ độc lập với bộ đề nguồn; không tự động lưu mọi từ
    trong JSON đề.
-   [ ] Tìm kiếm và tra cứu Kho từ vựng độc lập với Kho đề.
-   [ ] Tìm kiếm và lọc bộ đề theo chủ đề.
-   [ ] Đổi tên card.
-   [ ] Xuất JSON của card.
-   [ ] Xóa riêng từng card.
-   [ ] Lưu trữ offline.

------------------------------------------------------------------------

## 8. Định hướng kỹ thuật tham chiếu

Các lựa chọn kỹ thuật định hướng cho SelfLearn:

-   Flutter và Dart.
-   Kiến trúc MVVM kết hợp Repository.
-   Riverpod cho quản lý trạng thái.
-   SQLite qua Drift cho dữ liệu có cấu trúc.
-   File JSON lưu trong app-specific directory.
-   Offline-first.
-   Tách Presentation, Application, Domain và Data theo feature khi phù
    hợp.

Repository là đầu mối quản lý đọc/ghi dữ liệu. Giao diện không tự thao
tác SQL hoặc đường dẫn file.

Các chi tiết package, schema database, cấu trúc thư mục và API nội bộ
cần được xác nhận dựa trên repository thực tế trước khi triển khai.

------------------------------------------------------------------------

## 9. Nguyên tắc thay đổi quyết định

-   Các mục có nhãn **Đã chốt** là yêu cầu chuẩn để thiết kế và nghiệm
    thu.
-   Không tự ý thay đổi quy tắc một JSON tương ứng một card, cách phân
    loại `both` hoặc cách xóa `per_set`.
-   Nếu cần thay đổi, phải ghi nhận quyết định mới và cập nhật tài liệu
    này.
-   Phân biệt rõ quyết định nghiệp vụ đã chốt với chi tiết kỹ thuật còn
    cần khảo sát hoặc xác nhận.
