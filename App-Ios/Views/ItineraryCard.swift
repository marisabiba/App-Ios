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
                HStack {
                    Image(systemName: activity.category.icon)
                        .foregroundColor(.white)
                        .frame(width: 30, height: 30)
                        .background(activity.category.color)
                        .clipShape(Circle())
                    
                    Text(activity.title)
                        .padding(.leading, 8)
                }
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
        let sampleActivity = Activity(
            time: Date(),
            title: "Visit Museum",
            location: "City Center",
            notes: "Buy tickets online",
            category: .sightseeing
        )
        
        let sampleDay = TripDay(
            date: Date(),
            title: "Day 1",
            activities: [sampleActivity],
            transportationDetails: TransportationDetails(mode: "Bus", time: Date()),
            budgetDetails: BudgetDetails(totalBudget: 100, expenses: [], currency: "EUR"),
            checklist: []
        )
        
        return ItineraryCard(day: sampleDay) {
            print("Card tapped")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
