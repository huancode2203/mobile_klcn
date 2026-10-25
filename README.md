# HTBAM Mobile

Ứng dụng Flutter tại E:\Mobile_KLCN, dùng API của newFrontEndHTBAM.

## Cấu trúc mã nguồn

- lib/screens/: giao diện, mỗi màn hình một file.
- lib/widgets/: các thành phần giao diện dùng chung.
- lib/models/: dữ liệu có kiểu và chuyển đổi JSON.
- lib/services/: kết nối API và thao tác nghiệp vụ.
- lib/data/demo/: dữ liệu minh họa.
- lib/core/: theme, màu, lỗi và tiện ích.
- lib/main.dart và lib/app.dart: khởi chạy và quản lý phiên ứng dụng.

Xem ARCHITECTURE.md để biết cây thư mục, luồng dữ liệu và cách thêm chức năng.

## Chạy local ngay, chưa cần backend

1. Mở dự án E:\Mobile_KLCN bằng Android Studio.
2. Chọn Chrome hoặc Android Emulator/điện thoại (không chọn Windows desktop nếu chưa cài bộ C++).
3. Run lib/main.dart.
4. Ở màn hình đăng nhập, bấm **Trải nghiệm local · không cần máy chủ**.

Chế độ local có sinh viên, buổi học, hành vi và cảnh báo minh họa. Bạn có thể tạo/bắt đầu/kết thúc/hủy buổi, xử lý cảnh báo và thử thu ảnh khuôn mặt. Mọi thay đổi chỉ trong bộ nhớ, mất khi đóng demo. Ảnh demo chỉ lưu tên và góc chụp, không tải ảnh lên đâu. Không có AI thực chạy. PDF/Excel và nhận xét AI thật cần backend.

## Kết nối backend sau này

Tại màn hình đăng nhập ban đầu, nhập địa chỉ gốc (không cần /api), tài khoản và mật khẩu đã được cấp:
- Android Emulator: http://10.0.2.2:8080 (thay 8080 bằng cổng backend thực tế).
- Điện thoại thật: http://<IP-máy-chủ>:<cổng>, cùng Wi-Fi hoặc VPN.
- Máy tính: http://localhost:<cổng>.

Cổng 8080 chỉ là ví dụ. Bản debug Android cho phép HTTP local; bản phát hành cần HTTPS. Flutter web còn cần backend cho phép CORS của địa chỉ web chạy thử.

JWT lưu qua flutter_secure_storage. Giao diện lấy role, permissions và phạm vi từ /api/auth/me; quyền cuối cùng vẫn do backend kiểm tra. ADMIN chỉ vào khu quản trị; không mặc định có quyền học vụ.

## Chức năng bản hiện tại

- Đăng nhập, khôi phục phiên, đăng xuất, đổi mật khẩu.
- Tổng quan, lọc và tạo buổi học (camera hoặc video đã có), start/stop/cancel/retry-finalize theo quyền.
- Chi tiết buổi và snapshot mỗi 10 giây khi trạng thái đang chạy; làm mới khi quay lại ứng dụng.
- Tra cứu sinh viên, hồ sơ, đăng ký khuôn mặt bằng camera/thư viện, gửi và yêu cầu AI xử lý.
- Cảnh báo: xác nhận, đóng/mở lại và ghi chú.
- Báo cáo buổi/sinh viên/lớp, lưu/chia sẻ PDF/Excel qua backend, tạo nhận xét buổi/lớp.
- Xem lịch sử hành vi/nhận diện, chính sách, trạng thái, cơ cấu; quản trị viên xem tài khoản/camera/phòng/audit.

Chưa triển khai: SignalR (đang polling), thông báo đẩy, phát live camera, CRUD quản trị/học vụ đầy đủ, phân công dạy thay, upload video và sửa roster. Các danh sách quản trị và một số báo cáo đang dùng dạng thẻ dữ liệu, chưa phải màn hình biên tập chuyên biệt.

## Môi trường Android trên máy hiện tại

Flutter: E:\Mobile\flutter_windows_3.47.8-stable\flutter
SDK Android: C:\Users\Lenovo\AppData\Local\Android\sdk

flutter doctor phát hiện thiếu Android SDK Command-line Tools và chưa xác nhận license. Trong Android Studio: Settings > Languages & Frameworks > Android SDK > SDK Tools > Android SDK Command-line Tools (latest), cài xong chạy flutter doctor --android-licenses và tự đọc/chấp nhận điều khoản. Không cần bộ C++ Windows nếu chỉ chạy Android/Chrome.

## Kiểm tra

flutter analyze
flutter test
flutter build apk --debug

iOS đã thêm mô tả quyền camera/thư viện; cần macOS/Xcode để build và kiểm thử. Android release vẫn dùng signing debug của template, chưa dành phát hành lên store.

## Kết quả kiểm tra bản local (25/10/2026)

- flutter analyze: không có lỗi/cảnh báo.
- flutter test: 8 bài kiểm tra thành công (API/phân quyền/phiên đăng nhập và màn hình/luồng local).
- flutter build apk --debug: thành công.
- APK: build/app/outputs/flutter-apk/app-debug.apk.
- Đã xem trực tiếp giao diện đăng nhập, tổng quan, danh sách và chi tiết buổi học qua trình duyệt local.
- Chưa kiểm thử trên điện thoại Android thật hoặc backend thật.
- Đã tắt Kotlin incremental cache và dùng in-process compiler để tránh lỗi cache giữa ổ E (dự án) và ổ C (Pub cache).
- Có thể chạy thẳng demo với flutter run --dart-define=LOCAL_DEMO=true; hoặc bấm nút trải nghiệm local trên màn hình đăng nhập.
- Trong demo, Tài khoản > Kết nối backend thật mở màn hình đăng nhập máy chủ.

Sau khi tách cấu trúc: flutter analyze sạch, 11 bài kiểm tra qua, build APK debug thành công. Màn hình và các luồng nghiệp vụ hiện có được giữ lại.

