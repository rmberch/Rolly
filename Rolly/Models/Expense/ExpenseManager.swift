//
//  ExpenseManager.swift
//  Rolly
//
//  Created by Ryan Berch on 2/20/26.
//

import Foundation
import Combine



class ExpenseManager: ObservableObject {
    @Published var currentExpenses: [Expense] {
        didSet { save() }
    }
    
    @Published var month: Int
    @Published var previousExpenses: [Expense]

    private let currentExpensesKey = "expenses"
    private let previousExpensesKey = "previousExpenses"
    private let monthKey = "month"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: currentExpensesKey),
           let decoded = try? JSONDecoder().decode([Expense].self, from: data) {
            self.currentExpenses = decoded
        } else {
            self.currentExpenses = []
        }
        
        if let data = UserDefaults.standard.data(forKey: monthKey),
           let decodedMonth = try? JSONDecoder().decode(Int.self, from: data) {
            self.month = decodedMonth
        } else {
            self.month = Calendar.current.component(.month, from: Date())
        }
        
        if let data = UserDefaults.standard.data(forKey: previousExpensesKey),
           let decodedPrev = try? JSONDecoder().decode([Expense].self, from: data) {
            self.previousExpenses = decodedPrev
        } else {
            self.previousExpenses = []
        }
    }
    
    func addExpense(_ expense: Expense) {
        currentExpenses.append(expense)
        save()
    }
    
    func updateExpense(_ expense: Expense) {
        if let index = currentExpenses.firstIndex(where: { $0.id == expense.id }) {
            currentExpenses[index] = expense
            save()
        }
    }
    /*
    func removeExpense(at offsets: IndexSet) {
        currentExpenses.remove(atOffsets: offsets)
        save()
    }
     */
    
    func checkMonth() {
        if Calendar.current.component(.month, from: Date()) != month {
            finalizeExpenses()
        }
    }
    
    func finalizeExpenses() {
        // Move current → previous
        previousExpenses = currentExpenses.isEmpty ? [] : currentExpenses
        currentExpenses = []
        month = Calendar.current.component(.month, from: Date())
        save()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(currentExpenses) {
            UserDefaults.standard.set(encoded, forKey: currentExpensesKey)
        }
        if let monthEncoded = try? JSONEncoder().encode(month) {
            UserDefaults.standard.set(monthEncoded, forKey: monthKey)
        }
        
        if let encodedPrev = try? JSONEncoder().encode(previousExpenses) {
            UserDefaults.standard.set(encodedPrev, forKey: previousExpensesKey)
        } else {
            UserDefaults.standard.removeObject(forKey: previousExpensesKey)
        }
    }
}
