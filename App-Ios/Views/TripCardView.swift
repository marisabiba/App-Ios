import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trip.name)
                .font(.headline)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(formattedDate(trip.startDate))
                        .font(.subheadline)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("End:")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    Text(formattedDate(trip.endDate))
                        .font(.subheadline)
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrip = Trip(name: "Sample Trip", 
                            startDate: Date(), 
                            endDate: Date().addingTimeInterval(86400 * 3))
        
        TripCardView(trip: sampleTrip)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
