# SelfLearn UI/UX Design System

> **Phiên bản:** 1.0  
> **Trạng thái:** Approved baseline  
> **Ngày cập nhật:** 21/11/2026  
> **Phạm vi:** Giao diện SelfLearn trên Phone và Tablet  
>
> Tài liệu này là nguồn tham chiếu thiết kế giao diện cho SelfLearn. Nội dung được phân loại:
> - **Approved:** lựa chọn và hành vi đã được người dùng xác nhận.
> - **Default:** thông số mặc định để bắt đầu triển khai; có thể tinh chỉnh sau kiểm thử.
> - **To Validate:** nội dung cần kiểm tra trên thiết bị thực tế trước khi coi là tiêu chí cuối cùng.

---

## 1. Design Philosophy

### 1.1. Định hướng thẩm mỹ

SelfLearn sử dụng phong cách **Clean Modern – Blue Modern**, kết hợp Glassmorphism có chọn lọc.

Nguyên tắc:
- Ưu tiên nội dung học tập và khả năng đọc hiểu; không để trang trí lấn át nội dung.
- Giao diện gọn, rõ cấp bậc thông tin, ít màu và ít hiệu ứng không cần thiết.
- Thành phần giao diện nhất quán giữa các màn hình.
- Tương tác có phản hồi trực quan, nhanh và không cản trở thao tác.
- Hỗ trợ Phone và Tablet; tận dụng không gian lớn trên Tablet.
- Hỗ trợ Light Theme, Dark Theme và System Theme.
- Thiết kế adaptive: thay đổi cả cách bố trí và điều hướng theo không gian hiển thị, không chỉ co giãn kích thước.

### 1.2. Ưu tiên trải nghiệm

1. Nội dung và thao tác học tập là trọng tâm.
2. Điều hướng phải dễ nhận biết vị trí hiện tại.
3. Trạng thái rỗng, đang tải, thành công và lỗi phải rõ ràng.
4. Không dùng hiệu ứng làm giảm khả năng đọc hoặc hiệu năng.
5. Các hành vi quan trọng phải có phản hồi và trạng thái phù hợp.

---

## 2. Approved Design Decisions

Các lựa chọn sau đã được người dùng xác nhận:

| Hạng mục | Quyết định Approved |
|---|---|
| Color Palette | **A — Blue Modern** |
| Typography | **A — System Font** |
| Spacing | **B — Balanced** |
| Component Style | **C — Selective Glassmorphism** |
| Thiết bị mục tiêu | Phone và Tablet |
| Ghi chú bổ sung cho lựa chọn ban đầu | Không có |
| Navigation selected indicator | Có lớp kính mờ phủ lên mục đang chọn và hoạt ảnh di chuyển khi đổi lựa chọn |

Không tự ý thay đổi các lựa chọn Approved nếu chưa có quyết định mới của chủ dự án.

---

## 3. Visual Identity & Color System

### 3.1. Brand identity

- Tên phong cách: **Blue Modern**.
- Màu thương hiệu chính: xanh dương hiện đại, tạo cảm giác tin cậy và tập trung.
- Màu thương hiệu dùng nhất quán cho hành động chính, trạng thái được chọn và điểm nhấn cần thiết.
- Tránh dùng màu thương hiệu cho mọi thành phần khiến giao diện mất phân cấp.

### 3.2. Light Theme tokens

| Token | Giá trị |
|---|---|
| `background` | `#F5F7FB` |
| `surface` | `#FFFFFF` |
| `surfaceVariant` | `#EDF2FA` |
| `surfaceElevated` | `#FFFFFF` |
| `primary` | `#315FEA` |
| `primaryHover` | `#1746B5` |
| `primaryContainer` | `#EAF0FF` |
| `textPrimary` | `#172554` |
| `textSecondary` | `#64748B` |
| `textDisabled` | `#94A3B8` |
| `border` | `#DCE4F0` |
| `divider` | `#E8EDF5` |

### 3.3. Dark Theme tokens

| Token | Giá trị |
|---|---|
| `background` | `#0B1220` |
| `surface` | `#111C2E` |
| `surfaceVariant` | `#1A2940` |
| `surfaceElevated` | `#22334D` |
| `primary` | `#6B91FF` |
| `primaryHover` | `#8BAAFF` |
| `primaryContainer` | `#1C315C` |
| `textPrimary` | `#F1F5FF` |
| `textSecondary` | `#A9B8CE` |
| `textDisabled` | `#718096` |
| `border` | `#2B3B52` |
| `divider` | `#25354B` |

### 3.4. Semantic colors

| Trạng thái | Light Theme | Dark Theme |
|---|---|---|
| Success | `#15803D` | `#4ADE80` |
| Warning | `#B45309` | `#FBBF24` |
| Error | `#DC2626` | `#F87171` |
| Info | `#2563EB` | `#60A5FA` |

### 3.5. Quy tắc sử dụng màu

- Dùng `primary` cho CTA chính, trạng thái selected và điểm nhấn tương tác.
- Dùng `primaryContainer` cho nền nhẹ của trạng thái được chọn hoặc vùng nhấn mạnh.
- Dùng `textPrimary` cho nội dung quan trọng; `textSecondary` cho mô tả và metadata.
- Không dùng riêng màu sắc để truyền đạt lỗi, thành công hoặc trạng thái; cần có nhãn, icon hoặc thông điệp phù hợp.
- Kiểm tra tương phản ở cả Light và Dark Theme.
- Các giá trị trên là token mặc định; không tự ý tạo màu gần giống tại từng màn hình.

---

## 4. Typography System

### 4.1. Font family

**Approved:** System Font.

- Trên Android, ưu tiên system font mặc định của nền tảng (thông thường là Roboto).
- Không bắt buộc nhúng font bên ngoài.
- Tôn trọng cài đặt font scaling của hệ điều hành.
- Không đặt kích thước chữ cố định theo cách làm nội dung bị cắt khi người dùng tăng cỡ chữ.

### 4.2. Type scale

| Style | Size | Weight | Line height |
|---|---:|---:|---:|
| Display | 30 | 700 | 1.2 |
| H1 | 24 | 700 | 1.25 |
| H2 | 20 | 600 | 1.3 |
| H3 | 18 | 600 | 1.35 |
| Title | 16 | 600 | 1.4 |
| Body | 14 | 400 | 1.5 |
| Body Medium | 14 | 500 | 1.5 |
| Caption | 12 | 400 | 1.4 |
| Button | 14 | 600 | 1.2 |

### 4.3. Quy tắc typography

- Dùng heading theo đúng thứ bậc; không bỏ cấp chỉ để tạo hiệu ứng thị giác.
- Nội dung đọc lâu ưu tiên độ rõ và line-height thoáng.
- Caption dành cho metadata hoặc thông tin phụ, không dùng cho nội dung quan trọng.
- Nút và nhãn tương tác phải đủ rõ, dễ đọc.
- Cho phép font scale theo hệ thống; kiểm tra layout khi cỡ chữ tăng.

---

## 5. Layout & Spacing

### 5.1. Spacing scale

**Approved:** Balanced spacing.

| Token | Giá trị |
|---|---:|
| `space0` | 0 px |
| `space1` | 4 px |
| `space2` | 8 px |
| `space3` | 12 px |
| `space4` | 16 px |
| `space5` | 20 px |
| `space6` | 24 px |
| `space8` | 32 px |
| `space10` | 40 px |

Ưu tiên dùng bội số 4 px; dùng token thay vì tự đặt khoảng cách tùy ý.

### 5.2. Layout defaults

| Hạng mục | Phone | Tablet |
|---|---:|---:|
| Page horizontal inset | 16 px | 20 px |
| Card padding | 12–16 px | 16 px |
| Section gap | 20 px | 24 px |
| Card gap | 12 px | 16 px |
| Form field gap | 12 px | 12–16 px |
| Dialog padding | 20 px | 24 px |

### 5.3. Grid và bố cục

- Phone: nội dung dashboard thường dùng một cột.
- Tablet: dashboard có thể dùng hai cột; tăng lên ba cột khi chiều rộng thực tế cho phép.
- Danh sách trên Phone ưu tiên card/list item dễ thao tác.
- Trên Tablet có thể dùng toolbar, bảng hoặc bố cục nhiều cột khi tăng khả năng quan sát.
- Search/filter trên Phone có thể đặt trong bottom sheet; trên Tablet ưu tiên toolbar hoặc panel hiển thị trực tiếp.
- Không ép một bố cục Phone phóng to nguyên trạng lên Tablet.

---

## 6. Border Radius, Border & Elevation

### 6.1. Radius tokens

| Token | Giá trị |
|---|---:|
| Small | 8 px |
| Medium | 12 px |
| Large | 16 px |
| Extra Large | 20 px |
| Pill | 999 px |

Quy tắc:
- Input và button thường dùng radius 12 px.
- Card thường dùng radius 16 px.
- Dialog/panel có thể dùng radius 16–20 px.
- Chip và pill dùng radius dạng viên thuốc.

### 6.2. Elevation

Dùng các mức elevation vừa đủ để phân biệt lớp nội dung:
- None: thành phần phẳng.
- Low: card hoặc panel thông thường.
- Medium: menu, popup hoặc panel nổi.
- High: dialog/overlay cần phân lớp rõ.

Trong Dark Theme, ưu tiên khác biệt giữa surface và border thay vì tăng shadow mạnh.

---

## 7. Glassmorphism Guidelines

### 7.1. Nguyên tắc

**Approved:** Selective Glassmorphism.

Glassmorphism chỉ dùng tại những vị trí có ý nghĩa phân lớp hoặc trạng thái tương tác. Không biến toàn bộ ứng dụng thành các lớp kính mờ.

Vị trí được phép ưu tiên:
- Navigation selected indicator.
- Header hoặc vùng điều hướng nổi khi cần phân lớp.
- Popup, overlay và dialog phù hợp.

Không ưu tiên dùng kính mờ cho:
- Nội dung văn bản dài.
- Danh sách/card nội dung cần đọc lâu.
- Mọi card trong ứng dụng.
- Các vùng chồng nhiều lớp blur.

### 7.2. Glass tokens mặc định

| Thuộc tính | Light Theme | Dark Theme |
|---|---|---|
| Background opacity | Khoảng 72% màu trắng | Khoảng 8–12% màu trắng |
| Border | Trắng, opacity khoảng 80% | Trắng, opacity khoảng 12–18% |
| Blur | 12 px | 12 px |
| Radius tham chiếu | 16 px | 16 px |

Các giá trị opacity là thông số mặc định để triển khai và cần kiểm tra trực quan trên nền thực tế.

### 7.3. Quy tắc hiệu năng

- Tránh nhiều `BackdropFilter` lồng nhau hoặc đặt riêng trên từng item không cần thiết.
- Ưu tiên một lớp blur dùng chung cho indicator khi phù hợp.
- Không blur vùng nội dung lớn nếu không có lợi ích UX rõ ràng.
- Có phương án hiển thị thay thế khi blur gây giảm hiệu năng hoặc không được hỗ trợ tốt.
- Kiểm tra trên Android Phone và Tablet thực tế.

---

## 8. Component Guidelines

### 8.1. Buttons

| Loại | Chiều cao mặc định | Quy tắc |
|---|---:|---|
| Primary button | 48 px | CTA chính, dùng màu primary |
| Secondary button | 40–44 px | Hành động phụ |
| Icon button | Tối thiểu vùng chạm 48 × 48 px | Icon rõ, có tooltip/semantic label khi cần |

- Button có trạng thái enabled, disabled, loading khi phù hợp.
- Không để nhiều CTA chính cạnh tranh trong cùng một vùng.
- Có phản hồi khi nhấn nhưng không dùng hiệu ứng kéo dài.

### 8.2. Text fields và search

- Chiều cao mặc định: 48 px.
- Radius: 12 px.
- Có trạng thái normal, focused, error và disabled.
- Label/hint không thay thế hoàn toàn label truy cập.
- Thông báo lỗi cần cụ thể, đặt gần trường nhập.
- Search field phải dễ nhận biết và có thao tác xóa nội dung khi phù hợp.

### 8.3. Cards

- Radius: 16 px.
- Padding: 12–16 px trên Phone, 16 px trên Tablet.
- Border 1 px theo token border.
- Shadow nhẹ; Dark Theme ưu tiên surface/border.
- Nội dung card phải có phân cấp rõ giữa tiêu đề, mô tả, metadata và hành động.
- Không áp dụng glassmorphism cho tất cả card.

### 8.4. Chips và badges

- Dùng để biểu thị chủ đề, bộ lọc, trạng thái hoặc metadata ngắn.
- Phân biệt rõ selected và unselected.
- Không dùng quá nhiều màu trạng thái trong một vùng nhỏ.
- Nội dung phải ngắn gọn, không thay thế thông tin quan trọng.

### 8.5. Dialog và bottom sheet

- Dùng dialog cho xác nhận hoặc tác vụ cần tập trung.
- Dùng bottom sheet cho lựa chọn/phần điều khiển phù hợp trên Phone.
- Nội dung, nút xác nhận và nút hủy phải rõ ràng.
- Thao tác phá hủy dữ liệu cần bước xác nhận và mô tả hậu quả.

### 8.6. Trạng thái giao diện

Các màn hình có dữ liệu bất đồng bộ hoặc thao tác lưu cần xử lý phù hợp:
- Loading.
- Empty.
- Success.
- Error.
- Disabled hoặc unavailable khi cần.

Không coi một màn hình đã hoàn thành chỉ vì trạng thái dữ liệu bình thường hiển thị đúng.

---

## 9. Navigation & Glass Selection Indicator

### 9.1. Quyết định Approved

Navigation phải có **một lớp Glass Selection Indicator phủ lên mục trang đang được chọn**.

Khi người dùng chọn một mục khác:
- Indicator di chuyển từ vị trí cũ sang vị trí mới.
- Không biến mất rồi xuất hiện lại như hai hiệu ứng độc lập.
- Chuyển động đơn giản, nhanh nhưng đủ nhìn thấy.
- Trang đích được cập nhật ngay; animation không được khóa thao tác.
- Nếu người dùng chọn liên tiếp, indicator tiếp tục hướng tới lựa chọn mới nhất.

### 9.2. Phạm vi áp dụng

**Phone — Bottom Navigation**
- Indicator dạng pill/rounded container nằm phía sau hoặc bao quanh nội dung mục đang chọn.
- Chuyển động theo chiều ngang giữa các mục.
- Icon và label của mục selected đổi màu/trạng thái nhẹ nhàng.

**Tablet — NavigationRail / Sidebar**
- Indicator bao quanh hàng Navigation đang chọn.
- Chuyển động theo chiều dọc.
- Khi Sidebar thu gọn/mở rộng, trạng thái selected phải được giữ nguyên.
- Cùng một nguyên tắc thị giác và chuyển động với Phone; chỉ thay đổi hướng bố trí theo layout.

### 9.3. Motion defaults

| Thuộc tính | Giá trị mặc định |
|---|---|
| Duration | 180 ms |
| Curve | `Curves.easeOutCubic` |
| Direction | Trượt từ vị trí hiện tại đến vị trí mới |
| Indicator radius | 12–16 px |
| Blur | 10–12 px |
| Light glass opacity | Khoảng 72% |
| Dark glass opacity | Khoảng 8–12% |
| Border | Viền sáng mờ, tinh tế |
| Shadow | Rất nhẹ hoặc không dùng |

### 9.4. Phản hồi tương tác

- Cập nhật trang đích ngay khi người dùng chọn.
- Indicator trượt đến vị trí mới.
- Icon và label chuyển màu/trạng thái nhẹ.
- Không làm chậm hoặc chặn thao tác tiếp theo.
- Hỗ trợ thao tác chọn liên tiếp; đích animation luôn theo lựa chọn mới nhất.
- Không làm mất trạng thái selected khi đổi breakpoint hoặc chuyển dạng Navigation.

### 9.5. Gợi ý triển khai Flutter

Đây là gợi ý kỹ thuật, không phải yêu cầu bắt buộc phải dùng đúng một widget:
- Có thể dùng `AnimatedPositioned` hoặc `AnimatedAlign` để di chuyển indicator.
- Có thể dùng `AnimatedContainer` cho thay đổi kích thước, radius hoặc decoration.
- Dùng `BackdropFilter` có kiểm soát cho hiệu ứng kính mờ.
- Dùng `AnimatedDefaultTextStyle` hoặc cơ chế tương đương cho label.
- Ưu tiên một lớp blur dùng chung thay vì một `BackdropFilter` riêng cho từng mục.
- Tôn trọng `MediaQueryData.reduceMotion`.

### 9.6. Reduce Motion

Khi người dùng bật Reduce Motion:
- Không dùng chuyển động trượt rõ rệt.
- Có thể đổi trạng thái tức thời hoặc dùng chuyển opacity rất ngắn.
- Không được làm mất tín hiệu thị giác về mục đang được chọn.

---

## 10. Responsive Design — Phone & Tablet

### 10.1. Breakpoint defaults

Các breakpoint dưới đây là mốc bố cục mặc định; cần kiểm tra thêm với kích thước cửa sổ thực tế và hướng màn hình.

| Chiều rộng | Bố cục tham chiếu |
|---|---|
| 360–599 px | Phone, một cột |
| 600–767 px | Không gian trung gian, một hoặc hai cột tùy nội dung |
| 768–839 px | Tablet nhỏ, ưu tiên hai cột khi phù hợp |
| 840–1023 px | Tablet, hai cột |
| 1024–1199 px | Tablet rộng, hai hoặc ba cột |
| Từ 1200 px | Có thể dùng ba cột và Inspector Panel |

### 10.2. Navigation theo thiết bị

- Phone: Bottom Navigation cho các khu vực chính; Drawer có thể dùng cho mục phụ.
- Tablet: NavigationRail hoặc Sidebar.
- Tablet rộng: Sidebar có thể mở rộng; có thể bổ sung Inspector Panel khi nội dung cần xem song song.
- Sidebar expanded tham chiếu khoảng 240–264 px.
- NavigationRail/collapsed sidebar tham chiếu khoảng 72–80 px.
- Inspector Panel tham chiếu khoảng 280–320 px khi có đủ chiều rộng.

### 10.3. Dashboard và danh sách

- Phone: dashboard một cột.
- Tablet: dashboard hai cột; ba cột khi đủ chiều rộng và không làm card quá hẹp.
- Danh sách ưu tiên card trên Phone; Tablet có thể dùng table/list density cao hơn khi phù hợp.
- Không để thao tác chính bị đẩy ra ngoài vùng dễ tiếp cận.

### 10.4. Orientation và resize

- Hỗ trợ cả portrait và landscape.
- Khi kích thước cửa sổ thay đổi, giữ dữ liệu và trạng thái điều hướng.
- Không để indicator selected nhảy về mục mặc định khi chuyển layout.
- Kiểm tra tràn chữ, tràn ngang và vùng chạm ở mọi breakpoint.

---

## 11. Animation & Interaction

### 11.1. Motion defaults

| Tương tác | Duration mặc định |
|---|---:|
| Button feedback | 100–150 ms |
| Card interaction | 120–180 ms |
| Dropdown | 150–200 ms |
| Sidebar | 200–250 ms |
| Dialog | 180–250 ms |
| Page transition | 200–250 ms |
| Navigation indicator | 180 ms |

Navigation indicator dùng `easeOutCubic` theo mục 9.

### 11.2. Nguyên tắc animation

- Ngắn, mượt, có mục đích và nhất quán.
- Animation hỗ trợ hiểu trạng thái, không chỉ để trang trí.
- Không trì hoãn phản hồi thao tác chỉ để chờ animation kết thúc.
- Tránh nhiều animation cạnh tranh cùng lúc.
- Hỗ trợ Reduce Motion.

---

## 12. Accessibility

- Duy trì độ tương phản đủ rõ cho chữ và thành phần tương tác ở cả hai theme.
- Không dùng màu sắc làm tín hiệu duy nhất.
- Tôn trọng font scaling của hệ điều hành.
- Vùng chạm cho thao tác chính nên đạt tối thiểu 48 × 48 px.
- Thành phần tương tác cần semantic label phù hợp cho screen reader.
- Thứ tự focus phải hợp lý; trạng thái selected/disabled/error cần được công bố.
- Nội dung không bị cắt khi tăng cỡ chữ hoặc đổi hướng màn hình.
- Không truyền đạt trạng thái chỉ bằng hiệu ứng chuyển động.

---

## 13. Performance Guidelines

- Giới hạn blur, shadow và các hiệu ứng compositing tốn tài nguyên.
- Tránh nhiều lớp `BackdropFilter` lồng nhau.
- Không blur toàn bộ danh sách hoặc vùng nội dung dài.
- Tối ưu rebuild để thay đổi selected Navigation không khiến toàn bộ màn hình render lại không cần thiết.
- Animation phải duy trì cảm giác phản hồi nhanh trên thiết bị Android mục tiêu.
- Có fallback khi hiệu ứng blur không phù hợp hoặc gây giảm hiệu năng.
- Kiểm thử trên thiết bị thật, không chỉ dựa vào emulator.

---

## 14. UI Quality Checklist

Trước khi hoàn thiện một màn hình, kiểm tra:

### Visual consistency
- [ ] Dùng đúng color tokens Light/Dark.
- [ ] Dùng đúng typography scale.
- [ ] Spacing theo hệ thống Balanced.
- [ ] Radius, border và elevation nhất quán.
- [ ] Glassmorphism chỉ xuất hiện ở vị trí có chủ đích.

### Layout & responsive
- [ ] Hiển thị tốt trên Phone.
- [ ] Hiển thị tốt trên Tablet.
- [ ] Không tràn hoặc cắt nội dung ở portrait/landscape.
- [ ] Bố cục tận dụng hợp lý không gian Tablet.
- [ ] Search/filter và hành động chính dễ tiếp cận.

### Navigation & motion
- [ ] Mục Navigation hiện tại được nhận biết rõ.
- [ ] Glass Selection Indicator di chuyển đúng khi đổi lựa chọn.
- [ ] Indicator hoạt động trên Bottom Navigation và Sidebar/NavigationRail.
- [ ] Chọn liên tiếp không gây lỗi vị trí hoặc trạng thái.
- [ ] Selected state được giữ khi resize/collapse/expand.
- [ ] Reduce Motion được tôn trọng.

### Accessibility & states
- [ ] Độ tương phản phù hợp.
- [ ] Font scaling không làm vỡ layout.
- [ ] Touch target đủ lớn.
- [ ] Có semantic label phù hợp.
- [ ] Có loading, empty, success và error state khi cần.
- [ ] Lỗi được diễn đạt rõ ràng, có hướng xử lý khi phù hợp.

### Performance
- [ ] Không lạm dụng blur/shadow.
- [ ] Không có BackdropFilter lồng nhau không cần thiết.
- [ ] Animation không làm chậm thao tác.
- [ ] Đã kiểm tra trên thiết bị mục tiêu.

---

## 15. Design Tokens & Flutter Reference

Các nhóm token nên được quản lý tập trung, không khai báo rải rác trong từng màn hình.

Cấu trúc tham chiếu:

```text
lib/
  app/
    theme/
      app_colors.dart
      app_typography.dart
      app_spacing.dart
      app_radius.dart
      app_elevation.dart
      app_glass.dart
      app_breakpoints.dart
      app_motion.dart
      app_theme.dart
      theme_controller.dart
```

Các component dùng chung dự kiến:

```text
AppButton
AppTextField
AppSearchField
AppCard
AppChip
AppDialog
AppDropdown
AppGlassPanel
AppBottomNavigation
AppSidebar
EmptyState
LoadingView
ErrorView
```

### 15.1. Token Navigation bổ sung

Cần có token tập trung cho:
- `AppGlass.navigationBlur`
- `AppGlass.navigationLightOpacity`
- `AppGlass.navigationDarkOpacity`
- `AppGlass.navigationBorder`
- `AppNavigation.indicatorRadius`
- `AppNavigation.indicatorPadding`
- `AppMotion.navigationDuration`
- `AppMotion.navigationCurve`

Tên token có thể điều chỉnh theo quy ước đặt tên thực tế của codebase, nhưng giá trị và ý nghĩa thiết kế phải được giữ nhất quán.

---

## 16. Change Management

- Các lựa chọn trong mục **Approved Design Decisions** là baseline đã được người dùng xác nhận.
- Giá trị ghi là **Default** là thông số triển khai mặc định; có thể tinh chỉnh sau khi kiểm thử mà không làm thay đổi ý định thiết kế.
- Những điểm chưa được xác nhận phải được ghi là **To Validate**, không tự nâng thành quyết định Approved.
- Khi người dùng phê duyệt thay đổi, cập nhật tài liệu này và tăng phiên bản khi thay đổi có ảnh hưởng đáng kể.
- Không tự ý thay đổi palette, typography, spacing style, component style hoặc hành vi Navigation indicator nếu chưa có phê duyệt mới.

---

**Kết thúc tài liệu — SelfLearn UI/UX Design System v1.0**
