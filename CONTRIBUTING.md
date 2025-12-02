# Contributing to CoachGuru

Thank you for your interest in contributing to CoachGuru! This document provides guidelines and instructions for contributing to the project.

---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.24 or higher)
- [Dart SDK](https://dart.dev/get-dart) (3.0 or higher)
- [Git](https://git-scm.com/downloads)
- Android Studio / Xcode (for platform-specific development)
- A code editor (VS Code, Android Studio, or IntelliJ IDEA recommended)

### Clone and Run the Project

1. **Fork the repository**
   ```bash
   # Click the "Fork" button on GitHub
   ```

2. **Clone your fork**
   ```bash
   git clone https://github.com/YOUR_USERNAME/coachguru-app.git
   cd coachguru-app
   ```

3. **Add upstream remote**
   ```bash
   git remote add upstream https://github.com/GuruGroup-de/coachguru-app.git
   ```

4. **Install dependencies**
   ```bash
   flutter pub get
   ```

5. **Run the app**
   ```bash
   # On connected device/emulator
   flutter run

   # On specific platform
   flutter run -d android
   flutter run -d ios
   flutter run -d web
   ```

6. **Verify everything works**
   - The app should launch without errors
   - All features should be accessible
   - No console errors or warnings

---

## 🌿 Branch Naming Rules

We follow a consistent branch naming convention:

### Format
```
<type>/<short-description>
```

### Types

- `feature/` - New features or enhancements
  - Example: `feature/add-dark-mode`
  - Example: `feature/player-export-functionality`

- `fix/` - Bug fixes
  - Example: `fix/navigation-crash`
  - Example: `fix/attendance-calculation-error`

- `refactor/` - Code refactoring (no feature changes or bug fixes)
  - Example: `refactor/player-provider-cleanup`
  - Example: `refactor/theme-consolidation`

- `docs/` - Documentation changes
  - Example: `docs/update-readme`
  - Example: `docs/add-api-documentation`

- `style/` - Code style changes (formatting, missing semicolons, etc.)
  - Example: `style/format-codebase`

- `test/` - Adding or updating tests
  - Example: `test/add-player-provider-tests`

- `chore/` - Maintenance tasks (dependencies, build config, etc.)
  - Example: `chore/update-flutter-version`
  - Example: `chore/add-ci-cd-pipeline`

### Examples

✅ **Good branch names:**
- `feature/training-statistics-chart`
- `fix/scouting-note-save-error`
- `refactor/match-provider-optimization`
- `docs/contributing-guidelines`

❌ **Bad branch names:**
- `new-feature` (missing type prefix)
- `fix-bug` (should use `/` separator)
- `my-changes` (too vague)
- `update` (not descriptive)

---

## 📝 Commit Message Style

We use [Conventional Commits](https://www.conventionalcommits.org/) specification for commit messages.

### Format
```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

- `feat`: A new feature
- `fix`: A bug fix
- `docs`: Documentation only changes
- `style`: Changes that do not affect the meaning of the code
- `refactor`: A code change that neither fixes a bug nor adds a feature
- `perf`: A code change that improves performance
- `test`: Adding missing tests or correcting existing tests
- `chore`: Changes to the build process or auxiliary tools

### Scope (Optional)

The scope should be the area of the codebase affected:
- `player` - Player management features
- `match` - Match history and statistics
- `scouting` - Scouting reports
- `tactic` - Tactic board
- `training` - Training management
- `ui` - User interface changes
- `theme` - Theme and styling
- `provider` - State management
- `docs` - Documentation

### Subject

- Use imperative, present tense: "add" not "added" nor "adds"
- Don't capitalize the first letter
- No period (.) at the end
- Maximum 72 characters

### Body (Optional)

- Explain the "what" and "why" vs. "how"
- Wrap at 72 characters
- Can include multiple paragraphs

### Footer (Optional)

- Reference issues: `Fixes #123`, `Closes #456`
- Breaking changes: `BREAKING CHANGE: <description>`

### Examples

✅ **Good commit messages:**

```
feat(player): add player photo upload functionality

Implement image picker integration for player avatars.
Users can now select photos from gallery or camera.

Closes #42
```

```
fix(scouting): resolve navigation black screen issue

Replace Navigator.pop with NavHelper.safePop to prevent
black screen when returning from scouting screens.

Fixes #78
```

```
docs(readme): update installation instructions

Add Flutter version requirements and platform-specific
setup steps for Android and iOS.
```

```
refactor(theme): consolidate color definitions

Move all color constants to CoachGuruTheme class for
better maintainability and consistency.
```

❌ **Bad commit messages:**

```
Fixed bug
```

```
update code
```

```
feat: added new feature
```

```
fix(player): Fixed the player screen bug that was causing crashes when you tried to add a new player and the form validation wasn't working properly
```

---

## 🐛 Reporting Issues

### Before Reporting

1. **Search existing issues** - Check if the issue has already been reported
2. **Check documentation** - Ensure the issue isn't covered in the docs
3. **Test latest version** - Verify the issue exists in the latest code

### Issue Template

When creating an issue, please include:

**Title Format:**
```
[Type] Brief description
```

Types: `Bug`, `Feature Request`, `Enhancement`, `Documentation`, `Question`

**Body:**
```markdown
## Description
Clear and concise description of the issue or feature request.

## Steps to Reproduce (for bugs)
1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior
What you expected to happen.

## Actual Behavior
What actually happened.

## Screenshots
If applicable, add screenshots to help explain.

## Environment
- Flutter Version: [e.g., 3.24.0]
- Dart Version: [e.g., 3.0.0]
- Platform: [e.g., Android 13, iOS 17]
- Device: [e.g., Pixel 7, iPhone 14]

## Additional Context
Any other relevant information.
```

---

## 🔀 Submitting Pull Requests

### Before Submitting

1. **Update your fork**
   ```bash
   git fetch upstream
   git checkout main
   git merge upstream/main
   ```

2. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

3. **Make your changes**
   - Write clean, readable code
   - Follow existing code style
   - Add comments where necessary
   - Update documentation if needed

4. **Test your changes**
   ```bash
   # Run tests
   flutter test

   # Check for linting issues
   flutter analyze

   # Test on device/emulator
   flutter run
   ```

5. **Commit your changes**
   ```bash
   git add .
   git commit -m "feat(scope): your commit message"
   ```

6. **Push to your fork**
   ```bash
   git push origin feature/your-feature-name
   ```

### Pull Request Template

**Title:**
```
[Type] Brief description
```

**Description:**
```markdown
## Description
Brief description of changes.

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Related Issues
Closes #123
Fixes #456

## Changes Made
- Change 1
- Change 2
- Change 3

## Testing
- [ ] Tests pass locally
- [ ] Tested on Android
- [ ] Tested on iOS
- [ ] Tested on Web

## Screenshots (if applicable)
Add screenshots here.

## Checklist
- [ ] Code follows project style guidelines
- [ ] Self-review completed
- [ ] Comments added for complex code
- [ ] Documentation updated
- [ ] No new warnings generated
- [ ] Tests added/updated
- [ ] All tests pass
```

### PR Review Process

1. **Automated Checks**
   - Code must pass all CI/CD checks
   - No linting errors
   - All tests must pass

2. **Code Review**
   - At least one maintainer must approve
   - Address all review comments
   - Keep PR focused (one feature/fix per PR)

3. **Merge**
   - Maintainer will merge after approval
   - PR will be squashed and merged (if applicable)

---

## 📋 Code Style Guidelines

### Dart/Flutter Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use `dart format` before committing
- Run `flutter analyze` to check for issues

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Functions**: `camelCase`
- **Constants**: `UPPER_SNAKE_CASE`

### Code Organization

```dart
// 1. Imports (dart: imports first, then package:, then relative)
import 'dart:async';

import 'package:flutter/material.dart';

import '../models/player_model.dart';

// 2. Class definition
class PlayerProvider extends ChangeNotifier {
  // 3. Private fields
  List<PlayerModel> _players = [];
  
  // 4. Public getters
  List<PlayerModel> get players => List.unmodifiable(_players);
  
  // 5. Constructor
  PlayerProvider() {
    _initialize();
  }
  
  // 6. Private methods
  void _initialize() {
    // Implementation
  }
  
  // 7. Public methods
  void addPlayer(PlayerModel player) {
    // Implementation
  }
}
```

---

## 🧪 Testing

### Writing Tests

- Write unit tests for providers and business logic
- Write widget tests for UI components
- Aim for >80% code coverage

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/player/player_provider_test.dart

# Run with coverage
flutter test --coverage
```

---

## 📚 Documentation

- Update README.md if adding new features
- Add code comments for complex logic
- Update API documentation if changing interfaces
- Keep CHANGELOG.md updated (if applicable)

---

## ❓ Questions?

- Open a [GitHub Discussion](https://github.com/GuruGroup-de/coachguru-app/discussions)
- Check existing [Issues](https://github.com/GuruGroup-de/coachguru-app/issues)
- Contact: [Instagram @coachguru1](https://www.instagram.com/coachguru1)

---

## 🙏 Thank You!

Your contributions make CoachGuru better for everyone. We appreciate your time and effort!

---

**Happy Coding! ⚽**

