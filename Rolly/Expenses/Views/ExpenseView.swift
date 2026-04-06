//
//  ExpenseView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI

struct ExpenseView: View {
    // Stores list of expenses
    @EnvironmentObject var expenseManager: ExpenseManager
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var budget: Budget
    
    @State private var showingAddExpenseSheet: Bool = false
    @State private var showingViewPreviousExpenses: Bool = false
    @State private var showingSetSpendingLimit: Bool = false
    
    // Variables for editing
    @State private var selectedExpense: Expense? = nil
    
    private var trackedExpenses: [Expense] {
        expenseManager.currentExpenses
            .filter({ $0.isTracked })
            .sorted { $0.date > $1.date}
    }
    
    private var untrackedExpenses: [Expense] {
        expenseManager.currentExpenses
            .filter({ $0.isTracked == false })
            .sorted { $0.date > $1.date }
    }
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottomTrailing) {
                // MARK: - Main List
                List {
                    
                    
                    // MARK: Summary Section
                    Section(header: Text("This Month's Summary")) {
                        HStack {
                            Text("Number of Transactions")
                            Spacer()
                            Text("\(expenseManager.currentExpenses.count)")
                        }
                        HStack {
                            Text("Expenses")
                            Spacer()
                            Text("$\(trackedExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Amount Remaining")
                            Spacer()
                            Text("$\(budget.amount - trackedExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        HStack {
                            Text("Bills")
                            Spacer()
                            Text("$\(untrackedExpenses.reduce(0) { $0 + $1.amount }, specifier: "%.2f")")
                        }
                        
                    }
                    
                    if !untrackedExpenses.isEmpty {
                        Section(header: Text("Bills")) {
                            ForEach(untrackedExpenses) { expense in ExpenseRowView(expense: expense, selectedExpense: $selectedExpense)
                            }
                        }
                    }
                    
                    // MARK: Expenses Section
                    Section(header: Text("Expenses")) {
                        if !trackedExpenses.isEmpty {
                            ForEach(trackedExpenses) { expense in
                                ExpenseRowView(expense: expense, selectedExpense: $selectedExpense)
                            }
                        } else {
                            Text("No expenses added yet.")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // MARK: Spacer Section
                    Section {
                        Color.clear
                            .frame(height: 5)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.insetGrouped)
                .navigationTitle(Text("Expenses"))
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("Set Spending Limit") {
                                showingSetSpendingLimit = true
                            }
                            Button("View Previous Expenses") {
                                showingViewPreviousExpenses = true
                            }
                        } label: {
                            Image(systemName: "ellipsis")
                        }
                    }
                }

                // MARK: Floating Add Button
                Button(action: {
                    showingAddExpenseSheet = true
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.blue)
                        .padding()
                        .clipShape(Circle())
                        .shadow(radius: 5)
                }
                .buttonStyle(.glass)
                .padding(.trailing, 20)
                .padding(.bottom, 15)
            }
            // MARK: Sheets
            .sheet(item: $selectedExpense) { expense in
                if let index = expenseManager.currentExpenses.firstIndex(where: { $0.id == expense.id }) {
                    EditExpenseView(
                        expense: $expenseManager.currentExpenses[index],
                        onSave: { updatedExpense in
                            accountManager.applyExpense(amount: 0 - expense.amount, to: expense.methodID)
                            accountManager.applyExpense(amount: updatedExpense.amount, to: updatedExpense.methodID)
                            expenseManager.currentExpenses[index] = updatedExpense
                            selectedExpense = nil
                        },
                        onCancel: {
                            selectedExpense = nil
                        }
                    )
                }
            }
            .sheet(isPresented: $showingAddExpenseSheet) {
                AddExpenseSheet { expense in
                    expenseManager.addExpense(expense)
                    accountManager.applyExpense(amount: expense.amount, to: expense.methodID)
                }
            }
            .sheet(isPresented: $showingViewPreviousExpenses) {
                PreviousExpensesView()
            }
            .sheet(isPresented: $showingSetSpendingLimit) {
                SpendingLimitSheet()
            }
        }
        .keyboardDoneOverlay()
    }
}
