//
//  SpendingView.swift
//  Lifeloop
//
//  Created by Anuj S on 17/01/2026.
//

import CoreData
import SwiftUI

// MARK: - Spending View (History)

struct SpendingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \SpendingEntry.date, ascending: false)],
        animation: .default
    )
    private var allSpending: FetchedResults<SpendingEntry>
    
    @State private var showingAddSpending = false
    @State private var spendingToEdit: SpendingEntry?
    
    private var groupedDates: [Date] {
        var dates = Set<Date>()
        
        for entry in allSpending {
            if let date = entry.date {
                dates.insert(Calendar.current.startOfDay(for: date))
            }
        }
        
        return dates.sorted(by: >)
    }
    
    var body: some View {
        NavigationStack {
            List {
                if groupedDates.isEmpty {
                    ContentUnavailableView(
                        "No Spending",
                        systemImage: "creditcard",
                        description: Text("Your spending entries will appear here")
                    )
                } else {
                    ForEach(groupedDates, id: \.self) { date in
                        Section {
                            let entriesForDate = allSpending
                                .filter { entry in
                                    guard let entryDate = entry.date else { return false }
                                    return Calendar.current.isDate(entryDate, inSameDayAs: date)
                                }
                                .sorted { ($0.createdAt ?? Date()) > ($1.createdAt ?? Date()) }
                            
                            // Daily total
                            let dailyTotal = entriesForDate.reduce(Decimal(0)) { $0 + ($1.amount as Decimal? ?? 0) }
                            HStack {
                                Text("Daily Total")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text(dailyTotal, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                                    .font(.subheadline)
                                    .fontWeight(.semibold)
                            }
                            
                            // Individual entries
                            ForEach(entriesForDate) { entry in
                                SpendingRowView(entry: entry)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        spendingToEdit = entry
                                    }
                            }
                            .onDelete { offsets in
                                deleteEntries(entriesForDate, at: offsets)
                            }
                        } header: {
                            Text(date, style: .date)
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .navigationTitle("Spending")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingAddSpending = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddSpending) {
                AddEditSpendingView(entry: nil)
            }
            .sheet(item: $spendingToEdit) { entry in
                AddEditSpendingView(entry: entry)
            }
        }
    }
    
    private func deleteEntries(_ entries: [SpendingEntry], at offsets: IndexSet) {
        withAnimation {
            offsets.map { entries[$0] }.forEach(viewContext.delete)
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

// MARK: - Spending Row View

struct SpendingRowView: View {
    @ObservedObject var entry: SpendingEntry
    
    private var category: SpendingCategory {
        SpendingCategory.from(entry.category)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Category icon
            Image(systemName: category.icon)
                .font(.title3)
                .foregroundStyle(category.color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(category.displayName)
                    .font(.body)
                
                if let notes = entry.notes, !notes.isEmpty {
                    Text(notes)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            Text(entry.amount as Decimal? ?? 0, format: .currency(code: Locale.current.currency?.identifier ?? "USD"))
                .font(.body)
                .fontWeight(.medium)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Add/Edit Spending View

struct AddEditSpendingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    
    let entry: SpendingEntry?
    
    @State private var amount: Decimal = 0
    @State private var amountString: String = ""
    @State private var category: SpendingCategory = .misc
    @State private var notes: String = ""
    @State private var date: Date = Date()
    
    private var isEditing: Bool { entry != nil }
    
    var body: some View {
        NavigationStack {
            Form {
                // Amount
                Section {
                    HStack {
                        Text(Locale.current.currency?.identifier ?? "USD")
                            .foregroundStyle(.secondary)
                        TextField("0.00", text: $amountString)
                            .keyboardType(.decimalPad)
                            .onChange(of: amountString) { _, newValue in
                                // Parse the amount
                                let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                if filtered != newValue {
                                    amountString = filtered
                                }
                                if let decimal = Decimal(string: filtered) {
                                    amount = decimal
                                }
                            }
                    }
                } header: {
                    Text("Amount")
                }
                
                // Category
                Section {
                    Picker("Category", selection: $category) {
                        ForEach(SpendingCategory.allCases) { cat in
                            Label(cat.displayName, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    .pickerStyle(.navigationLink)
                } header: {
                    Text("Category")
                }
                
                // Notes
                Section {
                    TextField("Notes (optional)", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                } header: {
                    Text("Notes")
                }
                
                // Date
                Section {
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                }
                
                // Delete button (only if editing)
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
            .navigationTitle(isEditing ? "Edit Spending" : "Add Spending")
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
                    .disabled(amount <= 0)
                }
            }
            .onAppear {
                if let entry = entry {
                    amount = entry.amount as Decimal? ?? 0
                    amountString = "\(amount)"
                    category = SpendingCategory.from(entry.category)
                    notes = entry.notes ?? ""
                    date = entry.date ?? Date()
                }
            }
        }
    }
    
    private func saveEntry() {
        let spendingEntry = entry ?? SpendingEntry(context: viewContext)
        
        if entry == nil {
            spendingEntry.id = UUID()
            spendingEntry.createdAt = Date()
        }
        
        spendingEntry.amount = NSDecimalNumber(decimal: amount)
        spendingEntry.category = category.rawValue
        spendingEntry.notes = notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : notes.trimmingCharacters(in: .whitespacesAndNewlines)
        spendingEntry.date = Calendar.current.startOfDay(for: date)
        
        do {
            try viewContext.save()
            dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func deleteEntry() {
        guard let entry = entry else { return }
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

// MARK: - Preview

#Preview {
    SpendingView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
