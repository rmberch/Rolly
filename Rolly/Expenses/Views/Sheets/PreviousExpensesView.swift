//
//  PreviousExpensesView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI

struct PreviousExpensesView: View {
    @EnvironmentObject var expenseManager: ExpenseManager
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var budget: Budget
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            let previousExpenses = expenseManager.previousExpenses
            if !previousExpenses.isEmpty {
                let trackedExpenses = previousExpenses.filter({ $0.isTracked })
                let untrackedExpenses = previousExpenses.filter( { $0.isTracked == false })
                List {
                    // --- Summary ---
                    Section(header: Text("Last Month's Summary")) {
                        HStack {
                            Text("Number of Transactions")
                            Spacer()
                            Text("\(previousExpenses.count)")
                        }
                        HStack {
                            Text("Total Amount Spent")
                            Spacer()
                            Text("$\(previousExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Expenses")
                            Spacer()
                            Text("$\(trackedExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Bils")
                            Spacer()
                            Text("$\(untrackedExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Amount Remaining")
                            Spacer()
                            Text("$\(budget.amount - trackedExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        
                    }
                    if !untrackedExpenses.isEmpty {
                        Section(header: Text("Bills")) {
                            ForEach(untrackedExpenses) { expense in
                                PreviousExpenseRowView(expense: expense)
                            }
                        }
                    }
                    
                    // --- Expenses List ---
                    if !trackedExpenses.isEmpty {
                        Section(header: Text("Expenses")) {
                            ForEach(trackedExpenses) { expense in
                                PreviousExpenseRowView(expense: expense)
                            }
                        }
                    }
                }
                .navigationTitle("Previous Expenses")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: { dismiss() }) { Image(systemName: "checkmark") }
                    }
                }
            } else {
                // --- No Previous Expenses ---
                VStack {
                    Spacer()
                    Text("No previous expenses were found.")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .navigationTitle("Previous Expenses")
                .toolbar {
                    ToolbarItem(placement: .confirmationAction) {
                        Button(action: { dismiss() }) { Image(systemName: "checkmark") }
                    }
                }
            }
        }
    }
    private func accountName(for id: UUID?) -> String {
        guard let id = id,
              let account = accountManager.accounts.first(where: { $0.id == id }) else {
            return "Unknown Account"
        }
        return account.name
    }
}

struct PreviousExpenseRowView: View {
    @EnvironmentObject var accountManager: AccountsManager
    let expense: Expense
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(expense.name)
                    .font(.headline)
                Spacer()
                Text(accountName(for: expense.methodID))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            HStack {
                Text("Amount:")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(expense.amount, format: .currency(code: "USD"))")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Text("Date:")
                    .font(.footnote)
                    .foregroundColor(.secondary)
                Spacer()
                Text(expense.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func accountName(for id: UUID?) -> String {
        guard let id = id,
              let account = accountManager.accounts.first(where: { $0.id == id }) else {
            return "Unknown Account"
        }
        return account.name
    }
}
