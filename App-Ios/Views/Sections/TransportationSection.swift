import SwiftUI

struct TransportationSection: View {
    let transportation: TransportationDetails
    var onUpdate: (TransportationDetails) -> Void
    
    @State private var mode: String
    @State private var time: Date
    
    init(transportation: TransportationDetails, onUpdate: @escaping (TransportationDetails) -> Void) {
        self.transportation = transportation
        self.onUpdate = onUpdate
        _mode = State(initialValue: transportation.mode)
        _time = State(initialValue: transportation.time)
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Transportation")
                .font(.headline)
            
            TextField("Mode of Transport", text: $mode)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .onChange(of: mode) { newValue in
                    onUpdate(TransportationDetails(mode: newValue, time: time))
                }
            
            DatePicker("Time", selection: $time, displayedComponents: [.hourAndMinute])
                .onChange(of: time) { newValue in
                    onUpdate(TransportationDetails(mode: mode, time: newValue))
                }
        }
        .padding()
    }
} 