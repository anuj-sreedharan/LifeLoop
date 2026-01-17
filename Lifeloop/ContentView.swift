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
        HomeView()
    }
}

// MARK: - Home View

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest private var todaysTasks: FetchedResults<TaskEntry>
    @FetchRequest private var todaysSkincare: FetchedResults<SkincareEntry>
    
    @State private var showingAddTask = false
    @State private var showingAddSkincare = false
    @State private var taskToEdit: TaskEntry?
    @State private var skincareToEdit: SkincareEntry?
    
    init() {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let taskPredicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        _todaysTasks = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntry.createdAt, ascending: true)],
            predicate: taskPredicate,
            animation: .default
        )
        
        let skincarePredicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)
        _todaysSkincare = FetchRequest(
            sortDescriptors: [
                NSSortDescriptor(keyPath: \SkincareEntry.timeOfDay, ascending: true),
                NSSortDescriptor(keyPath: \SkincareEntry.createdAt, ascending: true)
            ],
            predicate: skincarePredicate,
            animation: .default
        )
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Today's Date Header
                Section {
                    Text(Date(), style: .date)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                        .listRowBackground(Color.clear)
                }
                
                // Tasks Section
                Section {
                    if todaysTasks.isEmpty {
                        Text("No tasks for today")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(todaysTasks) { task in
                            TaskRowView(task: task)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    taskToEdit = task
                                }
                        }
                        .onDelete(perform: deleteTasks)
                    }
                } header: {
                    HStack {
                        Text("Tasks")
                        Spacer()
                        Button {
                            showingAddTask = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
                
                // Skincare Section
                Section {
                    if todaysSkincare.isEmpty {
                        Text("No skincare routine for today")
                            .foregroundStyle(.secondary)
                            .italic()
                    } else {
                        ForEach(todaysSkincare) { entry in
                            SkincareRowView(entry: entry)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    skincareToEdit = entry
                                }
                        }
                        .onDelete(perform: deleteSkincare)
                    }
                } header: {
                    HStack {
                        Text("Skincare")
                        Spacer()
                        Button {
                            showingAddSkincare = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Lifeloop")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Image(systemName: "calendar")
                    }
                }
            }
            .sheet(isPresented: $showingAddTask) {
                AddEditTaskView(task: nil)
            }
            .sheet(item: $taskToEdit) { task in
                AddEditTaskView(task: task)
            }
            .sheet(isPresented: $showingAddSkincare) {
                AddEditSkincareView(entry: nil)
            }
            .sheet(item: $skincareToEdit) { entry in
                AddEditSkincareView(entry: entry)
            }
        }
    }
    
    private func deleteTasks(offsets: IndexSet) {
        withAnimation {
            offsets.map { todaysTasks[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func deleteSkincare(offsets: IndexSet) {
        withAnimation {
            offsets.map { todaysSkincare[$0] }.forEach(viewContext.delete)
            saveContext()
        }
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Task Row View

struct TaskRowView: View {
    @ObservedObject var task: TaskEntry
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        HStack(spacing: 12) {
            Button {
                withAnimation {
                    task.isCompleted.toggle()
                    saveContext()
                }
            } label: {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(task.isCompleted ? .green : .secondary)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(task.title ?? "Untitled")
                    .strikethrough(task.isCompleted)
                    .foregroundStyle(task.isCompleted ? .secondary : .primary)
                
                if let notes = task.notes, !notes.isEmpty {
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
    }
    
    private func saveContext() {
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Skincare Row View

struct SkincareRowView: View {
    @ObservedObject var entry: SkincareEntry
    
    var body: some View {
        HStack(spacing: 12) {
            Text(entry.timeOfDay ?? "AM")
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(entry.timeOfDay == "AM" ? Color.orange.opacity(0.2) : Color.indigo.opacity(0.2))
                .foregroundStyle(entry.timeOfDay == "AM" ? .orange : .indigo)
                .clipShape(Capsule())
            
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.productName ?? "Unknown Product")
                
                Text(entry.stepType ?? "Step")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
    }
}

// MARK: - Add/Edit Task View

struct AddEditTaskView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let task: TaskEntry?
    
    @State private var title: String = ""
    @State private var notes: String = ""
    @State private var date: Date = Date()
    @State private var isCompleted: Bool = false
    @State private var hasReminder: Bool = false
    @State private var reminderDate: Date = Date()
    
    private var isEditing: Bool { task != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Task title", text: $title)
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                    Toggle("Completed", isOn: $isCompleted)
                }
                
                Section {
                    Toggle("Reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("Remind at", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                } footer: {
                    if hasReminder {
                        Text("You'll receive a notification at the scheduled time")
                    }
                }
                
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteTask()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Task")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Task" : "New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveTask()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let task = task {
                    title = task.title ?? ""
                    notes = task.notes ?? ""
                    date = task.date ?? Date()
                    isCompleted = task.isCompleted
                }
                // Set default reminder time to 9 AM on the task date
                var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                components.hour = 9
                components.minute = 0
                reminderDate = Calendar.current.date(from: components) ?? date
            }
        }
    }
    
    private func saveTask() {
        let entry = task ?? TaskEntry(context: viewContext)
        
        if task == nil {
            entry.id = UUID()
            entry.createdAt = Date()
        }
        
        entry.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        entry.date = Calendar.current.startOfDay(for: date)
        entry.isCompleted = isCompleted
        
        do {
            try viewContext.save()
            
            // Schedule or remove reminder
            Task {
                if hasReminder {
                    let authorized = await NotificationManager.shared.requestAuthorization()
                    if authorized {
                        await NotificationManager.shared.scheduleTaskReminder(for: entry, at: reminderDate)
                    }
                } else {
                    await NotificationManager.shared.removeTaskReminder(for: entry)
                }
            }
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteTask() {
        guard let task = task else { return }
        
        // Remove any scheduled reminder
        Task {
            await NotificationManager.shared.removeTaskReminder(for: task)
        }
        
        viewContext.delete(task)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}

// MARK: - Add/Edit Skincare View

struct AddEditSkincareView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: SkincareEntry?
    
    @State private var productName: String = ""
    @State private var stepType: String = "Cleanser"
    @State private var timeOfDay: String = "AM"
    @State private var notes: String = ""
    @State private var date: Date = Date()
    @State private var hasReminder: Bool = false
    @State private var reminderDate: Date = Date()
    
    private var isEditing: Bool { entry != nil }
    
    private let stepTypes = ["Cleanser", "Toner", "Serum", "Moisturizer", "Sunscreen", "Treatment", "Mask", "Eye Cream", "Oil"]
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Product name", text: $productName)
                    
                    Picker("Step Type", selection: $stepType) {
                        ForEach(stepTypes, id: \.self) { type in
                            Text(type).tag(type)
                        }
                    }
                    
                    Picker("Time of Day", selection: $timeOfDay) {
                        Text("AM ☀️").tag("AM")
                        Text("PM 🌙").tag("PM")
                    }
                    .pickerStyle(.segmented)
                }
                
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                Section {
                    Toggle("Reminder", isOn: $hasReminder)
                    
                    if hasReminder {
                        DatePicker("Remind at", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    }
                } footer: {
                    if hasReminder {
                        Text("You'll receive a notification at the scheduled time")
                    }
                }
                
                if isEditing {
                    Section {
                        Button(role: .destructive) {
                            deleteEntry()
                        } label: {
                            HStack {
                                Spacer()
                                Text("Delete Entry")
                                Spacer()
                            }
                        }
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Skincare" : "New Skincare")
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
                    .disabled(productName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if let entry = entry {
                    productName = entry.productName ?? ""
                    stepType = entry.stepType ?? "Cleanser"
                    timeOfDay = entry.timeOfDay ?? "AM"
                    notes = entry.notes ?? ""
                    date = entry.date ?? Date()
                }
                // Set default reminder time based on AM/PM
                var components = Calendar.current.dateComponents([.year, .month, .day], from: date)
                components.hour = timeOfDay == "AM" ? 7 : 20
                components.minute = 0
                reminderDate = Calendar.current.date(from: components) ?? date
            }
            .onChange(of: timeOfDay) { _, newValue in
                // Update reminder time when time of day changes
                var components = Calendar.current.dateComponents([.year, .month, .day], from: reminderDate)
                components.hour = newValue == "AM" ? 7 : 20
                components.minute = 0
                reminderDate = Calendar.current.date(from: components) ?? reminderDate
            }
        }
    }
    
    private func saveEntry() {
        let skincareEntry = entry ?? SkincareEntry(context: viewContext)
        
        if entry == nil {
            skincareEntry.id = UUID()
            skincareEntry.createdAt = Date()
        }
        
        skincareEntry.productName = productName.trimmingCharacters(in: .whitespacesAndNewlines)
        skincareEntry.stepType = stepType
        skincareEntry.timeOfDay = timeOfDay
        skincareEntry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        skincareEntry.date = Calendar.current.startOfDay(for: date)
        
        do {
            try viewContext.save()
            
            // Schedule or remove reminder
            Task {
                if hasReminder {
                    let authorized = await NotificationManager.shared.requestAuthorization()
                    if authorized {
                        await NotificationManager.shared.scheduleSkincareReminder(for: skincareEntry, at: reminderDate)
                    }
                } else {
                    await NotificationManager.shared.removeSkincareReminder(for: skincareEntry)
                }
            }
            
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteEntry() {
        guard let entry = entry else { return }
        
        // Remove any scheduled reminder
        Task {
            await NotificationManager.shared.removeSkincareReminder(for: entry)
        }
        
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

// MARK: - History View

struct HistoryView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \TaskEntry.date, ascending: false)],
        animation: .default
    )
    private var allTasks: FetchedResults<TaskEntry>
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SkincareEntry.date, ascending: false)],
        animation: .default
    )
    private var allSkincare: FetchedResults<SkincareEntry>
    
    @State private var taskToEdit: TaskEntry?
    @State private var skincareToEdit: SkincareEntry?
    
    private var groupedDates: [Date] {
        var dates = Set<Date>()
        
        for task in allTasks {
            if let date = task.date {
                dates.insert(Calendar.current.startOfDay(for: date))
            }
        }
        
        for entry in allSkincare {
            if let date = entry.date {
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
                    description: Text("Your past entries will appear here")
                )
            } else {
                ForEach(groupedDates, id: \.self) { date in
                    Section {
                        let tasksForDate = allTasks.filter { task in
                            guard let taskDate = task.date else { return false }
                            return Calendar.current.isDate(taskDate, inSameDayAs: date)
                        }
                        
                        let skincareForDate = allSkincare.filter { entry in
                            guard let entryDate = entry.date else { return false }
                            return Calendar.current.isDate(entryDate, inSameDayAs: date)
                        }
                        
                        if !tasksForDate.isEmpty {
                            ForEach(tasksForDate) { task in
                                TaskRowView(task: task)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        taskToEdit = task
                                    }
                            }
                        }
                        
                        if !skincareForDate.isEmpty {
                            ForEach(skincareForDate) { entry in
                                SkincareRowView(entry: entry)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        skincareToEdit = entry
                                    }
                            }
                        }
                    } header: {
                        Text(date, style: .date)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .navigationTitle("History")
        .sheet(item: $taskToEdit) { task in
            AddEditTaskView(task: task)
        }
        .sheet(item: $skincareToEdit) { entry in
            AddEditSkincareView(entry: entry)
        }
    }
}

// MARK: - Preview

#Preview {
    ContentView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
