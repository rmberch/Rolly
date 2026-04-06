//
//  RollyApp.swift
//  Rolly
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI

@main
struct RollyApp: App {
    @StateObject private var budget = Budget()
    @StateObject private var accountsManager = AccountsManager()
    @StateObject private var expenseManager = ExpenseManager()
    @StateObject private var paymentManager: PaymentManager
    @StateObject private var recurringExpenseManager: RecurringExpenseManager
    
    init() {
        let accounts = AccountsManager()
        let expenses = ExpenseManager()
        let payments = PaymentManager(accountManager: accounts, expenseManager: expenses)
        let recurringExpenses = RecurringExpenseManager(expenseManager: expenses, accountManager: accounts)
     
        
        _accountsManager = StateObject(wrappedValue: accounts)
        _expenseManager = StateObject(wrappedValue: expenses)
        _paymentManager = StateObject(wrappedValue: payments)
        _recurringExpenseManager = StateObject(wrappedValue: recurringExpenses)
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(budget)
                .environmentObject(accountsManager)
                .environmentObject(expenseManager)
                .environmentObject(paymentManager)
                .environmentObject(recurringExpenseManager)
                .onAppear {
                    expenseManager.checkMonth()
                    paymentManager.checkPayments()
                    recurringExpenseManager.processAllDueExpenses()
                }
        }
    }
}
