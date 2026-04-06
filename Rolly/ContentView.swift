//
//  ContentView.swift
//  Rolly
//
//  Created by Ryan Berch on 2/19/26.
//

import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            AccountsView()
                .tabItem {
                    Label("Accounts", systemImage: "creditcard.fill")
                }
                .tag(1)
            ExpenseView()
                .tabItem {
                    Label("Expenses", systemImage: "list.bullet")
                }
                .tag(2)
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
            }
                .tag(3)
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(Budget())
        .environmentObject(AccountsManager())
        .environmentObject(ExpenseManager())
}
