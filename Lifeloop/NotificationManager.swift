//
//  NotificationManager.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import Foundation
import UserNotifications

@MainActor
final class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var isAuthorized = false
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    // MARK: - Authorization
    
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }
    
    // MARK: - Task Reminders
    
    func scheduleTaskReminder(for task: TaskEntry, at date: Date) async {
        guard let taskId = task.id, let title = task.title else { return }
        
        // Remove existing notification for this task first (idempotent)
        await removeTaskReminder(for: task)
        
        // Don't schedule if the date is in the past
        guard date > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = title
        content.sound = .default
        content.userInfo = ["taskId": taskId.uuidString, "type": "task"]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task-\(taskId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule task reminder: \(error.localizedDescription)")
        }
    }
    
    func removeTaskReminder(for task: TaskEntry) async {
        guard let taskId = task.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["task-\(taskId.uuidString)"]
        )
    }
    
    // MARK: - Skincare Reminders
    
    func scheduleSkincareReminder(for entry: SkincareEntry, at date: Date) async {
        guard let entryId = entry.id, let productName = entry.productName else { return }
        
        // Remove existing notification for this entry first (idempotent)
        await removeSkincareReminder(for: entry)
        
        // Don't schedule if the date is in the past
        guard date > Date() else { return }
        
        let timeOfDay = entry.timeOfDay ?? "AM"
        
        let content = UNMutableNotificationContent()
        content.title = "\(timeOfDay) Skincare Reminder"
        content.body = "Time for: \(productName)"
        content.sound = .default
        content.userInfo = ["skincareId": entryId.uuidString, "type": "skincare"]
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "skincare-\(entryId.uuidString)",
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule skincare reminder: \(error.localizedDescription)")
        }
    }
    
    func removeSkincareReminder(for entry: SkincareEntry) async {
        guard let entryId = entry.id else { return }
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["skincare-\(entryId.uuidString)"]
        )
    }
    
    // MARK: - Daily Routine Reminders
    
    func scheduleDailyRoutineReminder(hour: Int, minute: Int, timeOfDay: String) async {
        let identifier = "daily-routine-\(timeOfDay)"
        
        // Remove existing to avoid duplicates
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        let content = UNMutableNotificationContent()
        content.title = "\(timeOfDay) Routine"
        content.body = timeOfDay == "AM" ? "Start your morning skincare routine" : "Time for your evening skincare routine"
        content.sound = .default
        content.userInfo = ["type": "dailyRoutine", "timeOfDay": timeOfDay]
        
        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule daily routine reminder: \(error.localizedDescription)")
        }
    }
    
    func removeDailyRoutineReminder(timeOfDay: String) {
        let identifier = "daily-routine-\(timeOfDay)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    // MARK: - Clear All
    
    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
