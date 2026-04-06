//
//  RecurringExpensesView.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import SwiftUI

struct RecurringExpensesView: View {
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var recurringExpenseManager: RecurringExpenseManager
    @State private var showingAddRecurringExpense = false
    
    public var body: some View {
        List {
            if recurringExpenseManager.recurringExpenses.isEmpty {
                Section {
                    Text("No recurring expenses added yet.")
                        .foregroundColor(.secondary)
                }
            } else {
                let subscriptions = recurringExpenseManager.recurringExpenses
                    .filter { $0.type == .subscription }
                    .sorted{ $0.name < $1.name }
                let bills = recurringExpenseManager.recurringExpenses
                    .filter { $0.type == .bill }
                    .sorted{ $0.name < $1.name }
                
                if !bills.isEmpty {
                    Section(header: Text("Bills")) {
                        ForEach(bills) { recurringExpense in
                            NavigationLink(destination: RecurringExpenseDetailView(expense: recurringExpense)) {
                                Text(recurringExpense.name)
                            }
                        }
                        .onDelete(perform: recurringExpenseManager.removeRecurringExpense)
                    }
                }
                
                if !subscriptions.isEmpty {
                    Section(header: Text("Subscriptions")) {
                        ForEach(subscriptions) { recurringExpense in
                            NavigationLink(destination: RecurringExpenseDetailView(expense: recurringExpense)) {
                                Text(recurringExpense.name)
                            }
                        }
                        .onDelete(perform: recurringExpenseManager.removeRecurringExpense)
                    }
                }
            }
            
            Section {
                Button { showingAddRecurringExpense = true } label: {
                    HStack {
                        Spacer()
                        Text("Add Recurring Expense").font(.headline)
                        Spacer()
                    }
                }
                .tint(.blue)
            }
        }
        .navigationTitle("Recurring Expenses")
        .sheet(isPresented: $showingAddRecurringExpense) {
            AddRecurringExpenseView()
                .environmentObject(recurringExpenseManager)
                .environmentObject(accountManager)
        }
    }
}
