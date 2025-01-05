import SwiftUI
import Combine

struct PlaceSearchView: View {
    @Binding var selectedPlace: Place?
    @State private var searchText = ""
    @State private var places: [Place] = []
    @State private var searchCancellable: AnyCancellable?
    
    let placesService = placesService()
    
    var body: some View {
        VStack(alignment: .leading) {
            TextField("Search destination", text: $searchText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: searchText) { newValue in
                    searchPlaces(query: newValue)
                }
            
            if !places.isEmpty {
                ScrollView {
                    LazyVStack(alignment: .leading) {
                        ForEach(places) { place in
                            Button(action: {
                                selectedPlace = place
                                searchText = ""
                                places = []
                            }) {
                                VStack(alignment: .leading) {
                                    Text(place.name)
                                        .font(.headline)
                                    Text(place.fullName)
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                            Divider()
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
    }
    
    private func searchPlaces(query: String) {
        guard !query.isEmpty else {
            places = []
            return
        }
        
        searchCancellable?.cancel()
        searchCancellable = placesService.searchPlaces(query: query)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { places in
                    self.places = places
                }
            )
    }
} 
