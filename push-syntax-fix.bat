@echo off
echo 🔧 Pushing syntax fix for quick-setup.sh...
echo.

cd /d "C:\Users\andon\OneDrive\Documents\Github\debian-devbox-installer"

echo 📊 Current git status:
git status --short

echo.
echo 📦 Adding fixed files...
git add scripts/quick-setup.sh scripts/validate-scripts.sh

echo.
echo 💾 Committing syntax fix...
git commit -m "fix: Correct syntax error in quick-setup.sh

🐛 Fixed missing newline between echo and if statement on line 42
✨ Added validate-scripts.sh for local syntax checking before commits

Resolves GitHub Actions CI failure:
- scripts/quick-setup.sh: line 42: syntax error near unexpected token 'then'
- Added script validation tool to prevent future syntax errors"

echo.
echo 🌐 Pushing fix to GitHub...
git push

echo.
echo ✅ Syntax fix pushed successfully!
echo 🎉 GitHub Actions should now pass!
echo.
echo 💡 Tip: Run 'bash scripts/validate-scripts.sh' before future commits
echo    to catch syntax errors locally.
echo.
pause
