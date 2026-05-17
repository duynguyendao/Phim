# Phim - iOS App

Ứng dụng xem phim trên iPhone từ website https://tvhayd.pro/

## Tính năng

- ✅ Xem phim trực tiếp từ website tvhayd.pro
- ✅ Giao diện native iOS với SwiftUI
- ✅ Hỗ trợ phát video inline (không cần mở trình phát riêng)
- ✅ Điều hướng: Quay lại, Tiến tới, Tải lại
- ✅ Mở trong Safari nếu cần
- ✅ Hỗ trợ cử chỉ vuốt để điều hướng
- ✅ Thanh công cụ dưới cùng với các nút điều khiển

## Yêu cầu

- Xcode 15.0 trở lên
- iOS 15.0 trở lên
- macOS để build (hoặc sử dụng dịch vụ cloud build)

## Cách cài đặt

### 1. Mở project trong Xcode

```bash
cd Phim
open Phim.xcodeproj
```

### 2. Chọn thiết bị

- Chọn iPhone simulator hoặc thiết bị thật từ menu dropdown
- Nếu build cho thiết bị thật, cần cấu hình Apple Developer Account

### 3. Build và chạy

- Nhấn `Cmd + R` hoặc nút Play ▶️ trong Xcode
- App sẽ được cài đặt và chạy trên thiết bị đã chọn

## Cấu trúc dự án

```
Phim/
├── Phim.xcodeproj/          # Xcode project file
│   └── project.pbxproj
├── Phim/                     # Source code
│   ├── PhimApp.swift        # Main app entry point
│   ├── ContentView.swift    # WebView và UI chính
│   ├── Assets.xcassets/     # App icons và assets
│   └── Preview Content/     # Preview assets cho SwiftUI
└── README.md                # File này
```

## Tùy chỉnh

### Thay đổi URL website

Mở file `ContentView.swift` và sửa URL:

```swift
WebView(
    url: URL(string: "https://tvhayd.pro/")!,  // Thay đổi URL tại đây
    ...
)
```

### Thay đổi tên app

1. Mở `Phim.xcodeproj` trong Xcode
2. Chọn project trong Navigator
3. Trong tab General, sửa "Display Name"

### Thay đổi Bundle Identifier

Trong `project.pbxproj`, tìm và sửa:
```
PRODUCT_BUNDLE_IDENTIFIER = com.phim.app;
```

## Build cho Production

### 1. Cấu hình Signing

- Mở project settings
- Chọn tab "Signing & Capabilities"
- Chọn Team (cần Apple Developer Account)
- Xcode sẽ tự động tạo provisioning profile

### 2. Archive

```
Product > Archive
```

### 3. Distribute

- Chọn archive vừa tạo
- Chọn phương thức phân phối:
  - App Store Connect (để đưa lên App Store)
  - Ad Hoc (để test trên thiết bị cụ thể)
  - Enterprise (nếu có Enterprise account)
  - Development (để test)

## Lưu ý

- App này sử dụng WKWebView để hiển thị nội dung web
- Cần kết nối internet để sử dụng
- Video sẽ phát inline trong app (không cần mở trình phát riêng)
- Hỗ trợ cả iPhone và iPad

## Troubleshooting

### Lỗi "Failed to load"

- Kiểm tra kết nối internet
- Đảm bảo URL website đúng và hoạt động

### Lỗi Code Signing

- Cần Apple Developer Account để build cho thiết bị thật
- Có thể dùng simulator miễn phí

### Video không phát

- Kiểm tra cài đặt `mediaTypesRequiringUserActionForPlayback` trong ContentView.swift
- Một số video có thể yêu cầu tương tác người dùng

## License

Free to use and modify.

## Tác giả

Created with ❤️ for Vietnamese movie lovers
