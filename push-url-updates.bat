@echo off
echo 🔗 Updating repository URLs and documentation...
echo.

cd /d "C:\Users\andon\OneDrive\Documents\Github\debian-devbox-installer"

echo 📊 Current git status:
git status --short

echo.
echo 📦 Adding all updated files...
git add README.md .github/CODEOWNERS docs/REPOSITORY_SETUP.md

echo.
echo 💾 Committing URL updates...
git commit -m "docs: Update repository URLs and documentation

🔗 Repository URL Updates:
- Updated README.md with correct GitHub repository URL
- Added professional badges for build status, license, and metrics
- Enhanced Quick Start with multiple installation options
- Added direct download options for quick testing

👤 Username Updates:
- Updated CODEOWNERS with correct GitHub username (@axewerfer)
- Fixed placeholder URLs in REPOSITORY_SETUP.md

✨ Documentation Improvements:
- Added build status badges and repository metrics
- Enhanced installation instructions with alternatives
- Professional repository presentation

Repository: https://github.com/axewerfer/debian-devbox-installer"

echo.
echo 🌐 Pushing documentation updates to GitHub...
git push

echo.
echo ✅ Documentation updated successfully!
echo 🎉 Repository now has correct URLs and professional presentation!
echo.
echo 📋 Next steps:
echo   1. Your repository is now properly configured
echo   2. All URLs point to the correct GitHub repository
echo   3. Installation instructions are ready for users
echo   4. Professional badges show build status and metrics
echo.
pause
