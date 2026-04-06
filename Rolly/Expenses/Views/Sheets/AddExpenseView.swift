//
//  AddExpenseView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI

struct AddExpenseSheet: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var expenseManager: ExpenseManager
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var budget: Budget
    
    //Temporary variables for adding a new expense
    @State private var expenseName = ""
    @State private var expenseAmount: Double? = nil
    @State private var expenseMethod: UUID?
    @State private var expenseDate: Date = Date()
    
    var onAdd: (Expense) -> Void
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("Required", text: $expenseName)
                        .multilineTextAlignment(.trailing)
                } label : {
                    Text("Name").bold()
                }
                
                LabeledContent {
                    TextField("Required", value: $expenseAmount, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    Text("Amount").bold()
                }
                Picker("**Method**", selection: $expenseMethod) {
                    Text("Select Method").tag(nil as UUID?)
                    ForEach(accountManager.accounts.filter {$0.type.canBePaymentMethod}.sorted {$0.name < $1.name}) { account in
                        Text(account.name).tag(account.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
                
                DatePicker("**Date**", selection: $expenseDate, displayedComponents: [.date])
            }
            .navigationTitle("Add Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        dismiss()
                    }) { Image(systemName: "chevron.backward")}
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if (!expenseName.isEmpty && expenseAmount != nil && expenseAmount != 0.0 && expenseMethod != nil) {
                            let expense = Expense(name: expenseName, amount: expenseAmount!, methodID: expenseMethod!, date: expenseDate, tracked: true)
                            onAdd(expense)
                            dismiss()
                        }
                        else { return }
                    }) { Image(systemName: "checkmark") }
                    .disabled(expenseName.isEmpty || expenseAmount == nil || expenseMethod == nil)
                }
            }
        }
        .keyboardDoneOverlay()
    }
}
