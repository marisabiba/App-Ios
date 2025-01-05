import SwiftUI

struct TransportationSection: View {
    let transportation: TransportationDetails
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transportation")
                .font(.headline)
            
            HStack {
                Text(transportation.mode)
                Spacer()
                Text(transportation.time, style: .time)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
    }
} 