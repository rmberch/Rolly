//
//  Frequency.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import Foundation

enum Frequency: String, Codable, CaseIterable, Identifiable {
    case daily
    case weekly
    case biWeekly
    case semiMonthly
    case monthly
    case quarterly
    case semiAnnually
    case yearly
    
    var id: String { rawValue }
    
    var description: String {
        switch self {
        case .daily: return "Daily"
        case .weekly: return "Weekly"
        case .biWeekly: return "Bi-Weekly"
        case .semiMonthly: return "Semi-Monthly"
        case .monthly: return "Monthly"
        case .quarterly: return "Quarterly"
        case .semiAnnually: return "Semi-Annually"
        case .yearly: return "Yearly"
        }
    }
    
    static let recurringExpenseOptions: [Frequency] = Frequency.allCases
}

func getNextDate(from date: Date, withFrequency frequency: Frequency) -> Date? {
    switch frequency {
    case .daily: return Calendar.current.date(byAdding: .day, value: 1, to: date)
    case .weekly: return Calendar.current.date(byAdding: .weekOfYear, value: 1, to: date)
    case .biWeekly: return Calendar.current.date(byAdding: .weekOfYear, value: 2, to: date)
    case .semiMonthly: return Calendar.current.date(byAdding: .day, value: 15, to: date)
    case .monthly: return Calendar.current.date(byAdding: .month, value: 1, to: date)
    case .quarterly: return Calendar.current.date(byAdding: .month, value: 3, to: date)
    case .semiAnnually: return Calendar.current.date(byAdding: .month, value: 6, to: date)
    case .yearly: return Calendar.current.date(byAdding: .year, value: 1, to: date)
    }
}
