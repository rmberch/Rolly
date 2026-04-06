//
//  AddAccountView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI

public struct AddAccountView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var accountManager: AccountsManager
    
    @State private var name = ""
    @State private var selectedType: AccountType = .checking
    @State private var balance: Double?
    
    @State private var hasPaymentDue = false
    @State private var paymentDueDate: Date = Date()
    @State private var paymentDueAmount: Double?
    
    @State private var errorMessage: String?
    
    public var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("Required", text: $name)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Name").bold()
                }
                
                Picker("Account Type", selection: $selectedType) {
                    ForEach(AccountType.allCases) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                
                LabeledContent {
                    TextField("Required", value: $balance, format: .currency(code: "USD"))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                } label: {
                    Text("Balance").bold()
                }
                
                if selectedType.tracksPaymentDue {
                    Toggle("**Has Payment Due?**", isOn: $hasPaymentDue)

                    if hasPaymentDue {
                        LabeledContent {
                            TextField("Required", value: $paymentDueAmount, format: .currency(code: "USD"))
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.trailing)
                        } label: {
                            Text("Amount Due").bold()
                        }

                        DatePicker("**Payment Due Date**", selection: $paymentDueDate, displayedComponents: [.date])
                    }
                }
            }
            .navigationTitle("New Account")
            .toolbar {
                 ToolbarItem(placement: .cancellationAction) {
                     Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
                 }
                 ToolbarItem(placement: .confirmationAction) {
                     Button(action: { addAccount() }) { Image(systemName: "checkmark") }
                     .disabled(name.isEmpty)
                 }
             }
        }
        //.keyboardDoneOverlay()
    }
    
    private func addAccount() {
        guard !name.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Account name cannot be empty."
            return
        }

        guard let balance = balance else {
            errorMessage = "Balance must be a valid number."
            return
        }

        let newAccount = Account(
            name: name.trimmingCharacters(in: .whitespaces),
            type: selectedType,
            currentBalance: balance,
            initialBalance: balance,
            hasPaymentDue: hasPaymentDue,
            paymentDueDate: hasPaymentDue ? paymentDueDate : nil,
            paymentAmount: hasPaymentDue ? paymentDueAmount : nil
        )

        accountManager.addAccount(newAccount)
        dismiss()
    }
}
