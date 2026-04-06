//
//  ExpenseListView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI

struct ExpenseRowView: View {
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var expenseManager: ExpenseManager
    
    let expense: Expense
    @Binding var selectedExpense: Expense?
    
    var body: some View {
        VStack {
            HStack {
                Text(expense.name)
                    .font(.headline)
                Spacer()
                Text("$\(expense.amount, specifier: "%.2f")")
                    .fontWeight(.semibold)
            }
            .padding(.bottom, 2)
            HStack {
                Text("\(expense.date.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(accountName(for: expense.methodID))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                if let index = expenseManager.currentExpenses.firstIndex(where: { $0.id == expense.id }) {
                    expenseManager.currentExpenses.remove(at: index)
                    accountManager.applyExpense(amount: -expense.amount, to: expense.methodID)
                }
            } label: {
                Label("Delete", systemImage: "trash")
            }
        }
        .swipeActions(edge: .leading) {
            Button {
                selectedExpense = expense
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
            
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
