//
//  SkincareSlotStatus.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import Foundation
import SwiftUI

/// Status for skincare slots (AM/PM)
enum SkincareSlotStatus: String, CaseIterable, Identifiable {
    case notLogged = "notLogged"
    case completed = "completed"
    case skipped = "skipped"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .notLogged: return "Not Logged"
        case .completed: return "Completed"
        case .skipped: return "Skipped"
        }
    }
    
    var icon: String {
        switch self {
        case .notLogged: return "circle.dashed"
        case .completed: return "checkmark.circle.fill"
        case .skipped: return "minus.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .notLogged: return .secondary
        case .completed: return .green
        case .skipped: return .orange
        }
    }
    
    /// Initialize from a stored string value
    static func from(_ string: String?) -> SkincareSlotStatus {
        guard let string = string else { return .notLogged }
        return SkincareSlotStatus(rawValue: string) ?? .notLogged
    }
}

/// Time of day for skincare routines
enum SkincareTimeOfDay: String, CaseIterable, Identifiable {
    case am = "AM"
    case pm = "PM"
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .am: return "Morning (AM)"
        case .pm: return "Evening (PM)"
        }
    }
    
    var icon: String {
        switch self {
        case .am: return "sun.max.fill"
        case .pm: return "moon.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .am: return .orange
        case .pm: return .indigo
        }
    }
    
    /// Fixed reminder hour for this time of day
    var reminderHour: Int {
        switch self {
        case .am: return 8   // 08:00
        case .pm: return 21  // 21:00
        }
    }
    
    static func from(_ string: String?) -> SkincareTimeOfDay {
        guard let string = string else { return .am }
        return SkincareTimeOfDay(rawValue: string) ?? .am
    }
}
