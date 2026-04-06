//
//  RERowView.swift
//  Rolly
//
//  Created by Ryan Berch on 3/13/26.
//

import SwiftUI

struct RecurringExpenseRowView: View {
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var expenseManager: ExpenseManager
    
    let expense: RecurringExpense
    
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
                Text("\(expense.nextDueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
                Text(accountName(for: expense.methodID))
                    .font(.caption)
                    .foregroundColor(.gray)
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
