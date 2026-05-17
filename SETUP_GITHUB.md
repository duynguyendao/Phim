# Hướng dẫn Push lên GitHub và Auto-Build

## Bước 1: Tạo Repository trên GitHub

1. Truy cập: **https://github.com/new**
2. Điền thông tin:
   - Repository name: `Phim` (hoặc tên bạn muốn)
   - Description: `iOS app để xem phim từ tvhayd.pro`
   - Chọn: **Public** (để GitHub Actions miễn phí)
   - **KHÔNG** chọn "Add a README file"
   - **KHÔNG** chọn "Add .gitignore"
   - **KHÔNG** chọn "Choose a license"
3. Click **"Create repository"**

## Bước 2: Liên kết và Push

Sau khi tạo repo, GitHub sẽ hiển thị các lệnh. Chạy các lệnh sau trong thư mục Phim:

```bash
# Thêm remote (thay YOUR_USERNAME bằng username GitHub của bạn)
git remote add origin https://github.com/YOUR_USERNAME/Phim.git

# Push code lên GitHub
git push -u origin main
```

### Ví dụ cụ thể:

Nếu username GitHub của bạn là `duynguyen`, thì chạy:

```bash
git remote add origin https://github.com/duynguyen/Phim.git
git push -u origin main
```

## Bước 3: Xác nhận GitHub Actions đang chạy

1. Truy cập repo của bạn trên GitHub
2. Click tab **"Actions"**
3. Bạn sẽ thấy workflow "Build iOS App (Unsigned)" đang chạy
4. Đợi khoảng 5-10 phút để build hoàn tất

## Bước 4: Tải IPA file

Sau khi build xong, có 2 cách tải IPA:

### Cách 1: Từ Artifacts (mọi commit)
1. Vào tab **Actions**
2. Click vào workflow run mới nhất
3. Scroll xuống phần **Artifacts**
4. Tải file **Phim-unsigned-ipa**

### Cách 2: Từ Releases (chỉ khi push vào main)
1. Vào tab **Releases** 
2. Click vào release mới nhất
3. Tải file **Phim-unsigned.ipa**

## Bước 5: Cài đặt IPA lên iPhone

Sử dụng một trong các công cụ sau:

### Option 1: AltStore (Khuyên dùng - Miễn phí)
1. Cài AltStore trên máy tính: https://altstore.io/
2. Cài AltStore app lên iPhone
3. Mở AltStore trên iPhone > My Apps > + > Chọn file IPA
4. Ứng dụng sẽ được cài đặt

### Option 2: Sideloadly (Dễ dùng)
1. Tải Sideloadly: https://sideloadly.io/
2. Kết nối iPhone với máy tính
3. Kéo thả file IPA vào Sideloadly
4. Đăng nhập Apple ID và cài đặt

### Option 3: Xcode (Nếu có Mac)
1. Mở Xcode
2. Window > Devices and Simulators
3. Chọn iPhone của bạn
4. Kéo thả file IPA vào danh sách apps

### Option 4: Sign lại với certificate của bạn
Nếu bạn có Apple Developer Account, có thể sign lại IPA với certificate của mình.

## Lưu ý quan trọng

⚠️ **App sẽ hết hạn sau 7 ngày** (nếu dùng free Apple ID)
- Cần re-sign lại sau 7 ngày
- Hoặc dùng Apple Developer Account ($99/năm) để app không hết hạn

✅ **Mỗi lần push code mới lên GitHub:**
- GitHub Actions sẽ tự động build IPA mới
- IPA mới sẽ có trong Artifacts/Releases
- Không cần build thủ công trên máy Mac

## Troubleshooting

### Lỗi: "remote origin already exists"
```bash
git remote remove origin
git remote add origin https://github.com/YOUR_USERNAME/Phim.git
```

### Lỗi: "failed to push some refs"
```bash
git pull origin main --rebase
git push -u origin main
```

### GitHub Actions không chạy
- Kiểm tra tab Actions có bị disable không
- Vào Settings > Actions > General > Allow all actions

## Liên hệ

Nếu cần hỗ trợ, tạo Issue trên GitHub repo.

---

**Chúc bạn thành công! 🎉**
