//
//  RecurringExpensePayment.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import Foundation
import Combine
import SwiftUI

class RecurringExpenseManager: ObservableObject {
    @Published var recurringExpenses: [RecurringExpense] = []
    private let storageKey = "recurring_expenses"
    
    // MARK: - Dependencies
    private let expenseManager: ExpenseManager
    private let accountManager: AccountsManager
    
    // MARK: - Initializer
    init(expenseManager: ExpenseManager,
         accountManager: AccountsManager) {
        self.expenseManager = expenseManager
        self.accountManager = accountManager
        load()
    }
    
    // MARK: - Add Expense
    @MainActor func addRecurringExpense(_ expense: RecurringExpense) {
        recurringExpenses.append(expense)
        save()
    }
    
    // MARK: - Check and Process All Due or Past-Due Expenses
    func processAllDueExpenses(currentDate: Date = Date()) {
        // Normalize current date to start of day (ignore time)
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: currentDate)
        
        for i in recurringExpenses.indices {
            var expense = recurringExpenses[i]
            
            // Normalize next due date as well
            var nextDue = calendar.startOfDay(for: expense.nextDueDate)
            
            // Process missed or due cycles one by one
            while nextDue <= today {
                processDueExpense(&expense)
                nextDue = calendar.startOfDay(for: expense.nextDueDate)
            }
            
            // Update array with modified expense
            recurringExpenses[i] = expense
        }
        
        save()
    }
    
    
    // MARK: - Process a Single Due Expense
    private func processDueExpense(_ expense: inout RecurringExpense) {
        switch expense.type {
        case .subscription:
            // Always tracked — real money spent
            let newExpense = Expense(
                name: expense.name,
                amount: expense.amount,
                methodID: expense.methodID,
                date: Date(),
                tracked: true
            )
            expenseManager.addExpense(newExpense)
            accountManager.applyExpense(amount: newExpense.amount, to: newExpense.methodID)
            
        case .bill:
            // Applies to card, but not to spending limit
            let newExpense = Expense(
                name: expense.name,
                amount: expense.amount,
                methodID: expense.methodID,
                date: Date(),
                tracked: false
            )
            expenseManager.addExpense(newExpense)
            accountManager.applyExpense(amount: newExpense.amount, to: newExpense.methodID)
            
        }
            
        expense.advanceDueDate()
        save()
        }
        
        
        // MARK: - Storage
        private func save() {
            if let data = try? JSONEncoder().encode(recurringExpenses) {
                UserDefaults.standard.set(data, forKey: storageKey)
            }
        }
        
        private func load() {
            guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }

            do {
                let decoded = try JSONDecoder().decode([RecurringExpense].self, from: data)
                self.recurringExpenses = decoded
            } catch {
                print("⚠️ Failed to decode recurring expenses: \(error)")
                // Keep existing data in memory but don’t overwrite
                self.recurringExpenses = []
            }
        }
        
        func removeRecurringExpense(at offsets: IndexSet) {
            recurringExpenses.remove(atOffsets: offsets)
            save()
        }
    
        func updateRecurringExpense(_ updatedExpense: RecurringExpense) {
            if let index = recurringExpenses.firstIndex(where: { $0.id == updatedExpense.id }) {
                recurringExpenses[index] = updatedExpense
                save()
            }
        }
        
        func removeRecurringExpense(by id: UUID) {
            recurringExpenses.removeAll { $0.id == id }
            save()
        }

    }

