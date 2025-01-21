import SwiftUI

struct BudgetView: View {
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    let dayIndex: Int
    @State private var showingAddExpense = false
    
    var budget: BudgetDetails {
        trip.days[dayIndex].budgetDetails
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Budget Overview Card
            VStack(spacing: 12) {
                HStack {
                    Text("Total Budget")
                        .font(.headline)
                    Spacer()
                    AnimatedNumberView(
                        value: budget.totalBudget,
                        currency: budget.currency
                    )
                }
                
                Divider()
                
                HStack {
                    Text("Spent")
                        .font(.subheadline)
                    Spacer()
                    let spentAmount = budget.expenses.reduce(0) { $0 + $1.amount }
                    AnimatedNumberView(
                        value: spentAmount,
                        currency: budget.currency
                    )
                }
                
                HStack {
                    Text("Remaining")
                        .font(.subheadline)
                    Spacer()
                    let remainingAmount = budget.totalBudget - budget.expenses.reduce(0) { $0 + $1.amount }
                    AnimatedNumberView(
                        value: remainingAmount,
                        currency: budget.currency
                    )
                }
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(radius: 2)
            
            // Expenses List
            List {
                ForEach(budget.expenses) { expense in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(expense.note)
                                .font(.headline)
                            Text(expense.category.rawValue)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack(alignment: .trailing) {
                            AnimatedNumberView(
                                value: expense.amount,
                                currency: expense.currency
                            )
                            
                            if expense.currency != trip.localCurrency {
                                let convertedAmount = viewModel.getConvertedAmount(
                                    amount: expense.amount,
                                    from: expense.currency,
                                    to: trip.localCurrency
                                )
                                AnimatedNumberView(
                                    value: convertedAmount,
                                    currency: trip.localCurrency
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .onDelete { indexSet in
                    var updatedBudget = budget
                    updatedBudget.expenses.remove(atOffsets: indexSet)
                    viewModel.updateBudget(
                        tripId: trip.id,
                        dayIndex: dayIndex,
                        budget: updatedBudget
                    )
                }
            }
            
            // Add Expense Button
            Button(action: { showingAddExpense = true }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add Expense")
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .sheet(isPresented: $showingAddExpense) {
            AddExpenseView(
                viewModel: viewModel,
                trip: trip,
                dayIndex: dayIndex,
                budget: budget
            ) { newBudget in
                viewModel.updateBudget(
                    tripId: trip.id,
                    dayIndex: dayIndex,
                    budget: newBudget
                )
            }
        }
    }
}

struct ExpenseRow: View {
    let expense: BudgetExpense
    let localCurrency: String
    let viewModel: TripViewModel
    
    var body: some View {
        HStack {
            Image(systemName: expense.category.icon)
                .foregroundColor(expense.category.color)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading) {
                Text(expense.category.rawValue)
                if !expense.note.isEmpty {
                    Text(expense.note)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing) {
                Text("\(expense.currency) \(String(format: "%.2f", expense.amount))")
                    .bold()
                
                if expense.currency != localCurrency {
                    let convertedAmount = viewModel.getConvertedAmount(
                        amount: expense.amount,
                        from: expense.currency,
                        to: localCurrency
                    )
                    Text("≈ \(localCurrency) \(String(format: "%.2f", convertedAmount))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
} 