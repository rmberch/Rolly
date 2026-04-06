//
//  EditSpendingLimit.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import SwiftUI

struct SpendingLimitSheet: View {
    @EnvironmentObject var budget: Budget
    @State private var newBudget: Double? = nil
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                LabeledContent {
                    TextField("Required", value: $newBudget, format: .currency(code: "USD"))
                        .multilineTextAlignment(.trailing)
                        .keyboardType(.decimalPad)
                } label: {
                    Text("New Spending Limit").bold()
                }
            }
            .navigationTitle("Spending Limit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: {
                        budget.updateBudget(to: budget.amount)
                        dismiss()
                    }) { Image(systemName: "chevron.backward")}
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        if let value = newBudget, value > 0 {
                            budget.updateBudget(to: value)
                        }
                        dismiss()
                    }) { Image(systemName: "checkmark") }
                    .disabled(newBudget == nil || (newBudget ?? 0) <= 0)
                }
            }
            .onAppear {
                newBudget = budget.amount
            }
        }
        .keyboardDoneOverlay()
    }
}
