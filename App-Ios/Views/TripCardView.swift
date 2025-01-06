import SwiftUI

struct TripCardView: View {
    let trip: Trip
    @State private var backgroundImage: String? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Spacer() // Push content to bottom half
            
            // Location info
            VStack(alignment: .leading, spacing: 2) {
                // Split the trip name into main location and country
                let components = trip.name.components(separatedBy: ", ")
                if components.count > 1 {
                    Text(components[0]) // City/State
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                    Text(components[1...].joined(separator: ", ")) // Country
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                } else {
                    Text(trip.name)
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            }
            
            // Dates
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Start")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Text(formattedDate(trip.startDate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("End")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    Text(formattedDate(trip.endDate))
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 8)
        }
        .padding(20)
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            ZStack {
                // Background image
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
                
                // Gradient overlay
                LinearGradient(
                    gradient: Gradient(colors: [
                        .clear,
                        .black.opacity(0.3),
                        .black.opacity(0.7)
                    ]),
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
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
            name: "Florida, United States",
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
