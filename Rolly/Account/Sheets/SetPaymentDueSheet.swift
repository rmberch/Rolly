//
//  SetPaymentDueSheet.swift
//  FinanceApp
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI

struct SetPaymentDueSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var accountManager: AccountsManager
    
    var account: Account
    
    @State private var dueDate = Date()
    @State private var paymentAmount: Double? = nil
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("", value: $paymentAmount, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    Text("Statement Balance").bold()
                }
                
                DatePicker("Due Date", selection: $dueDate, displayedComponents: .date)
            }
            .navigationTitle("Set Payment Due")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if let amount = paymentAmount, amount > 0 {
                            accountManager.setPaymentDue(
                                for: account,
                                amount: amount,
                                dueDate: dueDate
                            )
                        }
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            paymentAmount = account.currentBalance
        }
        .keyboardDoneOverlay()
    }
}
