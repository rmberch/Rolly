//
//  AccountSettingsView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI

public struct AccountSettingsView: View {
    @EnvironmentObject var accountManager: AccountsManager
    
    @State private var showingAddMethod = false
    @State private var selectedAccount: Account? = nil
    @State private var showingDeleteAlert = false
    
    private struct GroupSection: Identifiable {
        let id = UUID()
        let title: String
        let accounts: [Account]
    }

    private var groupedAccounts: [GroupSection] {
        Dictionary(grouping: accountManager.accounts, by: { $0.type })
            .map { (type, accounts) in
                GroupSection(
                    title: type.displayName,
                    accounts: accounts.sorted { $0.name < $1.name }
                )
            }
            .sorted { $0.title < $1.title }
    }

    public var body: some View {
        NavigationStack {
            List {
                ForEach(groupedAccounts) { group in
                    Section(header: Text(group.title)) {
                        ForEach(group.accounts) { account in
                            HStack {
                                Text(account.name)
                                Spacer()
                            }
                            .contentShape(Rectangle())
                            .onLongPressGesture {
                                selectedAccount = account
                                showingDeleteAlert = true
                            }
                        }
                    }
                }

                if !accountManager.accounts.isEmpty {
                    primaryAccountPicker
                }

                Button {
                    showingAddMethod = true
                } label: {
                    HStack {
                        Spacer()
                        Text("Add Account")
                            .foregroundColor(.blue)
                        Spacer()
                    }
                }
            }
            .navigationTitle("Accounts")
        }
        .sheet(isPresented: $showingAddMethod) {
            AddAccountView()
                .environmentObject(accountManager)
        }
        .alert("Delete Account?",
               isPresented: $showingDeleteAlert,
               presenting: selectedAccount) { account in
            Button("Delete", role: .destructive) {
                withAnimation {
                    accountManager.removeAccount(by: account.id)
                }
            }
            Button("Cancel", role: .cancel) { }
        } message: { account in
            Text("Are you sure you want to delete \(account.name)?")
        }
    }

    // MARK: - Picker

    var primaryAccountPicker: some View {
        Section {
            Picker("Primary Account", selection: $accountManager.primaryAccount) {
                Text("Select Account").tag(nil as UUID?)
                
                ForEach(
                    accountManager.accounts
                        .filter { $0.type.canBePaymentSource }
                        .sorted { $0.name < $1.name }
                ) { account in
                    Text(account.name).tag(account.id as UUID?)
                }
            }
            .pickerStyle(.menu)
            //.onChange(of: accountManager.primaryAccount) { oldValue, newValue in
            // accountManager.setPrimaryAccount(id: newValue)
            //}
        }
    }
}
