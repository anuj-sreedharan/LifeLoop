//
//  Persistence.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    @MainActor
    static let preview: PersistenceController = {
        let result = PersistenceController(inMemory: true)
        let viewContext = result.container.viewContext
        
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        let now = Date()
        
        // MARK: - Sample HourlyActivityEntry items for today
        
        // Sleep hours (0-6)
        for hour in 0...6 {
            let entry = HourlyActivityEntry(context: viewContext)
            entry.id = UUID()
            entry.date = today
            entry.hour = Int16(hour)
            entry.activityType = ActivityType.sleep.rawValue
            entry.notes = nil
            entry.createdAt = now
            entry.updatedAt = now
        }
        
        // Morning routine (7)
        let morning = HourlyActivityEntry(context: viewContext)
        morning.id = UUID()
        morning.date = today
        morning.hour = 7
        morning.activityType = ActivityType.miscGettingReady.rawValue
        morning.notes = "Shower, breakfast"
        morning.createdAt = now
        morning.updatedAt = now
        
        // Work hours (8-11)
        for hour in 8...11 {
            let entry = HourlyActivityEntry(context: viewContext)
            entry.id = UUID()
            entry.date = today
            entry.hour = Int16(hour)
            entry.activityType = ActivityType.work.rawValue
            entry.notes = nil
            entry.createdAt = now
            entry.updatedAt = now
        }
        
        // Lunch (12)
        let lunch = HourlyActivityEntry(context: viewContext)
        lunch.id = UUID()
        lunch.date = today
        lunch.hour = 12
        lunch.activityType = ActivityType.relaxationLeisure.rawValue
        lunch.notes = "Lunch break"
        lunch.createdAt = now
        lunch.updatedAt = now
        
        // Afternoon work (13-16)
        for hour in 13...16 {
            let entry = HourlyActivityEntry(context: viewContext)
            entry.id = UUID()
            entry.date = today
            entry.hour = Int16(hour)
            entry.activityType = ActivityType.work.rawValue
            entry.notes = nil
            entry.createdAt = now
            entry.updatedAt = now
        }
        
        // Exercise (17)
        let exercise = HourlyActivityEntry(context: viewContext)
        exercise.id = UUID()
        exercise.date = today
        exercise.hour = 17
        exercise.activityType = ActivityType.exercise.rawValue
        exercise.notes = "Gym session"
        exercise.createdAt = now
        exercise.updatedAt = now
        
        // Friends (18)
        let friends = HourlyActivityEntry(context: viewContext)
        friends.id = UUID()
        friends.date = today
        friends.hour = 18
        friends.activityType = ActivityType.friends.rawValue
        friends.notes = "Dinner with friends"
        friends.createdAt = now
        friends.updatedAt = now
        
        // Sample entry for yesterday
        let yesterdayWork = HourlyActivityEntry(context: viewContext)
        yesterdayWork.id = UUID()
        yesterdayWork.date = yesterday
        yesterdayWork.hour = 10
        yesterdayWork.activityType = ActivityType.work.rawValue
        yesterdayWork.notes = "Project meeting"
        yesterdayWork.createdAt = yesterday
        yesterdayWork.updatedAt = yesterday
        
        // MARK: - Sample SkincareEntry slots (slot-based model)
        
        // AM slot - Completed
        let amSlot = SkincareEntry(context: viewContext)
        amSlot.id = UUID()
        amSlot.date = today
        amSlot.timeOfDay = SkincareTimeOfDay.am.rawValue
        amSlot.status = SkincareSlotStatus.completed.rawValue
        amSlot.products = "Cleanser, Vitamin C Serum, Moisturizer SPF 30"
        amSlot.notes = "Felt refreshed!"
        amSlot.createdAt = now
        amSlot.updatedAt = now
        
        // PM slot - Not logged (default state)
        let pmSlot = SkincareEntry(context: viewContext)
        pmSlot.id = UUID()
        pmSlot.date = today
        pmSlot.timeOfDay = SkincareTimeOfDay.pm.rawValue
        pmSlot.status = SkincareSlotStatus.notLogged.rawValue
        pmSlot.products = nil
        pmSlot.notes = nil
        pmSlot.createdAt = now
        pmSlot.updatedAt = now
        
        // Yesterday's slots
        let yesterdayAM = SkincareEntry(context: viewContext)
        yesterdayAM.id = UUID()
        yesterdayAM.date = yesterday
        yesterdayAM.timeOfDay = SkincareTimeOfDay.am.rawValue
        yesterdayAM.status = SkincareSlotStatus.completed.rawValue
        yesterdayAM.products = "Cleanser, Toner, Serum, Moisturizer"
        yesterdayAM.notes = nil
        yesterdayAM.createdAt = yesterday
        yesterdayAM.updatedAt = yesterday
        
        let yesterdayPM = SkincareEntry(context: viewContext)
        yesterdayPM.id = UUID()
        yesterdayPM.date = yesterday
        yesterdayPM.timeOfDay = SkincareTimeOfDay.pm.rawValue
        yesterdayPM.status = SkincareSlotStatus.skipped.rawValue
        yesterdayPM.products = nil
        yesterdayPM.notes = "Too tired"
        yesterdayPM.createdAt = yesterday
        yesterdayPM.updatedAt = yesterday
        
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
        return result
    }()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "Lifeloop")
        if inMemory {
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
    }
}
