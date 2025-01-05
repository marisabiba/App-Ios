import SwiftUI

struct AddTripButton: View {
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: "plus")
        }
    }
}

struct AddTripButton_Previews: PreviewProvider {
    static var previews: some View {
        AddTripButton {
            print("Add button tapped")
        }
    }
}
