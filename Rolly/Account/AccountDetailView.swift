//
//  AccountDetailView.swift
//  FinanceApp
//
//  Created by Ryan Berch on 10/17/25.
//

import SwiftUI

enum ActiveSheet: Identifiable {
    case applyPayment(Account)
    case paymentDetail(Payment)
    case setPaymentDue(Account)
    case updateBalance(Account)
    case schedulePayment(Account)

    var id: String {
        switch self {
        case .applyPayment(let account): return "applyPayment-\(account.id)"
        case .paymentDetail(let payment): return "paymentDetail-\(payment.id)"
        case .setPaymentDue(let account): return "setPaymentDue-\(account.id)"
        case .schedulePayment(let account): return
            "schedulePayment-\(account.id)"
        case .updateBalance(let account): return "updateBalance-\(account.id)"
        }
    }
}

struct AccountDetailView: View {
    @EnvironmentObject var accountManager: AccountsManager
    @EnvironmentObject var expenseManager: ExpenseManager
    @EnvironmentObject var paymentManager: PaymentManager

    let account: Account
    
    @State private var activeSheet: ActiveSheet?
    @State private var showingRenameAlert = false
    @State private var newAccountName = ""
    
    
    private var recentTransactions: [Expense] {
        expenseManager.currentExpenses
            .filter { $0.methodID == account.id }
            .sorted { $0.date > $1.date }
    }
    
    private var previousTransactions: [Expense] {
        expenseManager.previousExpenses
            .filter { $0.methodID == account.id }
            .sorted { $0.date > $1.date }
    }
    
    // MARK: - Body
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                headerCard
                
                if account.hasPaymentDue && !hasScheduledPayment(for: account) {
                    paymentDueSection(
                        for: account.paymentDueDate!
                    )
                }
                else if hasScheduledPayment(for: account) {
                    VStack {
                        scheduledPaymentSection(
                            for: paymentManager.payments.first(where: { $0.destID == account.id })!
                        )
                    }
                }

                accountOverviewSection
                
                 if account.type.canBeBillingMethod {
                    recentTransactionsView
                    previousTransactionsView
                }
            }
            .padding(.top)
            .padding(.bottom, 40)
        }
        .navigationTitle(account.name)
        .sheet(item: $activeSheet) { item in
            switch item {
            case .applyPayment(let account):
                ApplyPaymentSheet(account: account)
                    .environmentObject(accountManager)
            case .setPaymentDue(let account):
                SetPaymentDueSheet(account: account)
                    .environmentObject(accountManager)
            case .schedulePayment(let account):
                SchedulePaymentSheet(destAccount: account)
                    .environmentObject(accountManager)
            case .updateBalance(let account):
                UpdateBalanceSheet(account: account)
                    .environmentObject(accountManager)
            case .paymentDetail(let payment):
                PaymentDetailSheet(payment: payment)
                    .environmentObject(paymentManager)
                    .environmentObject(accountManager)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                menuButton
            }
        }
        .alert("Rename Account", isPresented: $showingRenameAlert) {
            TextField("New Account Name", text: $newAccountName)
            Button("Cancel", role: .cancel) { }
            Button("Save") {
                accountManager.renameAccount(account.id, to: newAccountName)
            }
        } message: {
            Text("Enter a new name for this account.")
        }
    }
}

// MARK: - Header Card
private extension AccountDetailView {
    var headerCard: some View {
        ZStack(alignment: .bottomLeading) {
            // Background gradient
            LinearGradient(
                colors: gradientColors(for: account.type),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .frame(height: 220)
            .cornerRadius(24)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 4) { // tighter stack
                // Account type (top label)
                Text(account.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
                    .padding(.top, 15)
                
                Spacer()
                
                // Balance label & amount grouped together
                VStack(alignment: .leading, spacing: 2) {
                    Text("Balance")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white.opacity(0.9))
                    Text(account.currentBalance, format: .currency(code: "USD"))
                        .font(.system(size: 40, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                // Optional: due date, slightly offset below
                if account.hasPaymentDue &&  !hasScheduledPayment(for: account), let due = account.paymentDueDate {
                    Text("Next payment due \(due, format: .dateTime.month(.abbreviated).day())")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
                else if (account.hasPaymentDue && hasScheduledPayment(for: account)) {
                    let payment = paymentManager.payments.first(where: { $0.destID == account.id })!
                    Text("Payment of \(payment.amount, format: .currency(code: "USD")) scheduled for \(payment.date, format: .dateTime.month(.abbreviated).day())")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.top, 4)
                }
            }
            .padding(.leading, 32)
            .padding(.bottom, 15)
        }
    }
    
    
     var recentTransactionsView: some View {
        VStack {
            HStack {
                Text("Recent Transactions")
                    .font(.headline)
                    .padding(.leading, 8)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                if !recentTransactions.isEmpty {
                    ForEach(Array(recentTransactions.enumerated()), id: \.element.id) { index, expense in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                // Transaction name
                                Text(expense.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if (account.type == .checking || account.type == .credit) {
                                    // Transaction amount
                                    Text(expense.amount, format: .currency(code: "USD"))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(expense.amount < 0 ? .red : .primary)
                                }
                                if (account.type == .savings) {
                                    // Transaction amount
                                    Text(expense.amount, format: .currency(code: "USD"))
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(expense.amount > 0 ? .red : .primary)
                                }
                            }
                            
                            // Date below
                            Text(expense.date, format: .dateTime.month(.abbreviated).day().year())
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        
                        // Divider between items (not after last)
                        if index < recentTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                        }
                    }
                } else {
                    HStack {
                        Text("No recent transactions.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
    }
    
    
    var previousTransactionsView: some View {
        VStack {
            HStack {
                Text("Previous Transactions")
                    .font(.headline)
                    .padding(.leading, 8)
                    .bold()
                Spacer()
            }
            .padding(.horizontal)
            
            VStack(spacing: 0) {
                if !previousTransactions.isEmpty {
                    ForEach(Array(previousTransactions.enumerated()), id: \.element.id) { index, expense in
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                // Transaction name
                                Text(expense.name)
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                // Transaction amount
                                Text(expense.amount, format: .currency(code: "USD"))
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(expense.amount < 0 ? .red : .primary)
                            }
                            
                            // Date below
                            Text(expense.date, format: .dateTime.month(.abbreviated).day().year())
                                .font(.system(size: 13))
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        
                        // Divider between items (not after last)
                        if index < previousTransactions.count - 1 {
                            Divider()
                                .padding(.leading, 16)
                                .padding(.trailing, 16)
                        }
                    }
                } else {
                    HStack {
                        Text("No previous transactions.")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemGray6))
            )
            .padding(.horizontal)
        }
    }
    
    func gradientColors(for type: AccountType) -> [Color] {
        switch type {
        case .checking:
            return [Color.blue.opacity(0.9), Color.cyan]
        case .savings:
            return [Color.green.opacity(0.9), Color.teal]
        case .credit:
            return [Color.purple.opacity(0.9), Color.indigo]
        case .loan:
            return [Color.red.opacity(0.9), Color.orange]
        }
    }
}

// MARK: - Helper Rows
private extension AccountDetailView {
    func accountOverviewRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .bold()
        }
        .font(.subheadline)
    }
    
    /// The ellipsis menu in the navigation bar (matches previous appearance)
    var menuButton: some View {
        Menu {
            // Only show Set Payment Due when credit/loan and there's no existing due
            if (account.type == .credit || account.type == .loan) && !account.hasPaymentDue {
                Button("Set Payment Due") {
                    activeSheet = .setPaymentDue(account)
                }
            }
            
            if (account.type == .credit || account.type == .loan) && account.hasPaymentDue && !hasScheduledPayment(for: account) {
                Button("Schedule Payment") {
                    activeSheet = .schedulePayment(account)
                }
            }
            
            Button(applyActionLabel(for: account.type)) {
                activeSheet = .applyPayment(account)
            }
            
            Button("Rename Account") {
                newAccountName = account.name
                showingRenameAlert = true
            }
            
            Button("Update Balance", role: .destructive) {
                activeSheet = .updateBalance(account)
            }
        } label: {
            Image(systemName: "ellipsis.circle")
                .imageScale(.large)
        }
    }

    /// The "Upcoming Payment Due" card that was previously shown under the header
    func paymentDueSection(for dueDate: Date) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Upcoming Payment Due")
                .font(.headline)
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Amount Due")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text("\(account.paymentAmount ?? 0, format: .currency(code: "USD"))")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Due Date")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    Text(dueDate, format: .dateTime.month(.abbreviated).day().year())
                        .font(.title3)
                        .bold()
                        .foregroundColor(.red)
                }
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
        .padding(.horizontal)
            
    }
    
    /// The "Upcoming Payment Due" card that was previously shown under the header
    func scheduledPaymentSection(for payment: Payment) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Scheduled Payment")
                    .font(.headline)
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Payment Amount")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("\(payment.amount, format: .currency(code: "USD"))")
                            .font(.title2)
                            .bold()
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Date Scheduled")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text(payment.date, format: .dateTime.month(.abbreviated).day().year())
                            .font(.title3)
                            .bold()
                    }
                }
            }
            if (account.hasPaymentDue) {
                Divider()
                VStack(alignment: .leading, spacing: 12) {
                    Text("Statement Info")
                        .font(.headline)
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Balance Due")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text("\(account.paymentAmount!, format: .currency(code: "USD"))")
                                .font(.title2)
                                .bold()
                        }
                        Spacer()
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Due Date")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(account.paymentDueDate!, format: .dateTime.month(.abbreviated).day().year())
                                .font(.title3)
                                .bold()
                        }
                    }
                }
                
                
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
        .padding(.horizontal)
        .onLongPressGesture{
            let payment = paymentManager.payments.first(where: { $0.destID == account.id })!
            activeSheet = .paymentDetail(payment)
        }
    }

    /// The account overview card (Account Type, Current Balance, Payment Due if present)
    var accountOverviewSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Account Overview")
                .font(.headline)
            accountOverviewRow(title: "Account Type", value: account.type.rawValue.capitalized)
            accountOverviewRow(title: "Current Balance", value: account.currentBalance.formatted(.currency(code: "USD")))
            if account.hasPaymentDue {
                accountOverviewRow(title: "Payment Due", value: account.paymentAmount?.formatted(.currency(code: "USD")) ?? "-")
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(.systemGray6)))
        .padding(.horizontal)
    }


    func applyActionLabel(for type: AccountType) -> String {
        switch type {
        case .checking, .savings:
            return "Add Contribution"
        case .credit, .loan:
            return "Apply Payment"
        }
    }
    
    func hasScheduledPayment(for account: Account) -> Bool {
        return paymentManager.payments.contains(where: { $0.destID == account.id })
    }
}
