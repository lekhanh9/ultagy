# Hướng dẫn Build & Sideload XNUProbeLab qua SideStore

## 1. Cấu trúc thư mục mã nguồn:
- `XNUProbeLab/Info.plist`: Cấu hình bundle, quyền ứng dụng.
- `XNUProbeLab/main.m`: Điểm khởi chạy ứng dụng iOS.
- `XNUProbeLab/AppDelegate.h / .m`: Khởi tạo cửa sổ Dark Mode.
- `XNUProbeLab/ViewController.h / .m`: Giao diện điều khiển và các hàm thăm dò XNU Kernel (Mach Ports, IOSurface).

---

## 2. Cách mở và Build bằng Xcode (trên Mac):
1. Mở Xcode, chọn **Create a new Xcode project** ➔ **App** (iOS, Objective-C).
2. Đặt tên Product Name là: `XNUProbeLab`.
3. Kéo toàn bộ các file trong thư mục `XNUProbeLab/` đè vào project Xcode.
4. Vào **Signing & Capabilities**:
   - Chọn Team Apple ID cá nhân của bạn.
   - Bundle Identifier: `com.khanh.xnuprobelab` (hoặc tuỳ chọn).
5. Thêm framework:
   - Vào mục **Build Phases** ➔ **Link Binary With Libraries** ➔ Thêm:
     - `IOSurface.framework`
6. Chọn thiết bị đích là **Any iOS Device (arm64)** ➔ Vào menu **Product** ➔ **Archive**.
7. Xuất file: Chọn **Distribute App** ➔ **Custom** ➔ **Development / Ad Hoc** ➔ Lưu file ra thành **`XNUProbeLab.ipa`**.

---

## 3. Cài đặt qua SideStore trên iPhone:
1. Gửi file `XNUProbeLab.ipa` sang iPhone (qua AirDrop, Google Drive hoặc lưu vào app Tệp/Files).
2. Mở app **SideStore** trên iPhone.
3. Bấm dấu **+** ở góc trên ➔ Chọn file `XNUProbeLab.ipa` vừa lưu.
4. SideStore sẽ tự động ký chứng chỉ (7 ngày) và cài trực tiếp lên màn hình chính.
5. Mở app lên và kiểm thử các tính năng Kernel an toàn!
