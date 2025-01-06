import SwiftUI

struct AddTripView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: TripViewModel
    
    @State private var tripName = ""
    @State private var startDate = Date()
    @State private var endDate = Date()
    @State private var showTripDetails = false
    @State private var newTrip: Trip?
    @State private var suggestions: [String] = []
    @State private var showSuggestions = false
    
    var body: some View {
        NavigationView {
            Form {
                Section() {
                    TextField("Destination", text: $tripName)
                        .onChange(of: tripName) { newValue in
                            if !newValue.isEmpty {
                                fetchSuggestions(for: newValue)
                            } else {
                                suggestions = []
                            }
                        }
                    
                    // Show suggestions if available
                    if !suggestions.isEmpty && showSuggestions {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                tripName = suggestion
                                showSuggestions = false
                            }) {
                                Text(suggestion)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    
                    DatePicker("Start Date", selection: $startDate, displayedComponents: .date)
                    DatePicker("End Date", selection: $endDate, displayedComponents: .date)
                }
            }
            .navigationTitle("New Trip")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        createTrip()
                        dismiss()
                    }
                    .disabled(tripName.isEmpty || endDate < startDate)
                    .bold()
                }
            }
        }
    }
    
    private func fetchSuggestions(for query: String) {
        let apiKey = "450a074ba9c54c5f8251ba798cd8823f"
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.opencagedata.com/geocode/v1/json?q=\(encodedQuery)&key=\(apiKey)&limit=10&language=en&no_annotations=1"
        
        guard let url = URL(string: urlString) else { return }
        
        // Add a small delay to prevent too many API calls while typing
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            guard tripName == query else { return }
            
            URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data,
                      let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                      let results = json["results"] as? [[String: Any]] else {
                    return
                }
                
                // Extract formatted locations from results
                let locations = results.compactMap { result -> String? in
                    guard let components = result["components"] as? [String: Any] else { return nil }
                    
                    // Only show city and state suggestions
                    if let city = components["city"] as? String,
                       let state = components["state"] as? String,
                       let country = components["country"] as? String {
                        return "\(city), \(state), \(country)"
                    } else if let city = components["city"] as? String,
                              let country = components["country"] as? String {
                        return "\(city), \(country)"
                    } else if let state = components["state"] as? String,
                              let country = components["country"] as? String {
                        return "\(state), \(country)"
                    }
                    return nil
                }
                
                // Update suggestions on main thread
                DispatchQueue.main.async {
                    suggestions = Array(Set(locations)) // Remove duplicates
                    showSuggestions = !suggestions.isEmpty
                }
            }.resume()
        }
    }
    
    private func createTrip() {
        let trip = Trip(
            name: tripName,
            startDate: startDate,
            endDate: endDate,
            days: [] // Empty array of days initially
        )
        viewModel.addTrip(trip)
        newTrip = trip
    }
}

struct AddTripView_Previews: PreviewProvider {
    static var previews: some View {
        AddTripView(viewModel: TripViewModel())
    }
}
