import SwiftUI

struct BudgetSection: View {
    let budget: BudgetDetails
    var onUpdate: (BudgetDetails) -> Void
    
    @State private var amount: Double
    
    init(budget: BudgetDetails, onUpdate: @escaping (BudgetDetails) -> Void) {
        self.budget = budget
        self.onUpdate = onUpdate
        _amount = State(initialValue: budget.amount)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Budget")
                .font(.headline)
            
            HStack {
                Text("$")
                TextField("Amount", value: $amount, formatter: NumberFormatter())
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .keyboardType(.decimalPad)
                    .onChange(of: amount) { newValue in
                        onUpdate(BudgetDetails(amount: newValue))
                    }
            }
        }
        .padding()
    }
} 