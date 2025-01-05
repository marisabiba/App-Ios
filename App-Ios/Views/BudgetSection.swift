import SwiftUI

struct BudgetSection: View {
    let budget: BudgetDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Budget")
                .font(.headline)
            
            Text(String(format: "%.2f", budget.amount))
                .font(.body)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
} 