//
//  Account.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import Foundation

enum AccountType: String, Codable, CaseIterable, Identifiable {
    case checking
    case savings
    case credit
    case loan
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .checking: return "Checking"
        case .savings: return "Savings"
        case .credit: return "Credit Card"
        case .loan: return "Loan"
        }
    }
    
    var canBePaymentMethod: Bool {
        switch self {
        case .checking, .credit:
            return true
        default:
            return false
        }
    }
    
    var canBeBillingMethod: Bool {
        switch self {
        case .checking, .credit, .savings:
            return true
        default:
            return false
        }
    }
    
    
    var canBePaymentSource: Bool {
        switch self {
        case .savings, .checking:
            return true
        default:
            return false
        }
    }
    
    var tracksPaymentDue: Bool {
        switch self {
        case .credit, .loan:
            return true
        default:
            return false
        }
    }
    
    var increasesWithExpenses: Bool {
        switch self {
        case .credit:
            return true
        default:
            return false
        }
    }
}

struct Account: Identifiable, Codable, Equatable {
    var id = UUID()
    var name: String
    var type: AccountType   // 🆕 New property
    var currentBalance: Double
    var initialBalance: Double?

    // Only used for Credit or Loan accounts
    var hasPaymentDue: Bool = false
    var paymentDueDate: Date? = nil
    var paymentAmount: Double? = nil
}
