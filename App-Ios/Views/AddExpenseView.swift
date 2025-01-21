import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripViewModel
    let trip: Trip
    let dayIndex: Int
    let budget: BudgetDetails
    let onUpdate: (BudgetDetails) -> Void
    
    @State private var selectedCategory: BudgetCategory = .food
    @State private var note = ""
    @State private var selectedCurrency: String
    @State private var amount = ""
    @FocusState private var isAmountFocused: Bool
        
    let commonCurrencies = ["USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY", "INR", "RON", "HUF", "MKD", "ALL"]
    
    init(viewModel: TripViewModel, trip: Trip, dayIndex: Int, budget: BudgetDetails, onUpdate: @escaping (BudgetDetails) -> Void) {
        self.viewModel = viewModel
        self.trip = trip
        self.dayIndex = dayIndex
        self.budget = budget
        self.onUpdate = onUpdate
        _selectedCurrency = State(initialValue: trip.localCurrency)
    }
    
    var body: some View {
        NavigationView {
            Form {
                           Section(header: Text("Expense Details")) {
                               Picker("Category", selection: $selectedCategory) {
                                   ForEach(BudgetCategory.allCases, id: \.self) { category in
                                       Label(
                                           title: { Text(category.rawValue) },
                                           icon: { Image(systemName: category.icon) }
                                       )
                                       .foregroundColor(category.color)
                                       .tag(category)
                                   }
                               }
                               .pickerStyle(.menu)
                               
                               Picker("Currency", selection: $selectedCurrency) {
                                   ForEach(commonCurrencies, id: \.self) { currency in
                                       Text(currency).tag(currency)
                                   }
                               }
                               
                               HStack {
                                   Text(selectedCurrency)
                                   TextField("Amount", text: $amount)
                                       .keyboardType(.decimalPad)
                                       .focused($isAmountFocused)
                               }
                               
                               TextField("Note", text: $note)
                                   .textFieldStyle(.roundedBorder)
                           }
                       }
            .navigationTitle("Add Expense")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let amountValue = Double(amount), amountValue > 0 {
                            var updatedBudget = budget
                            let newExpense = BudgetExpense(
                                id: UUID(),
                                amount: amountValue,
                                currency: selectedCurrency,
                                category: selectedCategory,
                                note: note,
                                convertedAmount: nil,
                                date: Date()
                            )
                            if selectedCurrency != trip.localCurrency {
                                                            Task {
                                                                await viewModel.updateExpenseWithConversion(newExpense, tripId: trip.id, dayIndex: dayIndex)
                                                            }
                                                        } else {
                                                            // If it's the same currency, just add it directly
                                                            updatedBudget.expenses.append(newExpense)
                                                            onUpdate(updatedBudget)
                                                        }
                            dismiss()
                        }
                    }
                    .disabled(Double(amount) == nil || amount.isEmpty)
                }
            }
        }
    }
}
