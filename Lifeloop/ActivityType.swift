//
//  ActivityType.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import Foundation
import SwiftUI

/// Centralized list of activity types for hourly logging
enum ActivityType: String, CaseIterable, Identifiable {
    case sleep = "Sleep"
    case work = "Work"
    case hobbiesProjects = "Hobbies / Projects"
    case freelance = "Freelance"
    case exercise = "Exercise"
    case friends = "Friends"
    case relaxationLeisure = "Relaxation and Leisure"
    case datingPartner = "Dating / Partner"
    case family = "Family"
    case productiveChores = "Productive / Chores"
    case travel = "Travel"
    case miscGettingReady = "Misc / Getting Ready"
    
    var id: String { rawValue }
    
    /// Display name for the activity
    var displayName: String { rawValue }
    
    /// Icon for the activity type
    var icon: String {
        switch self {
        case .sleep: return "moon.zzz.fill"
        case .work: return "briefcase.fill"
        case .hobbiesProjects: return "paintbrush.fill"
        case .freelance: return "laptopcomputer"
        case .exercise: return "figure.run"
        case .friends: return "person.2.fill"
        case .relaxationLeisure: return "cup.and.saucer.fill"
        case .datingPartner: return "heart.fill"
        case .family: return "house.fill"
        case .productiveChores: return "checkmark.circle.fill"
        case .travel: return "car.fill"
        case .miscGettingReady: return "sparkles"
        }
    }
    
    /// Color associated with the activity type
    var color: Color {
        switch self {
        case .sleep: return .indigo
        case .work: return .blue
        case .hobbiesProjects: return .purple
        case .freelance: return .cyan
        case .exercise: return .green
        case .friends: return .orange
        case .relaxationLeisure: return .teal
        case .datingPartner: return .pink
        case .family: return .brown
        case .productiveChores: return .mint
        case .travel: return .yellow
        case .miscGettingReady: return .gray
        }
    }
    
    /// Initialize from a stored string value
    static func from(_ string: String?) -> ActivityType {
        guard let string = string else { return .miscGettingReady }
        return ActivityType(rawValue: string) ?? .miscGettingReady
    }
}
