//
//  ApplyPaymentSheet.swift
//  FinanceApp
//
//  Created by Ryan Berch on 9/30/25.
//

import SwiftUI

struct ApplyPaymentSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var paymentManager: PaymentManager
    
    var account: Account
    
    @State private var paymentAmount: Double? = nil
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("Required", value: $paymentAmount, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    Text("Payment Amount").bold()
                }
            }
            .navigationTitle("Apply Payment")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if let amount = paymentAmount, amount > 0 {
                            accountManager.applyPayment(amount: amount, to: account.id)
                            if (!account.hasPaymentDue && paymentManager.payments.contains(where: { $0.destID == account.id })) {
                                let payment = paymentManager.payments.first(where: { $0.destID == account.id })!
                                paymentManager.popPayment(id: payment.id)
                            }
                        }
                        dismiss()
                    }) { Image(systemName: "checkmark") }
                }
            }
        }
        .keyboardDoneOverlay()
    }
}
