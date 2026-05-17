@echo off
echo ========================================
echo  PUSH PHIM APP TO GITHUB
echo ========================================
echo.

set /p USERNAME="Nhap GitHub username cua ban: "

echo.
echo Dang them remote repository...
git remote add origin https://github.com/%USERNAME%/Phim.git

echo.
echo Dang push code len GitHub...
git push -u origin main

echo.
echo ========================================
echo  HOAN TAT!
echo ========================================
echo.
echo Truy cap: https://github.com/%USERNAME%/Phim
echo De xem GitHub Actions tu dong build IPA
echo.
pause
