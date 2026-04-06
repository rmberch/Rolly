//
//  RecurringExpense.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import Foundation

enum RecurringType: String, CaseIterable, Codable {
    case bill
    case subscription
    
    var id: String { rawValue }
    
    var displayName: String {
        switch self {
        case .bill: return "Bill"
        case .subscription: return "Subscription"
        }
    }
}


struct RecurringExpense: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var methodID: UUID
    var type: RecurringType
    var nextDueDate: Date
    var frequency: Frequency
    var amountVaries: Bool  // ✅ New field

    // MARK: - Init
    init(name: String, amount: Double, methodID: UUID, type: RecurringType, dueDate: Date, frequency: Frequency, amountVaries: Bool = false) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.methodID = methodID
        self.type = type
        self.nextDueDate = dueDate
        self.frequency = frequency
        self.amountVaries = amountVaries
    }

    // MARK: - Migration-safe Decoding
    enum CodingKeys: String, CodingKey {
        case id, name, amount, methodID, type, nextDueDate, frequency, amountVaries
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        amount = try container.decode(Double.self, forKey: .amount)
        methodID = try container.decode(UUID.self, forKey: .methodID)
        type = try container.decode(RecurringType.self, forKey: .type)
        nextDueDate = try container.decode(Date.self, forKey: .nextDueDate)
        frequency = try container.decode(Frequency.self, forKey: .frequency)
        amountVaries = try container.decodeIfPresent(Bool.self, forKey: .amountVaries) ?? false  // ✅ Defaults old data
    }

    // MARK: - Behavior
    mutating func advanceDueDate() {
        if let next = getNextDate(from: nextDueDate, withFrequency: frequency) {
            nextDueDate = next
        }
    }

    func isDue(between start: Date, and end: Date) -> Bool {
        nextDueDate >= start && nextDueDate < end
    }

    var countsTowardSpendingLimit: Bool {
        type == .subscription
    }
}
