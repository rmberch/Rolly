//
//  AccountsView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI



struct AccountsView: View {
    @EnvironmentObject var accountManager: AccountsManager
    @State private var activeSheet: ActiveSheet?

    var body: some View {
        NavigationStack {
            if !accountManager.accounts.isEmpty {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        ForEach(groupedAccounts, id: \.title) { group in
                            VStack(alignment: .leading, spacing: 12) {
                                Text(group.title)
                                    .font(.title2)
                                    .bold()
                                    .padding(.horizontal)
                                
                                ForEach(group.accounts) { account in
                                    NavigationLink(destination: AccountDetailView(account: account)) {
                                        accountCard(for: account)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .navigationTitle("Accounts")
            } else {
                VStack {
                    Text("Add accounts to see balances here.")
                }
                .navigationTitle("Accounts")
            }
        }
    }
}

// MARK: - Helpers
extension AccountsView {
    private var groupedAccounts: [(title: String, accounts: [Account])] {
        [
            ("Checking", accountManager.accounts.filter { $0.type == .checking } .sorted { $0.name < $1.name })
                ,
            ("Credit", accountManager.accounts.filter { $0.type == .credit }.sorted { $0.name < $1.name }),
            ("Savings", accountManager.accounts.filter { $0.type == .savings }.sorted { $0.name < $1.name }),
            ("Loan", accountManager.accounts.filter { $0.type == .loan }.sorted { $0.name < $1.name })
        ].filter { !$0.accounts.isEmpty }
    }

    private func applyActionLabel(for type: AccountType) -> String {
        switch type {
        case .checking, .savings:
            return "Add Contribution"
        case .credit, .loan:
            return "Apply Payment"
        }
    }

    private func accountCard(for account: Account) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(account.name)
                    .font(.headline)
                Spacer()
                
                Image(systemName: "chevron.forward")
                    .foregroundColor(.gray)
            }
            
            Divider()
            HStack {
                Text("Current Balance:")
                    .font(.subheadline)
                Spacer()
                Text(account.currentBalance, format: .currency(code: "USD"))
                    .font(.subheadline)
            }
            
            if account.hasPaymentDue, let dueDate = account.paymentDueDate {
                HStack {
                    Text("Payment Due:")
                        .font(.subheadline)
                        .foregroundColor(.red)
                    Spacer()
                    Text("\(account.paymentAmount ?? 0, format: .currency(code: "USD"))")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
                HStack {
                    Text("Due Date:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(dueDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            } else if account.type == .credit || account.type == .loan {
                Text("No payment due.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemGray6))
        )
        .padding(.horizontal)
    }
}
