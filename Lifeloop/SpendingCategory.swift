//
//  SpendingCategory.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import Foundation
import SwiftUI

/// Centralized list of spending categories
enum SpendingCategory: String, CaseIterable, Identifiable {
    case foodDrinks = "Food & Drinks"
    case transport = "Transport"
    case shopping = "Shopping"
    case rentBills = "Rent / Bills"
    case subscriptions = "Subscriptions"
    case health = "Health"
    case travel = "Travel"
    case social = "Social"
    case misc = "Misc"
    
    var id: String { rawValue }
    
    var displayName: String { rawValue }
    
    var icon: String {
        switch self {
        case .foodDrinks: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .rentBills: return "house.fill"
        case .subscriptions: return "repeat.circle.fill"
        case .health: return "heart.fill"
        case .travel: return "airplane"
        case .social: return "person.2.fill"
        case .misc: return "ellipsis.circle.fill"
        }
    }
    
    var color: Color {
        switch self {
        case .foodDrinks: return .orange
        case .transport: return .blue
        case .shopping: return .pink
        case .rentBills: return .brown
        case .subscriptions: return .purple
        case .health: return .red
        case .travel: return .cyan
        case .social: return .green
        case .misc: return .gray
        }
    }
    
    /// Initialize from a stored string value
    static func from(_ string: String?) -> SpendingCategory {
        guard let string = string else { return .misc }
        return SpendingCategory(rawValue: string) ?? .misc
    }
}
