//
//  Expense.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import Foundation

struct Expense: Identifiable, Codable {
    let id: UUID
    var name: String
    var amount: Double
    var methodID: UUID
    var date: Date
    var isTracked: Bool
    
    init(name: String, amount: Double, methodID: UUID, date: Date, tracked: Bool) {
        self.id = UUID()
        self.name = name
        self.amount = amount
        self.methodID = methodID
        self.date = date
        self.isTracked = tracked
    }

}
