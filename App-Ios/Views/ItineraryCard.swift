import SwiftUI

struct ItineraryCard: View {
    var day: Day
    var onTap: () -> Void

    var body: some View {
        VStack {
            Text("Date: \(day.date, formatter: dateFormatter)")
                .font(.headline)
                .padding(.bottom, 5)
            
            ForEach(day.activities) { activity in
                Text(activity.name)
            }
            
            ForEach(day.accommodations) { accommodation in
                Text(accommodation.name)
            }
            
            ForEach(day.transportation) { transport in
                Text(transport.type)
            }
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
        let mockDay = Day(
            date: Date(),
            activities: [Activity(name: "Visit Museum")],
            accommodations: [Accommodation(name: "Hotel ABC")],
            transportation: [Transportation(type: "Bus")]
        )
        
        return ItineraryCard(day: mockDay) {
            print("Card tapped!")
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
