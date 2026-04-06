//
//  HomeView.swift
//  Rolly
//
//  Created by Ryan Berch on 3/13/26.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var expenseManager: ExpenseManager
    @EnvironmentObject var paymentManager: PaymentManager
    @EnvironmentObject var recurringExpenseManager: RecurringExpenseManager
    @EnvironmentObject var budget: Budget
    
    
    
    private var primaryAccountID: UUID? {
        accountManager.primaryAccount
    }
    
    private var upcomingRecurringExpenses: [RecurringExpense] {
        recurringExpenseManager.recurringExpenses
            .filter({ $0.nextDueDate < Calendar.current.date(byAdding: .day, value: 7, to: Date())!})
            .sorted { $0.nextDueDate < $1.nextDueDate }
    }
    
    private var upcomingPayments: [Payment] {
        paymentManager.payments
            .filter({ $0.date < Calendar.current.date(byAdding: .day, value: 7, to: Date())!})
            .sorted { $0.date < $1.date }
    }
    
    var body: some View {
        NavigationStack {
            if (primaryAccountID == nil && upcomingPayments.isEmpty && upcomingRecurringExpenses.isEmpty) {
                VStack {
                    Text("Go to settings to get started.")
                }
                .navigationTitle("Balances")
            }
            else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        if (primaryAccountID != nil) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Primary Account")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                primaryAccountCard(for: accountManager.account(for: primaryAccountID!)!)
                            }
                        }
                        
                        if (!upcomingPayments.isEmpty) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upcoming Payments")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                ForEach(upcomingPayments) { payment in
                                    recurringPaymentCard(for: payment)
                                }
                            }
                        }
                    
                        if (!upcomingRecurringExpenses.isEmpty) {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Upcoming Recurring Expenses")
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                ForEach(upcomingRecurringExpenses) { expense in
                                    recurringExpenseCard(for: expense)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Home")
            }
        }
    }
    
    private func primaryAccountCard(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(account.name)
                    .font(.headline)
            }
            
            Divider()
            HStack {
                Text("Current Balance:")
                    .font(.subheadline)
                Spacer()
                Text(account.currentBalance, format: .currency(code: "USD"))
                    .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    private func recurringPaymentCard(for payment: Payment) -> some View {
        let destAccount = accountManager.accounts.first(where: { $0.id == payment.destID })!
        let sourceAccount = accountManager.accounts.first(where: { $0.id == payment.sourceID })!
        
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(destAccount.name)
                    .font(.headline)
                Spacer()
                Text(payment.amount, format: .currency(code: "USD"))
                    .font(.headline)
            }
            
            Divider()
            HStack{
                Text("Source:")
                    .font(.subheadline)
                Spacer()
                Text(sourceAccount.name)
                    .font(.subheadline)
            }
            
            HStack {
                Text("Date:")
                    .font(.subheadline)
                Spacer()
                Text(payment.date.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
    
    private func recurringExpenseCard(for expense: RecurringExpense) -> some View {
        let method = accountManager.accounts.first(where: { $0.id == expense.methodID })!
        return VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(expense.name)
                    .font(.headline)
                Spacer()
                Text(expense.type.displayName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Divider()
            HStack {
                Text("Amount:")
                    .font(.subheadline)
                Spacer()
                Text(expense.amount, format: .currency(code: "USD"))
                    .font(.subheadline)
            }
            HStack {
                Text("Method:")
                    .font(.subheadline)
                Spacer()
                Text(method.name)
                    .font(.subheadline)
            }
            HStack {
                Text("Date:")
                    .font(.subheadline)
                Spacer()
                Text(expense.nextDueDate.formatted(date: .abbreviated, time: .omitted))
                    .font(.subheadline)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}
