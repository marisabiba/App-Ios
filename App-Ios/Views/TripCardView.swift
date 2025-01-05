import SwiftUI

struct TripCardView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Destination Image
            if let imageUrlString = trip.destinationImageUrl,
               let imageUrl = URL(string: imageUrlString) {
                AsyncImage(url: imageUrl) { phase in
                    switch phase {
                    case .empty:
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 150)
                            .clipped()
                    case .failure(_):
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 150)
                            .overlay(
                                Image(systemName: "photo.fill")
                                    .foregroundColor(.gray)
                            )
                    @unknown default:
                        EmptyView()
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 150)
                    .overlay(
                        Image(systemName: "photo.fill")
                            .foregroundColor(.gray)
                    )
            }
            
            VStack(alignment: .leading, spacing: 8) {
                // Trip Name and Destination
                VStack(alignment: .leading, spacing: 4) {
                    Text(trip.name)
                        .font(.headline)
                    
                    if let destination = trip.destination {
                        Text(destination.name)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                // Dates
                HStack {
                    VStack(alignment: .leading) {
                        Text("Start:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formattedDate(trip.startDate))
                            .font(.subheadline)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("End:")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(formattedDate(trip.endDate))
                            .font(.subheadline)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 12)
            }
        }
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// Preview
struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrip = Trip(
            name: "Sample Trip",
            destination: Place(
                id: "123",
                name: "Paris",
                fullName: "Paris, France",
                photoReference: nil
            ),
            destinationImageUrl: "https://images.unsplash.com/photo-1502602898657-3e91760cbb34",
            startDate: Date(),
            endDate: Date().addingTimeInterval(86400 * 3),
            days: [
                TripDay(
                    date: Date(),
                    title: "Day 1",
                    activities: [],
                    transportationDetails: TransportationDetails(mode: "", time: Date()),
                    budgetDetails: BudgetDetails(amount: 0),
                    checklist: []
                )
            ]
        )
        
        VStack {
            // Preview with image
            TripCardView(trip: sampleTrip)
            
            // Preview without image
            TripCardView(trip: Trip(
                name: "Trip without image",
                destination: Place(
                    id: "456",
                    name: "London",
                    fullName: "London, UK",
                    photoReference: nil
                ),
                startDate: Date(),
                endDate: Date().addingTimeInterval(86400 * 3),
                days: []
            ))
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
