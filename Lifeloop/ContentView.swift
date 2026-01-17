//
//  ContentView.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import CoreData
import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            Tab("Today", systemImage: "clock.fill") {
                HomeView()
            }
            
            Tab("Skincare", systemImage: "sparkles") {
                SkincareView()
            }
            
            Tab("History", systemImage: "calendar") {
                NavigationStack {
                    HistoryView()
                }
            }
        }
    }
}

// MARK: - Home View (24-Hour Timeline)

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var todaysActivities: FetchedResults<HourlyActivityEntry>
    
    @State private var selectedHour: Int?
    
    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        _todaysActivities = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HourlyActivityEntry.hour, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Today's Date Header
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date(), style: .date)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("\(loggedHoursCount) of 24 hours logged")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // 24-Hour Timeline
                Section {
                    ForEach(0..<24, id: \.self) { hour in
                        HourRowView(
                            hour: hour,
                            entry: entryForHour(hour)
                        )
                        .contentShape(Rectangle())
                        .onTapGesture {
                            selectedHour = hour
                        }
                    }
                } header: {
                    Text("Activity Timeline")
                }
            }
            .navigationTitle("Lifeloop")
            .sheet(item: $selectedHour) { hour in
                EditHourView(hour: hour, existingEntry: entryForHour(hour))
            }
        }
    }
    
    private var loggedHoursCount: Int {
        todaysActivities.count
    }
    
    private func entryForHour(_ hour: Int) -> HourlyActivityEntry? {
        todaysActivities.first { $0.hour == hour }
    }
}

// MARK: - Hour Row View

struct HourRowView: View {
    let hour: Int
    let entry: HourlyActivityEntry?
    
    private var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private var nextHourLabel: String {
        let nextHour = (hour + 1) % 24
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        let date = Calendar.current.date(bySettingHour: nextHour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Time range
            Text("\(hourLabel)–\(nextHourLabel)")
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 90, alignment: .leading)
            
            if let entry = entry {
                let activityType = ActivityType.from(entry.activityType)
                
                // Activity indicator
                Image(systemName: activityType.icon)
                    .font(.body)
                    .foregroundStyle(activityType.color)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(activityType.displayName)
                        .font(.body)
                    
                    if let notes = entry.notes, !notes.isEmpty {
                        Text(notes)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
            } else {
                // Not logged
                Image(systemName: "circle.dashed")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .frame(width: 24)
                
                Text("Not logged")
                    .font(.body)
                    .foregroundStyle(.tertiary)
                    .italic()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Edit Hour View

struct EditHourView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let hour: Int
    let existingEntry: HourlyActivityEntry?
    
    @State private var activityType: ActivityType = .miscGettingReady
    @State private var notes: String = ""
    
    private var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    private var nextHourLabel: String {
        let nextHour = (hour + 1) % 24
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        let date = Calendar.current.date(bySettingHour: nextHour, minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                // Time display (non-editable)
                Section {
                    HStack {
                        Text("Time")
                        Spacer()
                        Text("\(hourLabel) – \(nextHourLabel)")
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Activity picker
                Section {
                    Picker("Activity", selection: $activityType) {
                        ForEach(ActivityType.allCases) { type in
                            Label(type.displayName, systemImage: type.icon)
                                .tag(type)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("What did you do?")
                }
                
                // Notes
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
                
                // Delete button (only if entry exists)
                if existingEntry != nil {
                    Section {
                        Button(role: .destructive) {
                            deleteEntry()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Clear This Hour")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle("Log Activity")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
            .onAppear {
                if let entry = existingEntry {
                    activityType = ActivityType.from(entry.activityType)
                    notes = entry.notes ?? ""
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = existingEntry ?? HourlyActivityEntry(context: viewContext)
        
        let now = Date()
        
        if existingEntry == nil {
            entry.id = UUID()
            entry.date = Calendar.current.startOfDay(for: now)
            entry.hour = Int16(hour)
            entry.createdAt = now
        }
        
        entry.activityType = activityType.rawValue
        entry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.updatedAt = now
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteEntry() {
        guard let entry = existingEntry else { return }
        viewContext.delete(entry)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Int extension for sheet binding

extension Int: @retroactive Identifiable {
    public var id: Int { self }
}

// MARK: - Skincare View (Slot-Based)

struct SkincareView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var todaysSkincare: FetchedResults<SkincareEntry>
    
    @State private var selectedSlot: SkincareTimeOfDay?
    
    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        _todaysSkincare = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \SkincareEntry.timeOfDay, ascending: true)],
            predicate: predicate,
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Date Header
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(Date(), style: .date)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            Text("Daily Skincare Routine")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // AM Slot
                Section {
                    SkincareSlotRowView(
                        timeOfDay: .am,
                        entry: entryForSlot(.am)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSlot = .am
                    }
                } header: {
                    Label("Morning Routine", systemImage: "sun.max.fill")
                }
                
                // PM Slot
                Section {
                    SkincareSlotRowView(
                        timeOfDay: .pm,
                        entry: entryForSlot(.pm)
                    )
                    .contentShape(Rectangle())
                    .onTapGesture {
                        selectedSlot = .pm
                    }
                } header: {
                    Label("Evening Routine", systemImage: "moon.fill")
                }
            }
            .navigationTitle("Skincare")
            .sheet(item: $selectedSlot) { slot in
                EditSkincareSlotView(
                    timeOfDay: slot,
                    existingEntry: entryForSlot(slot)
                )
            }
            .onAppear {
                // Schedule reminders when view appears
                Task {
                    await scheduleRemindersIfNeeded()
                }
            }
        }
    }
    
    private func entryForSlot(_ timeOfDay: SkincareTimeOfDay) -> SkincareEntry? {
        todaysSkincare.first { $0.timeOfDay == timeOfDay.rawValue }
    }
    
    private func scheduleRemindersIfNeeded() async {
        // Request authorization first
        let authorized = await NotificationManager.shared.requestAuthorization()
        guard authorized else { return }
        
        // Schedule fixed-time reminders
        await NotificationManager.shared.scheduleFixedSkincareReminders()
    }
}

// MARK: - Skincare Slot Row View

struct SkincareSlotRowView: View {
    let timeOfDay: SkincareTimeOfDay
    let entry: SkincareEntry?
    
    private var status: SkincareSlotStatus {
        guard let entry = entry else { return .notLogged }
        return SkincareSlotStatus.from(entry.status)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Status icon
            Image(systemName: status.icon)
                .font(.title2)
                .foregroundStyle(status.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(timeOfDay.displayName)
                        .font(.headline)
                    
                    Spacer()
                    
                    Text(status.displayName)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(status.color.opacity(0.15))
                        .foregroundStyle(status.color)
                        .clipShape(Capsule())
                }
                
                // Show products if completed
                if status == .completed, let products = entry?.products, !products.isEmpty {
                    Text(products)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }
                
                // Show notes if any
                if let notes = entry?.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .padding(.vertical, 8)
    }
}

// MARK: - Edit Skincare Slot View

struct EditSkincareSlotView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let timeOfDay: SkincareTimeOfDay
    let existingEntry: SkincareEntry?
    
    @State private var status: SkincareSlotStatus = .notLogged
    @State private var products: String = ""
    @State private var notes: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                // Time display (non-editable)
                Section {
                    HStack {
                        Label(timeOfDay.displayName, systemImage: timeOfDay.icon)
                            .foregroundStyle(timeOfDay.color)
                        Spacer()
                    }
                }
                
                // Status picker
                Section {
                    Picker("Status", selection: $status) {
                        ForEach(SkincareSlotStatus.allCases) { s in
                            Label(s.displayName, systemImage: s.icon)
                                .tag(s)
                        }
                    }
                    .pickerStyle(.inline)
                } header: {
                    Text("How did it go?")
                }
                
                // Products (only if completed)
                if status == .completed {
                    Section {
                        TextField("Products used", text: $products, axis: .vertical)
                            .lineLimit(3...6)
                    } header: {
                        Text("Products")
                    } footer: {
                        Text("List the products you used (e.g., Cleanser, Serum, Moisturizer)")
                    }
                }
                
                // Notes
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
            }
            .navigationTitle("\(timeOfDay.rawValue) Skincare")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveEntry()
                    }
                }
            }
            .onAppear {
                if let entry = existingEntry {
                    status = SkincareSlotStatus.from(entry.status)
                    products = entry.products ?? ""
                    notes = entry.notes ?? ""
                }
            }
        }
    }
    
    private func saveEntry() {
        let entry = existingEntry ?? SkincareEntry(context: viewContext)
        
        let now = Date()
        
        if existingEntry == nil {
            entry.id = UUID()
            entry.date = Calendar.current.startOfDay(for: now)
            entry.timeOfDay = timeOfDay.rawValue
            entry.createdAt = now
        }
        
        entry.status = status.rawValue
        entry.products = status == .completed ? products.trimmingCharacters(in: .whitespacesAndNewlines) : nil
        entry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.updatedAt = now
        
        do {
            try viewContext.save()
            
            // Update reminders after saving
            Task {
                await NotificationManager.shared.scheduleFixedSkincareReminders()
            }
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - History View

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \HourlyActivityEntry.date, ascending: false)],
        animation: .default
    )
    private var allActivities: FetchedResults<HourlyActivityEntry>
    
    @State private var selectedDate: Date?
    
    private var groupedDates: [Date] {
        var dates = Set<Date>()
        
        for activity in allActivities {
            if let date = activity.date {
                dates.insert(Calendar.current.startOfDay(for: date))
            }
        }
        
        return dates.sorted(by: >)
    }
    
    var body: some View {
        List {
            if groupedDates.isEmpty {
                ContentUnavailableView(
                    "No History",
                    systemImage: "calendar.badge.clock",
                    description: Text("Your logged activities will appear here")
                )
            } else {
                ForEach(groupedDates, id: \.self) { date in
                    Section {
                        let activitiesForDate = allActivities
                            .filter { activity in
                                guard let activityDate = activity.date else { return false }
                                return Calendar.current.isDate(activityDate, inSameDayAs: date)
                            }
                            .sorted { $0.hour < $1.hour }
                        
                        // Summary row
                        HStack {
                            Text("\(activitiesForDate.count) hours logged")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            
                            Spacer()
                            
                            // Activity breakdown
                            HStack(spacing: 4) {
                                ForEach(topActivities(for: activitiesForDate), id: \.0) { type, count in
                                    HStack(spacing: 2) {
                                        Image(systemName: type.icon)
                                            .font(.caption2)
                                            .foregroundStyle(type.color)
                                        Text("\(count)")
                                            .font(.caption2)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                        
                        // Individual entries
                        ForEach(activitiesForDate) { activity in
                            HistoryActivityRowView(activity: activity)
                        }
                    } header: {
                        Text(date, style: .date)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle("History")
    }
    
    private func topActivities(for activities: [HourlyActivityEntry]) -> [(ActivityType, Int)] {
        var counts: [ActivityType: Int] = [:]
        
        for activity in activities {
            let type = ActivityType.from(activity.activityType)
            counts[type, default: 0] += 1
        }
        
        return counts.sorted { $0.value > $1.value }.prefix(3).map { ($0.key, $0.value) }
    }
}

// MARK: - History Activity Row View

struct HistoryActivityRowView: View {
    @ObservedObject var activity: HourlyActivityEntry
    
    private var hourLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:00"
        let date = Calendar.current.date(bySettingHour: Int(activity.hour), minute: 0, second: 0, of: Date()) ?? Date()
        return formatter.string(from: date)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Text(hourLabel)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(width: 50, alignment: .leading)
            
            let activityType = ActivityType.from(activity.activityType)
            
            Image(systemName: activityType.icon)
                .font(.body)
                .foregroundStyle(activityType.color)
                .frame(width: 24)
            
            Text(activityType.displayName)
                .font(.body)
            
            Spacer()
            
            if let notes = activity.notes, !notes.isEmpty {
                Image(systemName: "note.text")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 2)
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
