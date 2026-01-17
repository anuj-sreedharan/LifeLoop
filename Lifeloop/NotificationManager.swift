//
//  NotificationManager.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import CoreData
import Foundation
import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    
    private(set) var isAuthorized = false
    
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
    
    // MARK: - Fixed-Time Skincare Reminders
    
    /// Schedule fixed-time reminders for AM (08:00) and PM (21:00) skincare
    /// Only fires if the slot is still "Not logged"
    func scheduleFixedSkincareReminders() async {
        if !isAuthorized {
            let granted = await requestAuthorization()
            if !granted { return }
        }
        
        // Schedule AM reminder at 08:00
        await scheduleSkincareSlotReminder(for: .am)
        
        // Schedule PM reminder at 21:00
        await scheduleSkincareSlotReminder(for: .pm)
    }
    
    /// Schedule a reminder for a specific skincare slot
    private func scheduleSkincareSlotReminder(for timeOfDay: SkincareTimeOfDay) async {
        let identifier = "skincare-slot-\(timeOfDay.rawValue)"
        
        // Remove existing to avoid duplicates
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        
        // Check if slot is already completed or skipped for today
        if await isSlotCompletedOrSkipped(timeOfDay: timeOfDay) {
            // Don't schedule reminder if already logged
            return
        }
        
        // Check if reminder time has already passed today
        let now = Date()
        let calendar = Calendar.current
        var reminderComponents = calendar.dateComponents([.year, .month, .day], from: now)
        reminderComponents.hour = timeOfDay.reminderHour
        reminderComponents.minute = 0
        
        guard let reminderDate = calendar.date(from: reminderComponents) else { return }
        
        // If reminder time has passed today, schedule for tomorrow
        let triggerDate: Date
        if reminderDate <= now {
            triggerDate = calendar.date(byAdding: .day, value: 1, to: reminderDate) ?? reminderDate
        } else {
            triggerDate = reminderDate
        }
        
        let content = UNMutableNotificationContent()
        content.title = "\(timeOfDay.rawValue) Skincare Reminder"
        content.body = timeOfDay == .am 
            ? "Time for your morning skincare routine!" 
            : "Time for your evening skincare routine!"
        content.sound = .default
        content.userInfo = ["type": "skincareSlot", "timeOfDay": timeOfDay.rawValue]
        
        let triggerComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await UNUserNotificationCenter.current().add(request)
        } catch {
            print("Failed to schedule skincare slot reminder: \(error.localizedDescription)")
        }
    }
    
    /// Check if a skincare slot is completed or skipped for today
    private func isSlotCompletedOrSkipped(timeOfDay: SkincareTimeOfDay) async -> Bool {
        // Access CoreData on main actor
        let context = PersistenceController.shared.container.viewContext
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let request: NSFetchRequest<SkincareEntry> = SkincareEntry.fetchRequest()
        request.predicate = NSPredicate(
            format: "date >= %@ AND date < %@ AND timeOfDay == %@",
            startOfDay as NSDate,
            endOfDay as NSDate,
            timeOfDay.rawValue
        )
        request.fetchLimit = 1
        
        do {
            let results = try context.fetch(request)
            if let entry = results.first {
                let status = SkincareSlotStatus.from(entry.status)
                return status == .completed || status == .skipped
            }
        } catch {
            print("Failed to fetch skincare entry: \(error.localizedDescription)")
        }
        
        return false
    }
    
    /// Remove skincare slot reminder
    func removeSkincareSlotReminder(for timeOfDay: SkincareTimeOfDay) {
        let identifier = "skincare-slot-\(timeOfDay.rawValue)"
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    /// Remove all skincare slot reminders
    func removeAllSkincareSlotReminders() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: ["skincare-slot-AM", "skincare-slot-PM"]
        )
    }
    
    // MARK: - Clear All
    
    func removeAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
