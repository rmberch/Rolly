//
//  PaymentDetailSheet.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import SwiftUI

struct PaymentDetailSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var paymentManager: PaymentManager
    
    @State var payment: Payment
    @State private var showingDeleteConfirmation = false
    @State private var showError: Bool = false
    
    
    
    var body: some View {
        let destAccount = accountManager.accounts.first(where: { $0.id == payment.destID })!
        NavigationView {
            Form {
                Section("\(destAccount.name) Details") {
                    HStack {
                        Text("Current Balance:")
                        Spacer()
                        Text("\(destAccount.currentBalance, format: .currency(code: "USD"))")
                            .foregroundColor(.secondary)
                    }
                    if let dueDate = destAccount.paymentDueDate {
                        LabeledContent {
                            Text("\(destAccount.paymentAmount ?? 0, specifier: "$%.2f")")
                        } label: {
                            Text("Payment Due on \(dueDate.formatted(date: .abbreviated, time: .omitted)):")
                        }
                    }
                }
                
                let sourceAccount = accountManager.accounts.first(where: { $0.id == payment.sourceID })!
                Section("\(sourceAccount.name) Details") {
                    HStack {
                        Text("Current Balance:")
                        Spacer()
                        Text("\(sourceAccount.currentBalance, format: .currency(code: "USD"))")
                            .foregroundColor(.secondary)
                    }
                }
                
                Section("Payment Details") {
                    Picker("Source", selection: $payment.sourceID) {
                        Text("Select Method").tag(nil as UUID?)
                        ForEach(accountManager.accounts.filter {$0.type.canBePaymentSource}.sorted {$0.name < $1.name}) { account in
                            Text(account.name).tag(account.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        LabeledContent {
                            TextField("", value: $payment.amount, format: .currency(code: "USD"))
                                .multilineTextAlignment(.trailing)
                                .keyboardType(.decimalPad)
                        } label: {
                            Text("Payment Amount")
                        }
                        
                        if showError {
                            Text("Amount cannot exceed source or destination balances.")
                                .font(.caption)
                                .foregroundColor(.red)
                                .transition(.opacity)
                        }
                        
                    }
                    
                    DatePicker("Date", selection: $payment.date, displayedComponents: [.date])
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
            .navigationTitle("Payment Details")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        paymentManager.updatePayment(payment)
                        dismiss()
                    }) { Image(systemName: "checkmark") }
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
                }
            }
        }
    }
}
