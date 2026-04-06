//
//  UpdateBalanceSheet.swift
//  FinanceApp
//
//  Created by Ryan Berch on 9/18/25.
//

import SwiftUI

struct UpdateBalanceSheet: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var accountManager: AccountsManager
    
    var account: Account
    
    @State private var newBalance: Double = 0.0
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent("Enter new balance") {
                    TextField("", value: $newBalance, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                }
            }
            .navigationTitle("Update Balance")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if newBalance > 0 {
                            accountManager.updateBalance(for: account, newBalance: newBalance)
                        }
                        dismiss()
                    }) { Image(systemName: "checkmark")}
                }
            }
        }
        //.keyboardDoneOverlay()
        .onAppear {
            newBalance = account.currentBalance
        }
    }
}
