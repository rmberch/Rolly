//
//  Payment.swift
//  Rolly
//
//  Created by Ryan Berch on 3/11/26.
//

import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var sourceID: UUID
    var destID: UUID
    var date: Date
    
    init(amount: Double, sourceID: UUID, destID: UUID, date: Date) {
        self.id = UUID()
        self.amount = amount
        self.sourceID = sourceID
        self.destID = destID
        self.date = date
    }
}
