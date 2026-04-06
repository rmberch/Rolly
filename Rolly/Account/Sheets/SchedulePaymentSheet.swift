//
//  SchedulePaymentSheet.swift
//  Rolly
//
//  Created by Ryan Berch on 2/28/26.
//

import SwiftUI

struct SchedulePaymentSheet: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var paymentManager: PaymentManager
    
    var destAccount: Account
    
    @State private var date = Date()
    @State private var amount: Double = 0.0
    @State private var source: UUID?
    @State private var showError: Bool = false
    
    private var selectedSource: Account? {
        guard let id = source else { return nil }
        return accountManager.account(for: id)
    }
    
    private var isValidPayment: Bool {
        guard let sourceAcct = selectedSource else { return false }
        
        guard amount >= 0 else { return false }
        
        return (amount <= sourceAcct.currentBalance || amount <= destAccount.currentBalance)
    }
    
    var body: some View {
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
                
                if (source != nil) {
                    let sourceAccount = accountManager.accounts.first(where: { $0.id == source! })!
                    Section("\(sourceAccount.name) Details") {
                        HStack {
                            Text("Current Balance:")
                            Spacer()
                            Text("\(sourceAccount.currentBalance, format: .currency(code: "USD"))")
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                Section("Payment Details") {
                    Picker("Source", selection: $source) {
                        Text("Select Method").tag(nil as UUID?)
                        ForEach(accountManager.accounts.filter {$0.type.canBePaymentSource}.sorted {$0.name < $1.name}) { account in
                            Text(account.name).tag(account.id as UUID?)
                        }
                    }
                    .pickerStyle(.menu)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        LabeledContent {
                            TextField("", value: $amount, format: .currency(code: "USD"))
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
                    
                    DatePicker("Date", selection: $date, displayedComponents: [.date])
                }
            }
            .navigationTitle("Schedule Payment")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(action: {
                        guard let source = selectedSource else { return }
                        
                        
                        if !isValidPayment {
                            showError = true
                            return
                        }

                        let newPayment = Payment(
                                amount: amount,
                                sourceID: source.id,
                                destID: destAccount.id,
                                date: Calendar.current.startOfDay(for: date)
                            )
                            paymentManager.addPayment(newPayment)
                            dismiss()
                    }) { Image(systemName: "checkmark") }
                        .disabled(source == nil || Calendar.current.startOfDay(for: date) > destAccount.paymentDueDate!)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button(action: { dismiss() }) { Image(systemName: "chevron.backward") }
                }
            }
        }
        .onAppear {
            amount = destAccount.paymentAmount!
        }
        .keyboardDoneOverlay()
    }
}
