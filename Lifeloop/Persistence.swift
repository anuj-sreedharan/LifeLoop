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
        
        // Sleep hours (0-7)
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
        
        // Work hours (8-12)
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
        
        // Afternoon work (13-17)
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
        
        // Friends (18-19)
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
        
        // MARK: - Sample SkincareEntry items
        
        let skincare1 = SkincareEntry(context: viewContext)
        skincare1.id = UUID()
        skincare1.productName = "Gentle Foaming Cleanser"
        skincare1.stepType = "Cleanser"
        skincare1.timeOfDay = "AM"
        skincare1.notes = nil
        skincare1.date = today
        skincare1.createdAt = now
        
        let skincare2 = SkincareEntry(context: viewContext)
        skincare2.id = UUID()
        skincare2.productName = "Vitamin C Serum"
        skincare2.stepType = "Serum"
        skincare2.timeOfDay = "AM"
        skincare2.notes = "Apply after toner"
        skincare2.date = today
        skincare2.createdAt = now
        
        let skincare3 = SkincareEntry(context: viewContext)
        skincare3.id = UUID()
        skincare3.productName = "Daily Moisturizer SPF 30"
        skincare3.stepType = "Moisturizer"
        skincare3.timeOfDay = "AM"
        skincare3.notes = nil
        skincare3.date = today
        skincare3.createdAt = now
        
        let skincare4 = SkincareEntry(context: viewContext)
        skincare4.id = UUID()
        skincare4.productName = "Oil Cleanser"
        skincare4.stepType = "Cleanser"
        skincare4.timeOfDay = "PM"
        skincare4.notes = "Double cleanse first step"
        skincare4.date = today
        skincare4.createdAt = now
        
        let skincare5 = SkincareEntry(context: viewContext)
        skincare5.id = UUID()
        skincare5.productName = "Retinol Night Cream"
        skincare5.stepType = "Treatment"
        skincare5.timeOfDay = "PM"
        skincare5.notes = "Use every other night"
        skincare5.date = today
        skincare5.createdAt = now
        
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
