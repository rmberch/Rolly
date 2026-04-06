//
//  EditExpenseView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI

struct EditExpenseView: View {
    @Binding var expense: Expense
    var onSave: (Expense) -> Void
    var onCancel: () -> Void
    
    @State private var tempExpense: Expense
    @EnvironmentObject var accounts: AccountsManager

    init(expense: Binding<Expense>, onSave: @escaping (Expense) -> Void, onCancel: @escaping () -> Void) {
        self._expense = expense
        self.onSave = onSave
        self.onCancel = onCancel
        self._tempExpense = State(initialValue: expense.wrappedValue) // ADD
    }
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("", text: $expense.name)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Name").bold()
                }
                LabeledContent {
                    TextField("", value: $expense.amount, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    Text("Amount").bold()
                }
                
                Picker("**Method**", selection: $expense.methodID) {
                    Text("Select Method").tag(nil as UUID?)
                    ForEach(accounts.accounts.filter {$0.type.canBePaymentMethod}.sorted {$0.name < $1.name}) { account in
                        Text(account.name).tag(account.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                
                DatePicker("**Date**", selection: $expense.date, displayedComponents: [.date])
            }
            .navigationTitle("Edit Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action:{ onSave(tempExpense) }) { Image(systemName: "chevron.backward") }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { onSave(expense) }) { Image(systemName: "checkmark")}
                }
            }
        }
        .keyboardDoneOverlay()
    }
}
