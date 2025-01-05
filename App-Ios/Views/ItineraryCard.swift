import SwiftUI

struct ItineraryCard: View {
    var day: TripDay
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text("Date: \(day.date, formatter: dateFormatter)")
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(day.activities) { activity in
                Text(activity.title)
            }
            
            Text(day.transportationDetails.mode)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
        .onTapGesture {
            onTap()
        }
    }
}

let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    return formatter
}()


struct ItineraryCard_Previews: PreviewProvider {
    static var previews: some View {
        let mockDay = TripDay(
            date: Date(),
            title: "Day 1",
            activities: [Activity(time: Date(), title: "Visit Museum", location: "City Center", notes: "")],
            transportationDetails: TransportationDetails(mode: "Bus", time: Date()),
            budgetDetails: BudgetDetails(amount: 100),
            checklist: []
        )
        
        return ItineraryCard(day: mockDay) {
            print("Card tapped!")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
