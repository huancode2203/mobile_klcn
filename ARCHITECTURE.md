# Cấu trúc mã nguồn HTBAM Mobile

Dự án: E:\Mobile_KLCN. Mỗi màn hình nằm trong một file riêng; không còn lib/src/app.dart tổng hợp.

```text
lib/
├── main.dart                       # Điểm khởi chạy
├── app.dart                        # MaterialApp, phiên đăng nhập, chuyển local/backend
├── models/                         # Dữ liệu có kiểu và fromJson
│   ├── user_model.dart
│   ├── student_model.dart
│   ├── session_model.dart
│   ├── alert_model.dart
│   ├── face_enrollment_model.dart
│   └── json.dart
├── services/                       # Kết nối và endpoint nghiệp vụ
│   ├── api_service.dart            # HTTP, JWT, secure storage, đăng nhập/đăng xuất
│   ├── student_service.dart
│   ├── session_service.dart
│   ├── alert_service.dart
│   ├── face_enrollment_service.dart
│   ├── report_service.dart
│   ├── catalog_service.dart
│   └── demo/demo_api_service.dart   # Xử lý local trong bộ nhớ
├── data/demo/demo_students.dart    # Hồ sơ sinh viên giả lập
├── screens/
│   ├── auth/login_screen.dart
│   ├── home/home_screen.dart       # Khung app và thanh điều hướng
│   ├── dashboard/dashboard_screen.dart
│   ├── sessions/
│   │   ├── sessions_screen.dart
│   │   ├── session_detail_screen.dart
│   │   └── create_session_screen.dart
│   ├── students/
│   │   ├── students_screen.dart
│   │   └── student_detail_screen.dart
│   ├── alerts/alerts_screen.dart
│   ├── face_enrollment/face_enrollment_screen.dart
│   ├── reports/report_screen.dart
│   ├── classes/class_sections_screen.dart
│   ├── account/account_screen.dart
│   ├── admin/admin_screen.dart
│   └── shared/data_screen.dart     # Trang xem dữ liệu chung, chỉ đọc
├── widgets/
│   ├── async_data_view.dart        # Loading/error/retry/refresh, generic T
│   ├── session_tile.dart           # Nhận model và callback
│   ├── status_badge.dart
│   ├── metric_card.dart
│   ├── notice_banner.dart
│   ├── empty_state.dart
│   ├── data_record_card.dart
│   └── data_view.dart
└── core/
    ├── theme/app_colors.dart       # Bảng màu
    ├── theme/app_theme.dart        # Theme Material, style input/button/card
    ├── constants/field_labels.dart
    ├── errors/api_exception.dart
    └── utils/                     # Định dạng ngày, nhãn, JSON, dialog và điều hướng
```

## Luồng dữ liệu

Screen → service nghiệp vụ → ApiService → backend hoặc DemoApiService.

Kết quả JSON → model → screen → widget trình bày.

Ví dụ: SessionsScreen gọi SessionService.list(), nhận List<SessionModel>, rồi truyền từng model và onTap vào SessionTile. SessionTile không tự gọi API hoặc import màn hình chi tiết.

## Quy tắc phát triển

- Sửa bố cục ở screens/, thành phần dùng chung ở widgets/.
- Thay màu và style ở core/theme/.
- Thay endpoint/cách đọc dữ liệu ở service tương ứng.
- Thêm trường dữ liệu ở model và fromJson; model không phụ thuộc Flutter.
- Service và model không import screens/ hay widgets/.
- Widget dùng chung nhận dữ liệu/callback, không import app.dart hoặc screen.
- State của form và màn hình vẫn nằm trong State của từng screen, chưa thêm framework state management.
- Báo cáo, danh mục và chi tiết tổng hợp vẫn dùng JSON ở phần hợp đồng linh hoạt. Người dùng, sinh viên, buổi học dạng danh sách, cảnh báo và đăng ký khuôn mặt đã có model cụ thể.

## Chạy và kiểm tra

Giữ nguyên cách chạy lib/main.dart. Có thể bấm trải nghiệm local hoặc chạy flutter run --dart-define=LOCAL_DEMO=true.

Chạy flutter analyze, flutter test và flutter build apk --debug để kiểm tra.

Test nằm trong test/. Bản sao ba file trước khi tách ở work/before-structure/ với đuôi .dart.txt, không tham gia biên dịch.
