import SwiftUI

struct AddTripButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
                .font(.title2)
                .padding(8)
                .background(Circle().fill(Color.blue))
                .foregroundColor(.white)
        }
        .accessibilityLabel("Add Trip")
    }
}
