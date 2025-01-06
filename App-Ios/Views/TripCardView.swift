import SwiftUI

struct TripCardView: View {
    let trip: Trip
    @State private var backgroundImage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(trip.name)
                .font(.headline)
                .foregroundColor(.white)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Start:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(formattedDate(trip.startDate))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading) {
                    Text("End:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    Text(formattedDate(trip.endDate))
                        .font(.subheadline)
                        .foregroundColor(.white)
                }
            }
        }
        .padding()
        .frame(height: 150)
        .frame(maxWidth: .infinity)
        .background(
            Group {
                if let imageUrl = backgroundImage {
                    AsyncImage(url: URL(string: imageUrl)) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                    } placeholder: {
                        Color.gray
                    }
                } else {
                    Color.gray
                }
            }
        )
        .clipped()
        .overlay(
            Color.black.opacity(0.3) // Adds a dark overlay for better text visibility
        )
        .cornerRadius(10)
        .shadow(radius: 2)
        .onAppear {
            loadBackgroundImage()
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
    
    private func loadBackgroundImage() {
        let accessKey = "IxrxeyyCotLys276nw2YpQBc0OxuK-evJlmctzuf7Nw"
        let query = trip.name.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.unsplash.com/search/photos?query=\(query)&client_id=\(accessKey)"
        
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                  let results = json["results"] as? [[String: Any]],
                  let firstResult = results.first,
                  let urls = firstResult["urls"] as? [String: Any],
                  let regularUrl = urls["regular"] as? String else {
                return
            }
            
            DispatchQueue.main.async {
                self.backgroundImage = regularUrl
            }
        }.resume()
    }
}

struct TripCardView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleTrip = Trip(
            name: "Barcelona", 
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
        
        TripCardView(trip: sampleTrip)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
