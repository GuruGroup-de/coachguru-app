#!/bin/bash

# GitHub Push Script for CoachGuru App
# Run this AFTER creating the repository on GitHub

echo "🚀 CoachGuru GitHub Push Script"
echo "================================"
echo ""

# Check if remote already exists
if git remote get-url origin > /dev/null 2>&1; then
    echo "✅ Remote 'origin' already configured"
    git remote -v
    echo ""
    read -p "Do you want to push now? (y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git push -u origin main
        echo ""
        echo "✅ Push completed!"
        echo "🌐 Repository URL: $(git remote get-url origin | sed 's/\.git$//')"
    fi
else
    echo "📝 Please provide your GitHub repository URL:"
    echo "   Example: https://github.com/YOUR_USERNAME/coachguru-app.git"
    read -p "Repository URL: " REPO_URL
    
    if [ -z "$REPO_URL" ]; then
        echo "❌ No URL provided. Exiting."
        exit 1
    fi
    
    echo ""
    echo "🔗 Adding remote repository..."
    git remote add origin "$REPO_URL"
    
    echo ""
    echo "📤 Pushing to GitHub..."
    git push -u origin main
    
    if [ $? -eq 0 ]; then
        echo ""
        echo "✅ Successfully pushed to GitHub!"
        echo "🌐 Repository URL: ${REPO_URL%.git}"
        echo ""
        echo "📋 Next steps:"
        echo "   1. Visit your repository on GitHub"
        echo "   2. Verify all files are present"
        echo "   3. Check that build/ and .dart_tool/ are NOT visible"
        echo "   4. Set up branch protection (optional)"
    else
        echo ""
        echo "❌ Push failed. Please check:"
        echo "   1. Repository exists on GitHub"
        echo "   2. You have write access"
        echo "   3. Authentication credentials are correct"
        echo ""
        echo "💡 Tip: Use a Personal Access Token instead of password"
        echo "   Create at: https://github.com/settings/tokens"
    fi
fi

