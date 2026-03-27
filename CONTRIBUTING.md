# Contributing to Liora

Thank you for your interest in contributing to Liora! We welcome contributions from developers, designers, and community members. This document provides guidelines and instructions for contributing.

---

## 📋 Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Contribution Types](#contribution-types)
- [Submitting Changes](#submitting-changes)
- [Code Style Guide](#code-style-guide)
- [Testing Guidelines](#testing-guidelines)
- [Reporting Bugs](#reporting-bugs)
- [Requesting Features](#requesting-features)
- [Contact](#contact)

---

## 💼 Code of Conduct

This project adheres to a [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [alwinmadhu7@gmail.com](mailto:alwinmadhu7@gmail.com).

---

## 🚀 Getting Started

### Prerequisites
- Flutter 3.8+ installed
- Dart 3.0+ installed
- Git installed
- GitHub account
- Android SDK (for Android dev) or Xcode (for iOS dev)

### Fork and Clone
```bash
# 1. Fork the repository on GitHub
# 2. Clone your fork
git clone https://github.com/alwin-m/liora.git
cd liora

# 3. Add upstream remote
git remote add upstream https://github.com/alwin-m/liora.git
git remote -v  # Verify both origin and upstream
```

### Set Up Git Config (optional but recommended)
```bash
git config user.name "Your Name"
git config user.email "your.email@example.com"
```

---

## 🛠️ Development Setup

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Configure Firebase (if needed)
```bash
flutterfire configure
# Select platform (Android/iOS/both)
# This updates firebase_options.dart
```

### 3. Run on Emulator/Device
```bash
# List available devices
flutter devices

# Run on specific device
flutter run -d <device-id>

# Run in debug mode with VM service
flutter run --verbose
```

### 4. Run Tests
```bash
# All tests
flutter test

# Watch mode (re-run on changes)
flutter test --watch

# With coverage
flutter test --coverage
```

---

## 🎯 Contribution Types

### 1. Bug Fixes
- Create an issue first (if not already reported)
- Reference the issue in your PR: `Fixes #123`
- Include test cases for the fix
- Update CHANGELOG.md

### 2. New Features
- Discuss in an issue before starting work
- Follow the feature branch naming: `feature/your-feature-name`
- Update README.md if user-facing
- Add tests and documentation
- Update CHANGELOG.md

### 3. Documentation
- Fix typos, clarify explanations
- Add missing documentation
- Create examples
- Update comments in code

### 4. Code Quality
- Add tests to improve coverage
- Refactor complex functions
- Fix linting issues
- Improve performance

### 5. Translation
- Help translate UI strings for international users
- Create new `intl_*.arb` files for your language

---

## 📝 Submitting Changes

### Step 1: Create a Feature Branch
```bash
# Ensure you're on main and up to date
git checkout main
git fetch upstream
git merge upstream/main

# Create your feature branch
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### Step 2: Make Your Changes
- Make small, logical commits
- Write clear commit messages following the pattern:
  ```
  feat: Add dark mode toggle to settings screen
  fix: Resolve crash when importing backup with invalid JSON
  docs: Update README installation instructions
  test: Add unit tests for cycle algorithm
  ```

### Step 3: Commit and Push
```bash
# Stage your changes
git add .

# Commit with clear message
git commit -m "feat: Add cycle history export as CSV"

# Push to your fork
git push origin feature/your-feature-name
```

### Step 4: Create a Pull Request
1. Go to GitHub and click "Compare & pull request"
2. Fill in the PR template with:
   - **Description**: What does this change do?
   - **Related Issues**: Link to issue #123
   - **Type**: Bug fix / Feature / Docs / etc.
   - **Testing**: How did you test this?
   - **Screenshots**: (if UI changes)
3. Click "Create Pull Request"

### Step 5: Code Review
- Respond to review comments
- Make requested changes with new commits
- Push updates: `git push origin feature/your-feature-name`
- Re-request review after making changes

### Step 6: Merge
Once approved, maintainers will merge your PR. Your branch will be deleted automatically.

---

## 📐 Code Style Guide

### Dart/Flutter Standards
Follow [Effective Dart](https://dart.dev/guides/language/effective-dart):

### Naming Conventions
```dart
// Classes: PascalCase
class CycleSession { }
class AdvancedCycleProfile { }

// Functions/methods: camelCase
void saveCycleData() { }
Future<void> loadProfile() async { }

// Constants: camelCase
const int defaultCycleLength = 28;
const String profileKey = "advanced_cycle_profile";

// Variables: camelCase
String userName = "Alice";
List<CycleRecord> historyData = [];
```

### File Organization
```dart
// 1. Imports (dart, packages, project)
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/cycle_record.dart';

// 2. Constants
const String _profileKey = "profile";

// 3. Class definition
class MyClass {
  // Fields
  final String name;
  
  // Constructor
  const MyClass({required this.name});
  
  // Getters
  String get displayName => name.toUpperCase();
  
  // Setters
  set newName(String value) => _name = value;
  
  // Methods (public first, then private)
  void publicMethod() { }
  void _privateMethod() { }
}
```

### Formatting
```bash
# Format all Dart files
dart format --fix lib/
# or
flutter format lib/

# Run linter
dart analyze lib/
# or
flutter analyze
```

### Comments & Documentation
```dart
/// Calculates the next predicted period date.
/// 
/// Uses the [profile]'s average cycle length and [lastPeriodDate]
/// to predict when the next period will start.
/// 
/// Returns a [DateTime] representing the predicted date.
DateTime getNextPeriodDate(AdvancedCycleProfile profile) {
  return profile.lastPeriodDate.add(
    Duration(days: profile.averageCycleLength),
  );
}
```

---

## 🧪 Testing Guidelines

### Unit Tests
Test business logic, models, services:
```dart
// test/core/cycle_algorithm_test.dart
void main() {
  group('CycleAlgorithm', () {
    test('calculates next period correctly', () {
      final profile = AdvancedCycleProfile(
        lastPeriodDate: DateTime(2024, 1, 1),
        averageCycleLength: 28,
        // ... other fields
      );
      
      final algorithm = CycleAlgorithm(profile: profile);
      final nextPeriod = algorithm.getNextPeriodDate();
      
      expect(nextPeriod, DateTime(2024, 1, 29));
    });
  });
}
```

### Widget Tests
Test UI components:
```dart
void main() {
  testWidgets('Period button displays correctly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.byType(ElevatedButton), findsOneWidget);
    expect(find.text('Log Period'), findsOneWidget);
  });
}
```

### Test Coverage
Aim for >80% coverage:
```bash
flutter test --coverage
open coverage/lcov-report/index.html  # View coverage report
```

### Before Submitting
```bash
# Run all checks
flutter analyze
flutter test
flutter test --coverage
```

---

## 🐛 Reporting Bugs

### Before Reporting
- Check [existing issues](https://github.com/alwin-m/liora/issues)
- Test with the latest code
- Reproduce the issue consistently

### Reporting Template
```markdown
**Describe the bug:**
A clear description of what the bug is.

**To Reproduce:**
1. Go to '...'
2. Click on '...'
3. See error

**Expected behavior:**
What should happen.

**Actual behavior:**
What actually happens.

**Environment:**
- Device: [e.g., Samsung Galaxy S21]
- OS: [e.g., Android 12]
- App Version: [e.g., 1.0.0]
- Flutter: [e.g., 3.8.0]

**Logs/Screenshots:**
[Attach relevant logs or screenshots]

**Additional context:**
Any other context.
```

---

## 💡 Requesting Features

### Feature Request Template
```markdown
**Is your feature request related to a problem?**
Describe the problem. Ex. I'm always frustrated when...

**Describe the solution you'd like:**
Clear and concise description of what you want to happen.

**Describe alternatives you've considered:**
Any alternative solutions or features you've considered.

**Use Case:**
Who would benefit? Why is this important?

**Additional context:**
Add mockups, wireframes, or examples.
```

---

## 📊 Development Workflow

```
main (stable)
├─ feature/new-feature-1 (PR #123)
│  └─ Merged after review
├─ bugfix/issue-456 (PR #124)
│  └─ Merged after review
└─ docs/update-readme (PR #125)
   └─ Merged after review
```

### Keeping Your Fork Updated
```bash
# Fetch latest from upstream
git fetch upstream

# Rebase your branch
git rebase upstream/main

# Force push to your fork
git push origin feature/your-feature -f
```

---

## 🚫 What NOT to Do

- ❌ Don't commit credentials, API keys, or secrets
- ❌ Don't make large refactors without discussing first
- ❌ Don't submit PRs without tests
- ❌ Don't ignore code review feedback
- ❌ Don't commit directly to main branch
- ❌ Don't create PRs for unrelated changes
- ❌ Don't remove or significantly alter existing features without discussion

---

## ✅ Checklist Before Submitting PR

- [ ] Branch is up-to-date with `upstream/main`
- [ ] Code follows style guide
- [ ] All tests pass: `flutter test`
- [ ] Code is well-commented
- [ ] No console errors or warnings
- [ ] Commit messages are clear
- [ ] PR description explains changes
- [ ] Related issue is referenced (#123)
- [ ] CHANGELOG.md is updated
- [ ] Screenshots/videos included (if UI changes)

---

## 📚 Documentation Structure

```
docs/
├─ ARCHITECTURE.md     # System design
├─ API.md             # API documentation
├─ DEVELOPMENT.md     # Dev setup & workflow
├─ SECURITY.md        # Security practices
├─ PRIVACY.md         # Privacy policy
└─ TROUBLESHOOTING.md # Common issues
```

---

## 🎁 Recognition

Contributors will be recognized in:
- [CONTRIBUTORS.md](CONTRIBUTORS.md)
- GitHub release notes
- Project website

---

## ❓ Questions?

**Contact the maintainers:**
- 📧 Email: [alwinmadhu7@gmail.com](mailto:alwinmadhu7@gmail.com)
- 💬 GitHub Discussions: [Discussions](https://github.com/alwin-m/liora/discussions)
- 🐛 GitHub Issues: [Issues](https://github.com/alwin-m/liora/issues)

---

## 📜 License

By contributing to Liora, you agree that your contributions will be licensed under the same [LICENSE.md](LICENSE.md) as the project.

---

**Thank you for contributing to Liora! Together we're building better health tools with privacy at the core.** 🌸

