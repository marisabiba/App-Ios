import SwiftUI

struct TripCardView: View {
    let trip: Trip

    var body: some View {
        VStack(alignment: .leading) {
            Text(trip.name)
                .font(.headline)
            Text("Start: \(formattedDate(trip.startDate))")
            Text("End: \(formattedDate(trip.endDate))")
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding(.horizontal)
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        TripCardView(trip: Trip(name: "Beach Vacation", startDate: Date(), endDate: Date()))
    }
}
