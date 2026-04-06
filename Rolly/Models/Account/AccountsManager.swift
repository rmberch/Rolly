//
//  PaymentMethods.swift
//  FinanceApp
//
//  Created by Ryan Berch on 8/21/25.
//

import Foundation
import Combine

class AccountsManager: ObservableObject {
    private var isInitializing = true
    
    @Published var accounts: [Account] = [] {
        didSet {
            if !isInitializing {
                save()
            }
        }
    }

    @Published var primaryAccount: UUID? = nil {
        didSet {
            if !isInitializing {
                save()
            }
        }
    }
    
    private let accountsStorageKey = "accounts"
    private let primaryAccountIDKey = "primaryAccountID"
    
    init() {
        if let data = UserDefaults.standard.data(forKey: accountsStorageKey),
           let decodedAccounts = try? JSONDecoder().decode([Account].self, from: data) {
            self.accounts = decodedAccounts
        }

        if let stored = UserDefaults.standard.string(forKey: primaryAccountIDKey),
           let uuid = UUID(uuidString: stored) {
            self.primaryAccount = uuid
        }

        isInitializing = false
    }
    
    func addAccount(_ account: Account) {
        if primaryAccount == nil {
            self.primaryAccount = account.id
        }
        accounts.append(account)
        save()
    }
    
    func updateAccount(_ account: Account) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index] = account
        }
        save()
    }
    
    func removeAccount(by id: UUID) {
        accounts.removeAll { $0.id == id }
        
        if primaryAccount == id {
            primaryAccount = nil
        }

        save()
    }
    
    private func save() {
        if let encodedAccounts = try? JSONEncoder().encode(accounts) {
            UserDefaults.standard.set(encodedAccounts, forKey: accountsStorageKey)
        }
        
        if let id = primaryAccount {
            UserDefaults.standard.set(id.uuidString, forKey: primaryAccountIDKey)
        } else {
            UserDefaults.standard.removeObject(forKey: primaryAccountIDKey)
        }

    }
    
    func setPrimaryAccount(id: UUID?) {
        self.primaryAccount = id
    }
    
    func applyExpense(amount: Double, to accountID: UUID) {
        if let index = accounts.firstIndex(where: { $0.id == accountID }) {
            var account = accounts[index]
            
            if account.type.increasesWithExpenses {
                account.currentBalance += amount
            } else {
                account.currentBalance -= amount
            }
            
            accounts[index] = account
            save()
        }
    }

    func applyPayment(amount: Double, to accountID: UUID) {
        if let index = accounts.firstIndex(where: { $0.id == accountID }) {
            var account = accounts[index]
            
            switch account.type {
            case .credit, .loan:
                account.currentBalance -= amount
                if (account.currentBalance < 0.01) {
                    account.currentBalance = 0.0
                }
            case .checking, .savings:
                account.currentBalance += amount
            }
            
            // Handle due payment logic (credit/loan only)
            if account.hasPaymentDue {
                let newDue = max((account.paymentAmount ?? 0) - amount, 0)
                if newDue == 0 {
                    account.paymentDueDate = nil
                    account.hasPaymentDue = false
                }
                account.paymentAmount = newDue
            }
            
            accounts[index] = account
            save()
        }
    }
    
    func setPaymentDue(for account: Account, amount: Double, dueDate: Date) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index].paymentAmount = amount
            accounts[index].paymentDueDate = dueDate
            accounts[index].hasPaymentDue = true
        }
    }
    
    func updateBalance(for account: Account, newBalance: Double) {
        if let index = accounts.firstIndex(where: { $0.id == account.id }) {
            accounts[index].currentBalance = newBalance
        }
    }
    
    func renameAccount(_ id: UUID, to newName: String) {
        if let index = accounts.firstIndex(where: { $0.id == id }) {
            accounts[index].name = newName
            save()
        }
    }
    
    func account(for id: UUID) -> Account? {
        accounts.first(where: { $0.id == id })
    }
    
    func accountType(for id: UUID) -> AccountType? {
        accounts.first(where: { $0.id == id })?.type
    }
}

