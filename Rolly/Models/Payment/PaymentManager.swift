//
//  PaymentManager.swift
//  Rolly
//
//  Created by Ryan Berch on 2/23/26.
//

import Foundation
import Combine

class PaymentManager: ObservableObject {
    private let accountManager: AccountsManager
    private let expenseManager: ExpenseManager
    
    @Published var payments: [Payment] = [] {
        didSet { save() }
    }
    
    private let paymentsKey = "payments"
    
    init(accountManager: AccountsManager, expenseManager: ExpenseManager) {
        self.accountManager = accountManager
        self.expenseManager = expenseManager
        
        if let data = UserDefaults.standard.data(forKey: paymentsKey),
           let decoded = try? JSONDecoder().decode([Payment].self, from: data) {
            self.payments = decoded
        }
    }
    
    func addPayment(_ payment: Payment) {
        payments.append(payment)
        save()
    }
    
    func checkPayments() {
        //for each payment, if payment's date is today, subtract amount for source and dest accounts
        let today = Calendar.current.startOfDay(for: Date())
        for payment in payments {
            let paymentDay = Calendar.current.startOfDay(for: payment.date)
            if (checkValid(payment: payment) && paymentDay <= today)  {
                processPayment(payment: payment)
                save()
            }
        }
    }
    
    func processPayment(payment: Payment) {
        let destAccount = accountManager.accounts.first(where: { $0.id == payment.destID })!
        let expenseName: String = "Payment to \(destAccount.name)"
        let expense = Expense(name: expenseName, amount: payment.amount, methodID: payment.sourceID, date: payment.date, tracked: false)
        
        expenseManager.currentExpenses.append(expense)
        accountManager.applyExpense(amount: payment.amount, to: payment.sourceID)
        accountManager.applyPayment(amount: payment.amount, to: payment.destID)
        
        popPayment(id: payment.id)
    }
    
    func updatePayment(_ updatedPayment: Payment) {
        if let index = payments.firstIndex(where: { $0.id == updatedPayment.id }) {
            payments[index] = updatedPayment
            save()
        }
    }
    
    func popPayment(id: UUID) {
        payments.removeAll { $0.id == id }
        save()
    }
    
    func checkValid(payment: Payment) -> Bool {
        let destAccount = accountManager.accounts.first(where: { $0.id == payment.destID })!
        if (!destAccount.hasPaymentDue) {
            popPayment(id: payment.id)
            return false
        }
        
        return true
    }
    
    private func save() {
        if let encodedPayments = try? JSONEncoder().encode(payments) {
            UserDefaults.standard.set(encodedPayments, forKey: paymentsKey)
        }
    }
}
