# Lifeloop

A personal hourly activity logger for iOS. Track how you spend your time and maintain awareness of your daily spending habits.

## Features

### Hourly Activity Logging
Log your activities hour by hour across a 24-hour timeline. Choose from 12 activity types:

- Sleep
- Work
- Hobbies / Projects
- Freelance
- Exercise
- Friends
- Relaxation and Leisure
- Dating / Partner
- Family
- Productive / Chores
- Travel
- Misc / Getting Ready

### Spending Awareness
Simple spending logging for awareness (not budgeting). Track expenses across 9 categories:

- Food & Drinks
- Transport
- Shopping
- Rent / Bills
- Subscriptions
- Health
- Travel
- Social
- Misc

### Dashboard
A daily overview showing:
- Hours logged today
- Today's spending
- Weekly spending total
- Daily average
- Top spending category

### Reminders & Notifications
Configurable reminders to help you stay on track with logging.

## Tech Stack

- **Language:** Swift 5.0
- **Framework:** SwiftUI
- **Persistence:** CoreData
- **Minimum iOS:** 26.2
- **Build System:** Xcode

## Getting Started

### Prerequisites
- Xcode (latest version recommended)
- iOS 26.2+ Simulator or device

### Build

```bash
xcodebuild -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16' build
```

### Run Tests

```bash
xcodebuild test -scheme Lifeloop -destination 'platform=iOS Simulator,name=iPhone 16'
```

### Clean

```bash
xcodebuild -scheme Lifeloop clean
```

## Project Structure

```
Lifeloop/
├── Lifeloop/
│   ├── Assets.xcassets/         # Images, colors, app icon
│   ├── Lifeloop.xcdatamodeld/   # CoreData model
│   ├── ActivityType.swift       # Activity type enum
│   ├── ContentView.swift        # Main views
│   ├── DashboardView.swift      # Dashboard with daily overview
│   ├── LifeloopApp.swift        # App entry point
│   ├── NotificationManager.swift # Reminder scheduling
│   ├── Persistence.swift        # CoreData persistence layer
│   ├── SpendingCategory.swift   # Spending category enum
│   └── SpendingView.swift       # Spending views
└── Lifeloop.xcodeproj/          # Xcode project
```

## Philosophy

Lifeloop is designed to be:

- **Simple** - Not a task manager or budgeting app
- **Calm** - Minimal, routine-focused UI without judgment
- **Private** - All data stays on your device
- **Accessible** - Supports Dynamic Type and VoiceOver

## License

Private project.
