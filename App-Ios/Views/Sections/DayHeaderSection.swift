import SwiftUI

struct DayHeaderSection: View {
    let date: Date
    @Binding var dayTitle: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(date.formatted(date: .long, time: .omitted))
                .font(.headline)
            TextField("Day Title", text: $dayTitle)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
} 