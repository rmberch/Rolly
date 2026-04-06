//
//  Budget.swift
//  Rolly
//
//  Created by Ryan Berch on 2/21/26.
//

import Foundation
import Combine

class Budget: ObservableObject {
    // The main budget value
    @Published var amount: Double {
        didSet {
            saveBudget()
        }
    }
    
    private let storageKey = "UserBudgetAmount"

    init() {
        // Check if a value exists in UserDefaults, otherwise use hard-coded default
        if UserDefaults.standard.object(forKey: storageKey) != nil {
            self.amount = UserDefaults.standard.double(forKey: storageKey)
        } else {
            self.amount = 300.0 // <-- Your hard-coded default
        }
    }

    func updateBudget(to newAmount: Double) {
        amount = newAmount
        saveBudget()
    }

    private func saveBudget() {
        UserDefaults.standard.set(amount, forKey: storageKey)
    }
    
}
