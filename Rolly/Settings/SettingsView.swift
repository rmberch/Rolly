//
//  SettingsView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI

struct SettingsView: View {
    //@ObservedObject private var budget = Budget()
    @ObservedObject private var paymentMethods = AccountsManager()
    //@ObservedObject private var payday = PaydayManager()
    
    
    var body: some View {
        NavigationStack {
            VStack {
                List {
                    NavigationLink(destination: AccountSettingsView()) {
                        Text("Accounts")
                    }
                    /*
                    NavigationLink(destination: AccountGoalSettings()) {
                        Text("Goals")
                    }
                    
                    
                    NavigationLink(destination: PaydaySettingsView()) {
                        Text("Payday")
                    }
                     */
                    NavigationLink(destination: RecurringExpensesView()) {
                        Text("Recurring Expenses")
                    }
                }
            }
            .navigationTitle(Text("Settings"))
        }
    }
}
