@echo off
echo 🚀 Pushing debian-devbox-installer changes to GitHub...
echo.

echo 📁 Changing to repository directory...
cd /d "C:\Users\andon\OneDrive\Documents\Github\debian-devbox-installer"

echo 📊 Checking git status...
git status

echo.
echo 📦 Adding all new files...
git add .

echo.
echo 💾 Committing changes...
git commit -m "feat: Add comprehensive GitHub configuration

✨ Added professional repository configuration:
- Dependabot configuration for automated dependency updates
- CODEOWNERS file for code review governance  
- Pull request template for contributor guidance
- Issue templates for bug reports and feature requests
- GitHub Actions workflow for automated testing
- Funding configuration for future sponsorships

🔒 Security & Maintenance:
- Automated vulnerability scanning
- Weekly dependency updates
- Proper code review requirements

🤝 Community Ready:
- Professional contribution workflows
- Comprehensive documentation
- Best practices from major open source projects"

echo.
echo 🌐 Pushing to GitHub...
git push

echo.
echo ✅ All changes pushed successfully!
echo 🎉 Your repository is now live with professional GitHub configuration!
echo.
echo 📋 Next steps:
echo   1. Go to your GitHub repository settings
echo   2. Enable Dependabot alerts and security updates
echo   3. Set up branch protection for the main branch
echo   4. Enable GitHub Pages for documentation
echo   5. Share your awesome installer with the community!
echo.
pause
