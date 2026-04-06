//
//  AddRecurringExpenseView.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import SwiftUI

struct AddRecurringExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var recurringExpenseManager: RecurringExpenseManager
    @EnvironmentObject var accountsManager: AccountsManager
    
    // MARK: - Form Fields
    @State private var expenseName: String = ""
    @State private var expenseAmount: Double? = nil
    @State private var expenseVaries: Bool = false
    @State private var expenseMethod: UUID?
    @State private var expenseType: RecurringType = .bill
    @State private var expenseFrequency: Frequency = .monthly
    @State private var expenseDueDate: Date = Date()
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("Required", text: $expenseName)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Name").bold()
                }
                
                LabeledContent {
                    TextField("Required", value: $expenseAmount, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    Text("Amount").bold()
                }
                
                HStack {
                    Text("Amount Varies?").bold()
                    Spacer()
                    Toggle("", isOn: $expenseVaries)
                }
                
                Picker("**Type**", selection: $expenseType) {
                    ForEach(RecurringType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
                
                Picker("**Frequency**", selection: $expenseFrequency) {
                    ForEach(Frequency.allCases, id: \.self) { freq in
                        Text(freq.description).tag(freq)
                    }
                }
                .pickerStyle(.menu)
                
                DatePicker("**First Due Date**", selection: $expenseDueDate, displayedComponents: [.date])
                
                Picker("**Payment Method**", selection: $expenseMethod) {
                    Text("Select Method").tag(nil as UUID?)
                    ForEach(accountsManager.accounts.filter { $0.type.canBeBillingMethod }.sorted {$0.name < $1.name}) { account in
                        Text(account.name).tag(account.id as UUID?)
                    }
                }
                .pickerStyle(.menu)
            }
            .navigationTitle("Add Recurring Expense")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.backward")}
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: { addRecurringExpense() }) { Image(systemName: "checkmark") }
                    .disabled(expenseName.isEmpty || expenseAmount == nil || expenseMethod == nil)
                }
            }
        }
        .keyboardDoneOverlay()
    }
    
    // MARK: - Add Recurring Expense
    private func addRecurringExpense() {
        guard let amount = expenseAmount,
              let methodID = expenseMethod else { return }
        
        let newExpense = RecurringExpense(
            name: expenseName,
            amount: amount,
            methodID: methodID,
            type: expenseType,
            dueDate: expenseDueDate,
            frequency: expenseFrequency
        )
        
        Task { @MainActor in
            recurringExpenseManager.addRecurringExpense(newExpense)
            dismiss()
        }
    }
}
