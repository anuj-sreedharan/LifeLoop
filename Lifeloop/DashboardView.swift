//
//  DashboardView.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import CoreData
import SwiftUI

// MARK: - Dashboard View

struct DashboardView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    // Today's activities
    @FetchRequest private var todaysActivities: FetchedResults<HourlyActivityEntry>
    
    // Today's skincare
    @FetchRequest private var todaysSkincare: FetchedResults<SkincareEntry>
    
    // This week's spending (last 7 days)
    @FetchRequest private var weekSpending: FetchedResults<SpendingEntry>
    
    init() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let tomorrow = calendar.date(byAdding: .day, value: 1, to: today)!
        let weekAgo = calendar.date(byAdding: .day, value: -6, to: today)!
        
        // Today's activities
        let activityPredicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        _todaysActivities = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \HourlyActivityEntry.hour, ascending: true)],
            predicate: activityPredicate,
            animation: .default
        )
        
        // Today's skincare
        let skincarePredicate = NSPredicate(format: "date >= %@ AND date < %@", today as NSDate, tomorrow as NSDate)
        _todaysSkincare = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \SkincareEntry.timeOfDay, ascending: true)],
            predicate: skincarePredicate,
            animation: .default
        )
        
        // This week's spending (including today)
        let spendingPredicate = NSPredicate(format: "date >= %@ AND date < %@", weekAgo as NSDate, tomorrow as NSDate)
        _weekSpending = FetchRequest(
            sortDescriptors: [NSSortDescriptor(keyPath: \SpendingEntry.date, ascending: false)],
            predicate: spendingPredicate,
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
                            
                            Text("Daily Overview")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                }
                
                // Section 1: Today at a Glance
                Section {
                    // Hours logged
                    DashboardRowView(
                        icon: "clock.fill",
                        iconColor: .blue,
                        title: "Hours Logged",
                        value: "\(todaysActivities.count)/24"
                    )
                    
                    // AM Skincare
                    DashboardRowView(
                        icon: "sun.max.fill",
                        iconColor: amSkincareStatus.color,
                        title: "AM Skincare",
                        value: amSkincareStatus.displayName
                    )
                    
                    // PM Skincare
                    DashboardRowView(
                        icon: "moon.fill",
                        iconColor: pmSkincareStatus.color,
                        title: "PM Skincare",
                        value: pmSkincareStatus.displayName
                    )
                    
                    // Today's spending
                    DashboardRowView(
                        icon: "creditcard.fill",
                        iconColor: .green,
                        title: "Spent Today",
                        value: todaySpendingFormatted
                    )
                } header: {
                    Label("Today at a Glance", systemImage: "eye")
                }
                
                // Section 2: This Week
                Section {
                    // Total spent
                    DashboardRowView(
                        icon: "chart.bar.fill",
                        iconColor: .purple,
                        title: "Total (7 days)",
                        value: weekTotalFormatted
                    )
                    
                    // Average per day
                    DashboardRowView(
                        icon: "divide",
                        iconColor: .orange,
                        title: "Daily Average",
                        value: dailyAverageFormatted
                    )
                    
                    // Top category
                    if let topCategory = topSpendingCategory {
                        DashboardRowView(
                            icon: topCategory.icon,
                            iconColor: topCategory.color,
                            title: "Top Category",
                            value: topCategory.displayName
                        )
                    }
                } header: {
                    Label("This Week", systemImage: "calendar")
                }
            }
            .navigationTitle("Dashboard")
        }
    }
    
    // MARK: - Computed Properties
    
    private var amSkincareStatus: SkincareSlotStatus {
        guard let entry = todaysSkincare.first(where: { $0.timeOfDay == SkincareTimeOfDay.am.rawValue }) else {
            return .notLogged
        }
        return SkincareSlotStatus.from(entry.status)
    }
    
    private var pmSkincareStatus: SkincareSlotStatus {
        guard let entry = todaysSkincare.first(where: { $0.timeOfDay == SkincareTimeOfDay.pm.rawValue }) else {
            return .notLogged
        }
        return SkincareSlotStatus.from(entry.status)
    }
    
    private var todaySpending: Decimal {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        return weekSpending
            .filter { entry in
                guard let date = entry.date else { return false }
                return calendar.isDate(date, inSameDayAs: today)
            }
            .reduce(Decimal(0)) { $0 + ($1.amount as Decimal? ?? 0) }
    }
    
    private var todaySpendingFormatted: String {
        formatCurrency(todaySpending)
    }
    
    private var weekTotal: Decimal {
        weekSpending.reduce(Decimal(0)) { $0 + ($1.amount as Decimal? ?? 0) }
    }
    
    private var weekTotalFormatted: String {
        formatCurrency(weekTotal)
    }
    
    private var dailyAverage: Decimal {
        weekTotal / 7
    }
    
    private var dailyAverageFormatted: String {
        formatCurrency(dailyAverage)
    }
    
    private var topSpendingCategory: SpendingCategory? {
        var categoryTotals: [SpendingCategory: Decimal] = [:]
        
        for entry in weekSpending {
            let category = SpendingCategory.from(entry.category)
            categoryTotals[category, default: 0] += (entry.amount as Decimal? ?? 0)
        }
        
        return categoryTotals.max(by: { $0.value < $1.value })?.key
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = Locale.current.currency?.identifier ?? "USD"
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0.00"
    }
}

// MARK: - Dashboard Row View

struct DashboardRowView: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(iconColor)
                .frame(width: 28)
            
            Text(title)
                .font(.body)
            
            Spacer()
            
            Text(value)
                .font(.body)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
