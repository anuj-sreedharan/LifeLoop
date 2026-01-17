# AGENTS.md - Lifeloop iOS App

This document provides guidelines for AI coding agents working in this repository.

## App Domain Rules

- Lifeloop is a **personal hourly activity logger**
- Core features:
  - Hourly activity logging (24-hour timeline)
  - Skincare routines (AM/PM)
  - Spending awareness (simple logging)
  - Dashboard (daily overview)
  - Reminders & notifications
- Lifeloop is NOT a task/todo app or budgeting app
- Do NOT add:
  - Social features
  - Cloud sync (unless explicitly requested)
  - Authentication or user accounts
  - Task/todo functionality
  - Budget limits, alerts, or financial warnings

## Notifications

- Use `UNUserNotificationCenter` for reminders
- Request permission explicitly and gracefully
- Notification scheduling must be idempotent
- Avoid scheduling duplicate notifications

### Skincare Reminders (Fixed Times)
- AM reminder at 08:00
- PM reminder at 21:00
- Only fire if slot is "Not logged"
- Do NOT send reminders for Completed or Skipped slots

## Spending

- Spending is for **awareness only**, NOT budgeting
- Do NOT add:
  - Budget limits or caps
  - Spending alerts or warnings
  - Financial advice or judgments
  - Category budgets
- UI should be calm and non-judgmental
- Fixed categories (9 total): Food & Drinks, Transport, Shopping, Rent/Bills, Subscriptions, Health, Travel, Social, Misc
- Dashboard shows totals and averages without judgment

## CoreData Migration

- Do NOT delete or rename entities without a migration plan
- Prefer lightweight migrations
- Changes to the data model must be backward compatible

## Git & Commit Rules

- Commit after each logical change
- Do NOT bundle unrelated changes in a single commit
- Commits should compile successfully
- Commit messages must be clear and descriptive

### Commit Message Format
- Use present tense
- Start with a verb

Examples:
- `Add skincare routine entity`
- `Fix reminder scheduling bug`
- `Refactor PersistenceController`


## UI Principles

- Prefer native SwiftUI components
- Avoid over-animated or distracting UI
- UI should feel calm, minimal, and routine-focused
- Accessibility (Dynamic Type, VoiceOver) is a priority


## Decision Rule

When unsure:
- Prefer simplicity over abstraction
- Prefer SwiftUI-native solutions
- Ask for clarification rather than guessing


## Project Overview

- **Language:** Swift 5.0
- **Framework:** SwiftUI (iOS)
- **Persistence:** CoreData
- **Minimum iOS Version:** 26.2
- **Build System:** Xcode


## Build Commands

### Build the project
```bash
xcodebuild -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Build for release
```bash
xcodebuild -scheme Lifeloop -configuration Release -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Clean build folder
```bash
xcodebuild -scheme Lifeloop clean
```

## Testing

### Run all tests
```bash
xcodebuild test -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Run a single test class
```bash
xcodebuild test -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:LifeloopTests/TestClassName
```

### Run a single test method
```bash
xcodebuild test -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:LifeloopTests/TestClassName/testMethodName
```

### Run tests with verbose output
```bash
xcodebuild test -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16' | xcpretty
```

Note: Test targets need to be added to the project. When adding tests, create `LifeloopTests` target.

## Directory Structure

```
Lifeloop/
├── AGENTS.md                # AI agent guidelines (this file)
├── Lifeloop/
│   ├── Assets.xcassets/     # Images, colors, app icon
│   ├── Lifeloop.xcdatamodeld/ # CoreData model (HourlyActivityEntry, SkincareEntry, SpendingEntry)
│   ├── ActivityType.swift   # Centralized activity type enum
│   ├── ContentView.swift    # Main views (Home, Skincare, History, Edit)
│   ├── DashboardView.swift  # Dashboard with daily overview
│   ├── LifeloopApp.swift    # App entry point (@main)
│   ├── NotificationManager.swift # Reminder scheduling
│   ├── Persistence.swift    # CoreData persistence layer + preview data
│   ├── SkincareSlotStatus.swift # Skincare slot status and time of day enums
│   ├── SpendingCategory.swift # Spending category enum
│   └── SpendingView.swift   # Spending history and add/edit views
└── Lifeloop.xcodeproj/      # Xcode project configuration
```

## Code Style Guidelines

### File Organization

1. Each Swift file should have a single primary type
2. Use standard Xcode file header with filename, project, author, and date
3. Group related functionality using `// MARK: -` comments

### Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Files | PascalCase | `ContentView.swift` |
| Types/Structs/Classes | PascalCase | `PersistenceController` |
| Protocols | PascalCase | `DataProvider` |
| Functions/Methods | camelCase | `addItem()` |
| Variables/Properties | camelCase | `viewContext` |
| Constants | camelCase | `let maxRetries = 3` |
| Static Properties | camelCase | `static let shared` |

### Import Organization

Order imports alphabetically:
```swift
import CoreData
import SwiftUI
```

- Apple frameworks first
- Third-party frameworks second (when added)
- Local modules last

### SwiftUI Patterns

Use declarative SwiftUI syntax:
```swift
struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(...) private var items: FetchedResults<Item>
    
    var body: some View {
        // View implementation
    }
}
```

Use `#Preview` macro for SwiftUI previews:
```swift
#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
```

### Property Wrappers

- `@Environment` - For dependency injection from SwiftUI environment
- `@FetchRequest` - For CoreData queries in views
- `@State` - For local view state
- `@Binding` - For two-way data binding
- `@StateObject` - For owning observable objects
- `@ObservedObject` - For referencing observable objects

### Concurrency

The project uses Swift's modern concurrency features:
- Default actor isolation is `MainActor`
- Use `@MainActor` for UI-related code
- Use `async/await` for asynchronous operations

### Error Handling

**Development:** Use `fatalError()` with descriptive messages for debugging:
```swift
do {
    try viewContext.save()
} catch {
    let nsError = error as NSError
    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
}
```

**Production:** Replace `fatalError()` with proper error handling:
```swift
do {
    try viewContext.save()
} catch {
    // Log error, show user alert, or handle gracefully
    logger.error("Failed to save: \(error.localizedDescription)")
}
```

### CoreData Conventions

- Entity names: PascalCase singular (`Item`, `User`)
- Attribute names: camelCase (`timestamp`, `createdAt`)
- Use auto-generated class code (`codeGenerationType="class"`)
- Access context via `@Environment(\.managedObjectContext)`

### Singleton Pattern

Use for shared resources:
```swift
struct PersistenceController {
    static let shared = PersistenceController()
    static var preview: PersistenceController = { ... }()
}
```

## Type Safety

- Prefer explicit types when clarity is needed
- Use `private` for implementation details
- Avoid force unwrapping (`!`) except in controlled scenarios
- Use `guard` for early returns
- Prefer `if let` or `guard let` for optional binding

## Comments

- Use `// MARK: -` to organize code sections
- Write doc comments (`///`) for public APIs
- Avoid obvious comments; code should be self-documenting

## Git Conventions

- Commit messages should be clear and descriptive
- Use present tense ("Add feature" not "Added feature")
- Reference issue numbers when applicable

## Common Xcode Shortcuts (for reference)

- Build: `Cmd + B`
- Run: `Cmd + R`
- Test: `Cmd + U`
- Clean: `Cmd + Shift + K`

## Adding Dependencies

When adding Swift packages:
1. File > Add Package Dependencies
2. Add the repository URL
3. Select version requirements
4. Import in Swift files as needed
