//
//  RecurringExpenseDetailView.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import SwiftUI

struct RecurringExpenseDetailView: View {
    @EnvironmentObject var recurringExpenseManager: RecurringExpenseManager
    @EnvironmentObject var accountManager: AccountsManager
    @Environment(\.dismiss) var dismiss
    
    @State var expense: RecurringExpense
    @State private var showingDeleteConfirmation = false
    
    var body: some View {
        Form {
            Section(header: Text("Details")) {
                HStack {
                    Text("Name").bold()
                    Spacer()
                    TextField("", text: $expense.name)
                        .multilineTextAlignment(.trailing)
                }
                
                HStack {
                    Text("Amount").bold()
                    Spacer()
                    TextField("0.00", value: $expense.amount, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 120)
                }
                HStack {
                    Text("Amount Varies?").bold()
                    Spacer()
                    Toggle("", isOn: $expense.amountVaries)
                }
                
                Picker("**Frequency**", selection: $expense.frequency) {
                    ForEach(Frequency.allCases, id: \.self) { freq in
                        Text(freq.description).tag(freq)
                    }
                }
                
                DatePicker("**Next Due Date**", selection: $expense.nextDueDate, displayedComponents: .date)
            }
            
            Section(header: Text("Payment Method")) {
                Picker("**Account**", selection: $expense.methodID) {
                    Text("Select Method").tag(nil as UUID?)
                    ForEach(accountManager.accounts.filter { $0.type.canBeBillingMethod }.sorted {$0.name < $1.name}) { account in
                        Text(account.name).tag(account.id as UUID?)
                    }
                }
            }
            
            Section {
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Remove Recurring Expense")
                        Spacer()
                    }
                }
            }
        }
        .navigationTitle(expense.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button(action: {
                    recurringExpenseManager.updateRecurringExpense(expense)
                    dismiss()
                }) {
                    Image(systemName: "checkmark")
                }
            }
        }
        .alert("Delete Recurring Expense?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                recurringExpenseManager.removeRecurringExpense(by: expense.id)
                dismiss()
            }
        } message: {
            Text("This will permanently remove this recurring expense.")
        }
    }
}
