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
        
        // Create sample TaskEntry items
        let today = Calendar.current.startOfDay(for: Date())
        let yesterday = Calendar.current.date(byAdding: .day, value: -1, to: today)!
        
        let task1 = TaskEntry(context: viewContext)
        task1.id = UUID()
        task1.title = "Morning meditation"
        task1.notes = "10 minutes of mindfulness"
        task1.date = today
        task1.isCompleted = true
        task1.createdAt = Date()
        
        let task2 = TaskEntry(context: viewContext)
        task2.id = UUID()
        task2.title = "Drink 8 glasses of water"
        task2.notes = nil
        task2.date = today
        task2.isCompleted = false
        task2.createdAt = Date()
        
        let task3 = TaskEntry(context: viewContext)
        task3.id = UUID()
        task3.title = "Evening walk"
        task3.notes = "30 minutes around the park"
        task3.date = today
        task3.isCompleted = false
        task3.createdAt = Date()
        
        let task4 = TaskEntry(context: viewContext)
        task4.id = UUID()
        task4.title = "Read for 20 minutes"
        task4.notes = nil
        task4.date = yesterday
        task4.isCompleted = true
        task4.createdAt = yesterday
        
        // Create sample SkincareEntry items
        let skincare1 = SkincareEntry(context: viewContext)
        skincare1.id = UUID()
        skincare1.productName = "Gentle Foaming Cleanser"
        skincare1.stepType = "Cleanser"
        skincare1.timeOfDay = "AM"
        skincare1.notes = nil
        skincare1.date = today
        skincare1.createdAt = Date()
        
        let skincare2 = SkincareEntry(context: viewContext)
        skincare2.id = UUID()
        skincare2.productName = "Vitamin C Serum"
        skincare2.stepType = "Serum"
        skincare2.timeOfDay = "AM"
        skincare2.notes = "Apply after toner"
        skincare2.date = today
        skincare2.createdAt = Date()
        
        let skincare3 = SkincareEntry(context: viewContext)
        skincare3.id = UUID()
        skincare3.productName = "Daily Moisturizer SPF 30"
        skincare3.stepType = "Moisturizer"
        skincare3.timeOfDay = "AM"
        skincare3.notes = nil
        skincare3.date = today
        skincare3.createdAt = Date()
        
        let skincare4 = SkincareEntry(context: viewContext)
        skincare4.id = UUID()
        skincare4.productName = "Oil Cleanser"
        skincare4.stepType = "Cleanser"
        skincare4.timeOfDay = "PM"
        skincare4.notes = "Double cleanse first step"
        skincare4.date = today
        skincare4.createdAt = Date()
        
        let skincare5 = SkincareEntry(context: viewContext)
        skincare5.id = UUID()
        skincare5.productName = "Retinol Night Cream"
        skincare5.stepType = "Treatment"
        skincare5.timeOfDay = "PM"
        skincare5.notes = "Use every other night"
        skincare5.date = today
        skincare5.createdAt = Date()
        
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
