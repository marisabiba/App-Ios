import SwiftUI

struct AnimatedNumberView: View {
    let value: Double
    let currency: String
    let duration: Double
    
    @State private var displayedValue: Double
    
    init(value: Double, currency: String, duration: Double = 0.5) {
        self.value = value
        self.currency = currency
        self.duration = duration
        self._displayedValue = State(initialValue: value)
    }
    
    var body: some View {
        Text("\(CurrencyService.getCurrencySymbol(for: currency))\(String(format: "%.2f", displayedValue))")
            .fontWeight(.bold)
            .foregroundColor(displayedValue >= 0 ? .green : .red)
            .onChange(of: value) { newValue in
                withAnimation(.spring(response: duration)) {
                    displayedValue = newValue
                }
            }
    }
} 